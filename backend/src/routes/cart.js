const express = require("express");
const db = require("../config/db");
const { authenticate } = require("../middleware/auth");

const router = express.Router();

router.get("/", authenticate, (req, res) => {
  try {
    const rows = db.queryAll(
      "SELECT c.*, p.name, p.price, p.image, p.stock, p.sizes as available_sizes FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?",
      [req.user.id]
    );
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/", authenticate, (req, res) => {
  try {
    const { product_id, quantity = 1, size, color } = req.body;
    const existing = db.queryGet(
      "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ? AND (size = ? OR (size IS NULL AND ? IS NULL)) AND (color = ? OR (color IS NULL AND ? IS NULL))",
      [req.user.id, product_id, size || null, size || null, color || null, color || null]
    );

    if (existing) {
      db.queryRun("UPDATE cart SET quantity = quantity + ? WHERE id = ?", [quantity, existing.id]);
    } else {
      db.queryRun("INSERT INTO cart (user_id, product_id, quantity, size, color) VALUES (?, ?, ?, ?, ?)", [req.user.id, product_id, quantity, size || null, color || null]);
    }

    res.status(201).json({ message: "Added to cart" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/:id", authenticate, (req, res) => {
  try {
    const { quantity, size } = req.body;
    if (quantity !== undefined && quantity < 1) {
      db.queryRun("DELETE FROM cart WHERE id = ? AND user_id = ?", [req.params.id, req.user.id]);
    } else {
      const fields = [];
      const params = [];
      if (quantity !== undefined) { fields.push("quantity = ?"); params.push(quantity); }
      if (size !== undefined) { fields.push("size = ?"); params.push(size || null); }
      if (fields.length) {
        params.push(req.params.id, req.user.id);
        db.queryRun(`UPDATE cart SET ${fields.join(", ")} WHERE id = ? AND user_id = ?`, params);
      }
    }
    res.json({ message: "Cart updated" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete("/:id", authenticate, (req, res) => {
  try {
    db.queryRun("DELETE FROM cart WHERE id = ? AND user_id = ?", [req.params.id, req.user.id]);
    res.json({ message: "Item removed from cart" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete("/", authenticate, (req, res) => {
  try {
    db.queryRun("DELETE FROM cart WHERE user_id = ?", [req.user.id]);
    res.json({ message: "Cart cleared" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
