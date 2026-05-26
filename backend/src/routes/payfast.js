const express = require("express");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");
const { authenticate } = require("../middleware/auth");
const { fulfillOrder } = require("../services/orderFulfillment");
const {
  config,
  isPayFastConfigured,
  generateSignature,
  buildPaymentPayload,
  buildSignatureString,
  getNotifyUrl,
  isNotifyUrlLocal,
  probePayFastCredentials,
} = require("../config/payfast");

const router = express.Router();

const parsePaymentId = (mPaymentId) => {
  const match = String(mPaymentId || "").match(/^(order|donation)-(\d+)$/);
  if (!match) return null;
  return { type: match[1], id: Number(match[2]) };
};

/** Validate ITN with PayFast servers */
const validateItnWithPayFast = async (body) => {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(body)) {
    if (value !== undefined && value !== null && key !== "signature") {
      params.append(key, String(value));
    }
  }
  const res = await fetch(config.validateUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params.toString(),
  });
  const text = await res.text();
  return text.trim() === "VALID";
};

router.get("/status", (req, res) => {
  res.json({
    configured: isPayFastConfigured(),
    sandbox: config.sandbox,
    process_url: config.processUrl,
    notify_url: `${require("../config/payfast").getApiBaseUrl()}/api/payfast/notify`,
    has_passphrase: Boolean(config.passphrase),
  });
});

/** Dev helper: verify PayFast credentials load (restart backend after .env changes) */
router.get("/check", async (req, res) => {
  if (process.env.NODE_ENV === "production") {
    return res.status(404).json({ message: "Not found" });
  }
  if (!isPayFastConfigured()) {
    return res.status(503).json({
      ok: false,
      message: "Set PAYFAST_MERCHANT_ID and PAYFAST_MERCHANT_KEY in backend/.env",
    });
  }

  const notifyUrl = getNotifyUrl();
  const sample = buildPaymentPayload({
    amount: 50,
    itemName: "Test Payment",
    paymentId: "donation-test",
    email: "test@example.com",
    name: "Test User",
    returnPath: "/payment/success?type=donation&id=1",
    cancelPath: "/payment/cancel?type=donation&id=1",
  });

  const warnings = [];
  const blockers = [];

  if (isNotifyUrlLocal(notifyUrl)) {
    warnings.push(
      "notify_url uses localhost — payments may work, but PayFast cannot confirm them. Use ngrok: PAYFAST_NOTIFY_URL=https://YOUR-ID.ngrok-free.app/api/payfast/notify"
    );
  }
  if (config.passphrase) {
    warnings.push(
      "Passphrase is set — it must match PayFast → Settings → Security exactly, or remove PAYFAST_PASSPHRASE from .env if disabled."
    );
  }

  const probe = await probePayFastCredentials();
  if (probe.invalid_merchant_id) {
    blockers.push(
      "Invalid merchant ID — copy Merchant ID and Merchant Key from https://sandbox.payfast.co.za (Settings → Integration)."
    );
  }
  if (probe.signature_mismatch) {
    blockers.push("Signature rejected — check PAYFAST_PASSPHRASE matches your PayFast security settings.");
  }
  if (probe.merchant_key_required) {
    blockers.push("PayFast requires merchant_key in the payment form (server misconfiguration).");
  }

  res.json({
    ok: blockers.length === 0,
    sandbox: config.sandbox,
    merchant_id: config.merchantId,
    has_passphrase: Boolean(config.passphrase),
    notify_url: notifyUrl,
    warnings,
    blockers,
    probe,
    sample_signature: sample.signature,
    tips: [
      "Credentials in .env must be from the SAME environment as PAYFAST_SANDBOX (sandbox vs live).",
      "Restart backend after any .env change.",
    ],
  });
});

/**
 * Simple PayFast payment (tutorial-style /api/pay route).
 * POST body: { amount, item_name, name_first, email_address, name_last?, m_payment_id?, return_url?, cancel_url? }
 * Returns: { url, fields } — frontend must POST fields to url (see redirectToPayFast).
 */
