const express = require("express");
const db = require("../config/db");
const { authenticate, authorize } = require("../middleware/auth");
const upload = require("../config/multer");
const cloudinary = require("../config/cloudinary");
const fs = require("fs");

const router = express.Router();

const slugify = (text) => text.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");

router.get("/", (req, res) => {
  try {
    const { category, search, sort, page = 1, limit = 12 } = req.query;
    let sql = `SELECT p.*, c.name as category_name,
      (SELECT ROUND(AVG(rating),1) FROM reviews WHERE product_id = p.id) as avg_rating,
      (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as review_count
      FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.is_active = 1`;
    const params = [];

    if (category) { sql += " AND c.slug = ?"; params.push(category); }
    if (search) { sql += " AND (p.name LIKE ? OR p.description LIKE ?)"; params.push(`%${search}%`, `%${search}%`); }

    if (sort === "price_asc") sql += " ORDER BY p.price ASC";
    else if (sort === "price_desc") sql += " ORDER BY p.price DESC";
    else sql += " ORDER BY p.created_at DESC";

    const offset = (page - 1) * limit;
    sql += " LIMIT ? OFFSET ?";
    params.push(Number(limit), Number(offset));

    const products = db.queryAll(sql, params);
    const countResult = db.queryGet("SELECT COUNT(*) as total FROM products WHERE is_active = 1");

    res.json({ products, total: countResult.total, page: Number(page), limit: Number(limit) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/meta/categories", (req, res) => {
  try {
    const rows = db.queryAll("SELECT * FROM categories ORDER BY name");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/:slug", (req, res) => {
  try {
    const row = db.queryGet(
      "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.slug = ?",
      [req.params.slug]
    );
    if (!row) return res.status(404).json({ message: "Product not found" });
    res.json(row);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/", authenticate, authorize("admin"), upload.single("image"), async (req, res) => {
  try {
    const { name, description, price, compare_price, category_id, stock, sizes, colors } = req.body;
    let imageUrl = null;

    if (req.file) {
      if (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_CLOUD_NAME !== "placeholder") {
        try {
          const result = await cloudinary.uploader.upload(req.file.path, { folder: "village-netacad" });
          imageUrl = result.secure_url;
          fs.unlinkSync(req.file.path);
        } catch {
          imageUrl = `/uploads/${req.file.filename}`;
        }
      } else {
        imageUrl = `/uploads/${req.file.filename}`;
      }
    }

    const slug = slugify(name) + "-" + Date.now();
    const result = db.queryRun(
      "INSERT INTO products (name, slug, description, price, compare_price, category_id, image, stock, sizes, colors) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [name, slug, description, price, compare_price || null, category_id || null, imageUrl, stock || 0, sizes || null, colors || null]
    );

    res.status(201).json({ id: result.lastInsertRowid, message: "Product created" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put("/:id", authenticate, authorize("admin"), upload.single("image"), (req, res) => {
  try {
    const { name, description, price, compare_price, category_id, stock, sizes, colors, is_active } = req.body;
    const fields = [];
    const params = [];

    if (name) { fields.push("name = ?", "slug = ?"); params.push(name, slugify(name) + "-" + Date.now()); }
    if (description !== undefined) { fields.push("description = ?"); params.push(description); }
    if (price) { fields.push("price = ?"); params.push(price); }
    if (compare_price !== undefined) { fields.push("compare_price = ?"); params.push(compare_price || null); }
    if (category_id !== undefined) { fields.push("category_id = ?"); params.push(category_id || null); }
    if (stock !== undefined) { fields.push("stock = ?"); params.push(stock); }
    if (sizes) { fields.push("sizes = ?"); params.push(sizes); }
    if (colors) { fields.push("colors = ?"); params.push(colors); }
    if (is_active !== undefined) { fields.push("is_active = ?"); params.push(is_active); }

    if (req.file) {
      fields.push("image = ?");
      params.push(`/uploads/${req.file.filename}`);
    }

    if (!fields.length) return res.status(400).json({ message: "No fields to update" });

    params.push(req.params.id);
    db.queryRun(`UPDATE products SET ${fields.join(", ")} WHERE id = ?`, params);
    res.json({ message: "Product updated" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete("/:id", authenticate, authorize("admin"), (req, res) => {
  try {
    db.queryRun("DELETE FROM products WHERE id = ?", [req.params.id]);
    res.json({ message: "Product deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
