const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");
const { getClientUrl } = require("../config/client");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

router.post("/register", (req, res) => {
  try {
    const { name, email, password, role, academy } = req.body;
    if (!name || !email || !password)
      return res.status(400).json({ message: "Name, email and password are required" });

    const userRole = role === "reseller" ? "reseller" : "customer";
    if (userRole === "reseller") {
      const academyName = String(academy || "").trim();
      if (!academyName) {
        return res.status(400).json({ message: "Please enter the name of your academy" });
      }
    }

    const existing = db.queryGet("SELECT id FROM users WHERE email = ?", [email]);
    if (existing) return res.status(409).json({ message: "Email already registered" });

    const hash = bcrypt.hashSync(password, 12);
    const verificationToken = uuidv4();
    const approvalStatus = userRole === "customer" ? "approved" : "pending";
    const result = db.queryRun(
      "INSERT INTO users (name, email, password, role, verification_token, is_approved) VALUES (?, ?, ?, ?, ?, ?)",
      [name, email, hash, userRole, verificationToken, approvalStatus]
    );

    if (userRole === "reseller") {
      const referralCode = "VNA-" + uuidv4().slice(0, 8).toUpperCase();
      const academyName = String(academy).trim();
      db.queryRun(
        "INSERT INTO reseller_profiles (user_id, referral_code, academy) VALUES (?, ?, ?)",
        [result.lastInsertRowid, referralCode, academyName]
      );
      sendEmail({
        to: SITE_EMAIL,
        replyTo: email,
        subject: `New reseller registration: ${name}`,
        html: `<p><strong>Name:</strong> ${name}</p><p><strong>Email:</strong> ${email}</p><p><strong>Academy:</strong> ${academyName}</p><p><strong>Referral code:</strong> ${referralCode}</p>`,
      });
    }

    const verifyUrl = `${getClientUrl()}/verify-email?token=${verificationToken}`;
    sendEmail({ to: email, subject: "Verify your Village NetAcad account", html: `<h2>Welcome ${name}!</h2><p>Click <a href="${verifyUrl}">here</a> to verify your email.</p>` });

    if (userRole === "reseller" && approvalStatus === "pending") {
      return res.status(201).json({
        pending: true,
        message: "Reseller account created. An admin must approve it before you can sign in.",
        user: { id: result.lastInsertRowid, name, email, role: userRole, is_approved: approvalStatus },
      });
    }

    const token = signToken(result.lastInsertRowid);
    res.status(201).json({
      token,
      user: { id: result.lastInsertRowid, name, email, role: userRole, is_approved: approvalStatus },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/login", (req, res) => {
  try {
    const email = req.body.email?.trim().toLowerCase();
    const password = req.body.password;
    if (!email || !password)
      return res.status(400).json({ message: "Email and password are required" });

    const user = db.queryGet("SELECT * FROM users WHERE LOWER(email) = ?", [email]);
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const valid = bcrypt.compareSync(password, user.password);
    if (!valid) return res.status(401).json({ message: "Invalid credentials" });

    if (user.is_approved === "declined")
      return res.status(403).json({ message: "Your account has been declined by an administrator" });

    if (user.is_approved === "pending" && user.role !== "admin")
      return res.status(403).json({ message: "Your account is pending admin approval" });

    const token = signToken(user.id);
    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        is_approved: user.is_approved,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/verify-email", (req, res) => {
  try {
    const { token } = req.query;
    const user = db.queryGet("SELECT id FROM users WHERE verification_token = ?", [token]);
    if (!user) return res.status(400).json({ message: "Invalid verification token" });

    db.queryRun("UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?", [user.id]);
    res.json({ message: "Email verified successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/forgot-password", (req, res) => {
  try {
    const { email } = req.body;
    const user = db.queryGet("SELECT id, name FROM users WHERE email = ?", [email]);
    if (!user) return res.json({ message: "If that email exists, a reset link was sent" });

    const resetToken = uuidv4();
    const expires = new Date(Date.now() + 3600000).toISOString();
    db.queryRun("UPDATE users SET reset_token = ?, reset_token_expires = ? WHERE id = ?", [resetToken, expires, user.id]);

    const resetUrl = `${getClientUrl()}/reset-password?token=${resetToken}`;
    sendEmail({ to: email, subject: "Password Reset - Village NetAcad", html: `<h2>Hi ${user.name}</h2><p>Click <a href="${resetUrl}">here</a> to reset your password. Expires in 1 hour.</p>` });

    res.json({ message: "If that email exists, a reset link was sent" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/reset-password", (req, res) => {
  try {
    const { token, password } = req.body;
    const user = db.queryGet("SELECT id FROM users WHERE reset_token = ? AND reset_token_expires > datetime('now')", [token]);
    if (!user) return res.status(400).json({ message: "Invalid or expired reset token" });

    const hash = bcrypt.hashSync(password, 12);
    db.queryRun("UPDATE users SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE id = ?", [hash, user.id]);
    res.json({ message: "Password reset successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/me", authenticate, (req, res) => {
  res.json({ user: req.user });
});

router.post("/logout", (req, res) => {
  res.json({ message: "Logged out successfully" });
});

module.exports = router;
