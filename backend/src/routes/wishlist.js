const express = require("express");
const db = require("../config/db");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

router.get("/", authenticate, (req, res) => {
  try {
    const rows = db.queryAll("SELECT w.*, p.name, p.price, p.image, p.slug FROM wishlist w JOIN products p ON w.product_id = p.id WHERE w.user_id = ?", [req.user.id]);
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/toggle", authenticate, (req, res) => {
  try {
    const { product_id } = req.body;
    const existing = db.queryGet("SELECT id FROM wishlist WHERE user_id = ? AND product_id = ?", [req.user.id, product_id]);

    if (existing) {
      db.queryRun("DELETE FROM wishlist WHERE id = ?", [existing.id]);
      res.json({ message: "Removed from wishlist", wishlisted: false });
    } else {
      db.queryRun("INSERT INTO wishlist (user_id, product_id) VALUES (?, ?)", [req.user.id, product_id]);
      res.json({ message: "Added to wishlist", wishlisted: true });
    }
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
