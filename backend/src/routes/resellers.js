const express = require("express");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

const requireApprovedReseller = (req, res, next) => {
  const profile = db.queryGet("SELECT status FROM reseller_profiles WHERE user_id = ?", [req.user.id]);
  if (!profile) return res.status(404).json({ message: "Reseller profile not found" });
  if (profile.status !== "approved") {
    return res.status(403).json({ message: "Reseller account is pending admin approval" });
  }
  next();
};

router.get("/profile", authenticate, authorize("reseller"), (req, res) => {
  try {
    const row = db.queryGet("SELECT rp.*, u.name, u.email, u.is_approved FROM reseller_profiles rp JOIN users u ON rp.user_id = u.id WHERE rp.user_id = ?", [req.user.id]);
    if (!row) return res.status(404).json({ message: "Reseller profile not found" });

    if (row.is_approved === "approved" && row.status === "pending") {
      db.queryRun("UPDATE reseller_profiles SET status = 'approved' WHERE user_id = ?", [req.user.id]);
      row.status = "approved";
    }
    if (row.is_approved === "declined" && row.status === "pending") {
      db.queryRun("UPDATE reseller_profiles SET status = 'rejected' WHERE user_id = ?", [req.user.id]);
      row.status = "rejected";
    }

    res.json(row);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/commissions", authenticate, authorize("reseller"), requireApprovedReseller, (req, res) => {
  try {
    const profile = db.queryGet("SELECT id FROM reseller_profiles WHERE user_id = ?", [req.user.id]);
    if (!profile) return res.status(404).json({ message: "Profile not found" });
    const rows = db.queryAll("SELECT c.*, o.total as order_total, o.created_at as order_date FROM commissions c JOIN orders o ON c.order_id = o.id WHERE c.reseller_id = ? ORDER BY c.created_at DESC", [profile.id]);
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/sales", authenticate, authorize("reseller"), requireApprovedReseller, (req, res) => {
  try {
    const profile = db.queryGet("SELECT id FROM reseller_profiles WHERE user_id = ?", [req.user.id]);
    if (!profile) return res.status(404).json({ message: "Profile not found" });
    const rows = db.queryAll("SELECT o.id, o.total, o.status, o.created_at, u.name as customer_name FROM commissions c JOIN orders o ON c.order_id = o.id JOIN users u ON o.user_id = u.id WHERE c.reseller_id = ? ORDER BY o.created_at DESC", [profile.id]);
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/withdraw", authenticate, authorize("reseller"), requireApprovedReseller, (req, res) => {
  try {
    const { amount, bank_details } = req.body;
    const profile = db.queryGet("SELECT id, wallet_balance FROM reseller_profiles WHERE user_id = ?", [req.user.id]);
    if (!profile) return res.status(404).json({ message: "Profile not found" });
    if (amount > profile.wallet_balance) return res.status(400).json({ message: "Insufficient balance" });

    db.queryRun("INSERT INTO withdrawals (reseller_id, amount, bank_details) VALUES (?, ?, ?)", [profile.id, amount, JSON.stringify(bank_details)]);
    db.queryRun("UPDATE reseller_profiles SET wallet_balance = wallet_balance - ? WHERE id = ?", [amount, profile.id]);

    sendEmail({
      to: SITE_EMAIL,
      replyTo: req.user.email,
      subject: `Withdrawal request: R${amount} from ${req.user.name}`,
      html: `<p><strong>Reseller:</strong> ${req.user.name} (${req.user.email})</p>
        <p><strong>Amount:</strong> R${amount}</p>
        <p><strong>Bank details:</strong><br>${JSON.stringify(bank_details, null, 2).replace(/\n/g, "<br>")}</p>`,
    });

    res.status(201).json({ message: "Withdrawal request submitted" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/withdrawals", authenticate, authorize("reseller"), requireApprovedReseller, (req, res) => {
  try {
    const profile = db.queryGet("SELECT id FROM reseller_profiles WHERE user_id = ?", [req.user.id]);
    if (!profile) return res.status(404).json({ message: "Profile not found" });
    const rows = db.queryAll("SELECT * FROM withdrawals WHERE reseller_id = ? ORDER BY created_at DESC", [profile.id]);
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/admin/all", authenticate, authorize("admin"), (req, res) => {
  try {
    const rows = db.queryAll("SELECT rp.*, u.name, u.email FROM reseller_profiles rp JOIN users u ON rp.user_id = u.id ORDER BY rp.created_at DESC");
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/admin/:id/status", authenticate, authorize("admin"), (req, res) => {
  try {
    const { status } = req.body;
    if (!["approved", "rejected", "suspended"].includes(status))
      return res.status(400).json({ message: "Invalid status" });
    db.queryRun("UPDATE reseller_profiles SET status = ? WHERE id = ?", [status, req.params.id]);
    const profile = db.queryGet("SELECT user_id FROM reseller_profiles WHERE id = ?", [req.params.id]);
    if (profile) {
      const userStatus = status === "approved" ? "approved" : "declined";
      db.queryRun("UPDATE users SET is_approved = ? WHERE id = ?", [userStatus, profile.user_id]);
    }
    res.json({ message: `Reseller ${status}` });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/admin/withdrawals", authenticate, authorize("admin"), (req, res) => {
  try {
    const rows = db.queryAll("SELECT w.*, rp.referral_code, u.name, u.email FROM withdrawals w JOIN reseller_profiles rp ON w.reseller_id = rp.id JOIN users u ON rp.user_id = u.id ORDER BY w.created_at DESC");
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/admin/withdrawals/:id", authenticate, authorize("admin"), (req, res) => {
  try {
    const { status } = req.body;
    if (!["approved", "rejected", "completed"].includes(status))
      return res.status(400).json({ message: "Invalid status" });

    if (status === "rejected") {
      const w = db.queryGet("SELECT reseller_id, amount FROM withdrawals WHERE id = ?", [req.params.id]);
      if (w) db.queryRun("UPDATE reseller_profiles SET wallet_balance = wallet_balance + ? WHERE id = ?", [w.amount, w.reseller_id]);
    }

    db.queryRun("UPDATE withdrawals SET status = ?, processed_at = datetime('now') WHERE id = ?", [status, req.params.id]);
    res.json({ message: `Withdrawal ${status}` });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
