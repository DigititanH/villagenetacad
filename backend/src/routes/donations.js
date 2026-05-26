const express = require("express");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");
const { isPayFastConfigured, buildPaymentPayload, config } = require("../config/payfast");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

router.post("/", (req, res) => {
  try {
    const { amount, donor_name, email, message, is_anonymous, is_recurring, recurring_interval, user_id, academy } = req.body;
    if (!amount || amount < 1)
      return res.status(400).json({ message: "Amount must be at least R1" });

    const academyName = String(academy || "").trim();
    if (!academyName) {
      return res.status(400).json({ message: "Please enter the name of the academy you are donating to" });
    }

    const payfastEnabled = isPayFastConfigured();
    if (payfastEnabled && !email?.trim()) {
      return res.status(400).json({ message: "Email is required for PayFast payment" });
    }
    if (payfastEnabled && !is_anonymous && !donor_name?.trim()) {
      return res.status(400).json({ message: "Name is required for PayFast payment" });
    }

    const result = db.queryRun(
      "INSERT INTO donations (user_id, donor_name, email, amount, is_recurring, recurring_interval, payment_status, message, is_anonymous, academy) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [user_id || null, is_anonymous ? "Anonymous" : (donor_name || "Anonymous"), email || null,
        amount, is_recurring ? 1 : 0, recurring_interval || null, "pending", message || null, is_anonymous ? 1 : 0, academyName]
    );

    const donationId = result.lastInsertRowid;
    const donorLabel = is_anonymous ? "Anonymous" : (donor_name || "Anonymous");

    if (payfastEnabled) {
      const fields = buildPaymentPayload({
        amount,
        itemName: `Village Netacad Donation #${donationId}`,
        paymentId: `donation-${donationId}`,
        email: email.trim(),
        name: donorLabel,
        returnPath: `/payment/success?type=donation&id=${donationId}`,
        cancelPath: `/payment/cancel?type=donation&id=${donationId}`,
      });

      return res.status(201).json({
        donation_id: donationId,
        academy: academyName,
        payfast: true,
        url: config.processUrl,
        fields,
        message: "Redirecting to PayFast to complete your donation.",
      });
    }

    sendEmail({
      to: SITE_EMAIL,
      replyTo: email || undefined,
      subject: `Donation pledge: R${amount} from ${donorLabel}`,
      html: `<p><strong>Donation ID:</strong> ${donationId}</p>
        <p><strong>Academy:</strong> ${academyName}</p>
        <p><strong>Donor:</strong> ${donorLabel}</p>
        <p><strong>Email:</strong> ${email || "—"}</p>
        <p><strong>Amount:</strong> R${amount}</p>
        ${message ? `<p><strong>Message:</strong> ${message}</p>` : ""}`,
    });

    res.status(201).json({
      donation_id: donationId,
      academy: academyName,
      payfast: false,
      message: "Thank you! Your donation has been recorded.",
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/my-donations", authenticate, (req, res) => {
  try {
    const rows = db.queryAll("SELECT * FROM donations WHERE user_id = ? ORDER BY created_at DESC", [req.user.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/:id/summary", (req, res) => {
  try {
    const donation = db.queryGet(
      "SELECT id, academy, amount, donor_name, payment_status, is_anonymous FROM donations WHERE id = ?",
      [req.params.id]
    );
    if (!donation) return res.status(404).json({ message: "Donation not found" });
    res.json(donation);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/admin/all", authenticate, authorize("admin"), (req, res) => {
  try {
    const donations = db.queryAll("SELECT * FROM donations ORDER BY created_at DESC");
    const totals = db.queryGet("SELECT COUNT(*) as count, COALESCE(SUM(amount),0) as total FROM donations WHERE payment_status = 'completed'");
    const monthly = db.queryAll(
      "SELECT strftime('%Y-%m', created_at) as month, SUM(amount) as total, COUNT(*) as count FROM donations WHERE payment_status = 'completed' GROUP BY month ORDER BY month DESC LIMIT 12"
    );

    res.json({ donations, summary: totals, monthly });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
