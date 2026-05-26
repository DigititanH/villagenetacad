const express = require("express");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");

const router = express.Router();

router.post("/", (req, res) => {
  try {
    const { name, email, subject, message } = req.body;
    if (!name || !email || !message) return res.status(400).json({ message: "Name, email and message are required" });

    db.queryRun("INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)", [name, email, subject || null, message]);

    sendEmail({
      to: SITE_EMAIL,
      replyTo: email,
      subject: `Contact Form: ${subject || "New Message"} from ${name}`,
      html: `<p><strong>From:</strong> ${name} (${email})</p><p>${message.replace(/\n/g, "<br>")}</p>`,
    });

    res.status(201).json({ message: "Message sent successfully" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
