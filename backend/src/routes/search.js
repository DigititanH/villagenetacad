const express = require("express");
const db = require("../config/db");

const router = express.Router();

const PAGES = [
  { title: "Home", description: "Village Netacad - AI Future Hub. Empowering Smart Villages through digital education.", path: "/" },
  { title: "About Us", description: "Learn about our mission, team, partners and community impact.", path: "/about" },
  { title: "Shop", description: "Browse our futuristic store with AI-inspired fashion and merchandise.", path: "/shop" },
  { title: "Donation", description: "Support the development of AI-powered innovation hubs across Africa.", path: "/donation" },
  { title: "Contact Us", description: "Get in touch with Village Netacad. Email, phone, location.", path: "/contact" },
  { title: "Login", description: "Sign in to your Village Netacad account.", path: "/login" },
  { title: "Register", description: "Create a new customer or reseller account.", path: "/register" },
  { title: "Cart", description: "View and manage items in your shopping cart.", path: "/cart" },
  { title: "My Orders", description: "Track your order history and status.", path: "/my-orders" },
  { title: "Wishlist", description: "View your saved products.", path: "/wishlist" },
];

router.get("/", (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 2) {
      return res.json({ products: [], pages: [], categories: [] });
    }

    const term = `%${q.trim()}%`;

    const products = db.queryAll(
      `SELECT p.id, p.name, p.slug, p.price, p.image, p.description, c.name as category_name,
        (SELECT ROUND(AVG(rating),1) FROM reviews WHERE product_id = p.id) as avg_rating
       FROM products p LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.is_active = 1 AND (p.name LIKE ? OR p.description LIKE ? OR c.name LIKE ?)
       ORDER BY p.name ASC LIMIT 8`,
      [term, term, term]
    );

    const categories = db.queryAll(
      "SELECT id, name, slug FROM categories WHERE name LIKE ? ORDER BY name LIMIT 5",
      [term]
    );

    const lowerQ = q.trim().toLowerCase();
    const pages = PAGES.filter(
      (p) => p.title.toLowerCase().includes(lowerQ) || p.description.toLowerCase().includes(lowerQ)
    );

    res.json({ products, pages, categories });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
