const express = require("express");
const db = require("../config/db");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

router.get("/product/:productId", (req, res) => {
  try {
    const rows = db.queryAll(
      "SELECT r.*, u.name as user_name, u.avatar FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.product_id = ? ORDER BY r.created_at DESC",
      [req.params.productId]
    );
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/", authenticate, (req, res) => {
  try {
    const { product_id, rating, comment } = req.body;
    if (!rating || rating < 1 || rating > 5) return res.status(400).json({ message: "Rating must be 1-5" });

    const existing = db.queryGet("SELECT id FROM reviews WHERE user_id = ? AND product_id = ?", [req.user.id, product_id]);
    if (existing) return res.status(409).json({ message: "You already reviewed this product" });

    db.queryRun("INSERT INTO reviews (user_id, product_id, rating, comment) VALUES (?, ?, ?, ?)", [req.user.id, product_id, rating, comment || null]);
    res.status(201).json({ message: "Review added" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete("/:id", authenticate, (req, res) => {
  try {
    const row = db.queryGet("SELECT user_id FROM reviews WHERE id = ?", [req.params.id]);
    if (!row) return res.status(404).json({ message: "Review not found" });
    if (row.user_id !== req.user.id && req.user.role !== "admin") return res.status(403).json({ message: "Access denied" });

    db.queryRun("DELETE FROM reviews WHERE id = ?", [req.params.id]);
    res.json({ message: "Review deleted" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