const handlePay = (req, res) => {
  try {
    if (!isPayFastConfigured()) {
      return res.status(503).json({ message: "PayFast is not configured on the server" });
    }

    const {
      amount,
      item_name,
      name_first,
      email_address,
      name_last,
      m_payment_id,
      return_url,
      cancel_url,
    } = req.body;

    if (!amount || !item_name || !name_first || !email_address) {
      return res.status(400).json({
        message: "amount, item_name, name_first, and email_address are required",
      });
    }

    const fullName = name_last ? `${name_first} ${name_last}`.trim() : String(name_first).trim();

    const fields = buildPaymentPayload({
      amount,
      itemName: item_name,
      paymentId: m_payment_id,
      email: email_address,
      name: fullName,
      returnUrl: return_url,
      cancelUrl: cancel_url,
    });

    res.json({
      url: config.processUrl,
      fields,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

router.post("/pay", handlePay);

/** Dev only: show signature string used for PayFast (compare in PayFast merchant tools) */
router.get("/debug-signature", (req, res) => {
  if (process.env.NODE_ENV === "production") {
    return res.status(404).json({ message: "Not found" });
  }
  const sample = buildPaymentPayload({
    amount: 50,
    itemName: "Test",
    paymentId: "donation-1",
    email: "test@test.com",
    name: "Test User",
    returnPath: "/payment/success?type=donation&id=1",
    cancelPath: "/payment/cancel?type=donation&id=1",
  });
  res.json({
    signature_string: buildSignatureString(sample),
    signature: sample.signature,
    fields: { ...sample, signature: "[hidden]" },
  });
});

/** Start PayFast payment for an order */
router.post("/order/:orderId", authenticate, (req, res) => {
  try {
    if (!isPayFastConfigured()) {
      return res.status(503).json({ message: "PayFast is not configured on the server" });
    }

    const orderId = Number(req.params.orderId);
    const order = db.queryGet("SELECT * FROM orders WHERE id = ?", [orderId]);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (order.user_id !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Access denied" });
    }
    if (order.payment_status === "paid") {
      return res.status(400).json({ message: "Order is already paid" });
    }

    const fields = buildPaymentPayload({
      amount: order.total,
      itemName: `Village Netacad Order #${orderId}`,
      paymentId: `order-${orderId}`,
      email: req.user.email,
      name: req.user.name,
      returnPath: `/payment/success?type=order&id=${orderId}`,
      cancelPath: `/payment/cancel?type=order&id=${orderId}`,
    });

    res.json({ url: config.processUrl, fields });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

/** Start PayFast payment for a donation */
router.post("/donation/:donationId", (req, res) => {
  try {
    if (!isPayFastConfigured()) {
      return res.status(503).json({ message: "PayFast is not configured on the server" });
    }

    const donationId = Number(req.params.donationId);
    const donation = db.queryGet("SELECT * FROM donations WHERE id = ?", [donationId]);
    if (!donation) return res.status(404).json({ message: "Donation not found" });
    if (donation.payment_status === "completed") {
      return res.status(400).json({ message: "Donation is already completed" });
    }

    const fields = buildPaymentPayload({
      amount: donation.amount,
      itemName: `Village Netacad Donation #${donationId}`,
      paymentId: `donation-${donationId}`,
      email: donation.email || "donor@villagenetacad.co.za",
      name: donation.donor_name || "Donor",
      returnPath: `/payment/success?type=donation&id=${donationId}`,
      cancelPath: `/payment/cancel?type=donation&id=${donationId}`,
    });

    res.json({ url: config.processUrl, fields });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

/** PayFast ITN (Instant Transaction Notification) */
router.post("/notify", express.urlencoded({ extended: false }), async (req, res) => {
  res.status(200).send("OK");

  try {
    const data = { ...req.body };
    const receivedSignature = data.signature;
    const expectedSignature = generateSignature(data);

    if (!receivedSignature || receivedSignature !== expectedSignature) {
      console.error("PayFast ITN: invalid signature");
      return;
    }

    const valid = await validateItnWithPayFast(data);
    if (!valid) {
      console.error("PayFast ITN: validation failed");
      return;
    }

    const parsed = parsePaymentId(data.m_payment_id);
    if (!parsed) {
      console.error("PayFast ITN: unknown m_payment_id", data.m_payment_id);
      return;
    }

    const pfStatus = String(data.payment_status || "").toUpperCase();
    if (pfStatus !== "COMPLETE") {
      if (parsed.type === "order") {
        db.queryRun("UPDATE orders SET payment_status = 'failed', updated_at = datetime('now') WHERE id = ?", [
          parsed.id,
        ]);
      } else {
        db.queryRun("UPDATE donations SET payment_status = 'failed' WHERE id = ?", [parsed.id]);
      }
      return;
    }

    const pfPaymentId = data.pf_payment_id || data.m_payment_id;

    if (parsed.type === "order") {
      const order = db.queryGet("SELECT * FROM orders WHERE id = ?", [parsed.id]);
      if (!order || order.payment_status === "paid") return;

      const paidAmount = Number(data.amount_gross || data.amount_net || 0);
      if (Math.abs(paidAmount - order.total) > 0.01) {
        console.error("PayFast ITN: amount mismatch", paidAmount, order.total);
        return;
      }

      db.queryRun("UPDATE orders SET payment_intent_id = ? WHERE id = ?", [pfPaymentId, parsed.id]);
      fulfillOrder(parsed.id);
    } else if (parsed.type === "donation") {
      const donation = db.queryGet("SELECT * FROM donations WHERE id = ?", [parsed.id]);
      if (!donation || donation.payment_status === "completed") return;

      db.queryRun(
        "UPDATE donations SET payment_status = 'completed', payment_intent_id = ? WHERE id = ?",
        [pfPaymentId, parsed.id]
      );

      sendEmail({
        to: SITE_EMAIL,
        replyTo: donation.email || undefined,
        subject: `Donation received: R${Number(donation.amount).toFixed(2)}`,
        html: `<p><strong>Donation ID:</strong> ${parsed.id}</p>
          <p><strong>Academy:</strong> ${donation.academy || "—"}</p>
          <p><strong>Donor:</strong> ${donation.donor_name}</p>
          <p><strong>Amount:</strong> R${Number(donation.amount).toFixed(2)}</p>
          <p><strong>PayFast ref:</strong> ${pfPaymentId}</p>`,
      });
    }
  } catch (err) {
    console.error("PayFast ITN error:", err.message);
  }
});

module.exports = router;
module.exports.handlePay = handlePay;
