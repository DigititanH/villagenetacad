const express = require("express");
const db = require("../config/db");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

router.get("/", authenticate, (req, res) => {
  try {
    const rows = db.queryAll("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50", [req.user.id]);
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/:id/read", authenticate, (req, res) => {
  try {
    db.queryRun("UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?", [req.params.id, req.user.id]);
    res.json({ message: "Marked as read" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/read-all", authenticate, (req, res) => {
  try {
    db.queryRun("UPDATE notifications SET is_read = 1 WHERE user_id = ?", [req.user.id]);
    res.json({ message: "All marked as read" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
