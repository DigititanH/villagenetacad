const express = require("express");
const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");
const { isPayFastConfigured } = require("../config/payfast");
const { fulfillOrder } = require("../services/orderFulfillment");
const { authenticate, authorize } = require("../middleware/auth");
const router = express.Router();

router.post("/", authenticate, (req, res) => {
  try {
    const { items, shipping_address, referral_code } = req.body;
    if (!items?.length || !shipping_address)
      return res.status(400).json({ message: "Items and shipping address are required" });

    const code = referral_code?.trim();
    let reseller = null;

    if (req.user.role !== "admin") {
      if (!code)
        return res.status(400).json({ message: "A reseller referral code is required to place an order" });

      reseller = db.queryGet(
        "SELECT id, commission_rate FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
        [code]
      );
      if (!reseller)
        return res.status(400).json({ message: "Invalid or inactive reseller referral code" });
    } else if (code) {
      reseller = db.queryGet(
        "SELECT id, commission_rate FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
        [code]
      );
    }

    let total = 0;
    const orderItems = [];

    for (const item of items) {
      const product = db.queryGet("SELECT id, price, stock, name FROM products WHERE id = ? AND is_active = 1", [
        item.product_id,
      ]);
      if (!product) return res.status(400).json({ message: `Product ${item.product_id} not found` });
      if (product.stock < item.quantity) return res.status(400).json({ message: `${product.name} is out of stock` });

      const lineTotal = product.price * item.quantity;
      total += lineTotal;
      orderItems.push({ ...item, price: product.price, name: product.name });
    }

    const payfastEnabled = isPayFastConfigured();

    const order = db.queryRun(
      "INSERT INTO orders (user_id, total, shipping_address, payment_status, referral_code) VALUES (?, ?, ?, 'pending', ?)",
      [req.user.id, total, JSON.stringify(shipping_address), code || null]
    );
    const orderId = order.lastInsertRowid;

    for (const item of orderItems) {
      db.queryRun(
        "INSERT INTO order_items (order_id, product_id, quantity, price, size, color) VALUES (?, ?, ?, ?, ?, ?)",
        [orderId, item.product_id, item.quantity, item.price, item.size || null, item.color || null]
      );
    }

    if (payfastEnabled) {
      return res.status(201).json({
        order_id: orderId,
        total,
        payfast: true,
        message: "Order created. Redirecting to PayFast for payment.",
      });
    }

    // No PayFast: complete order immediately (manual / dev mode)
    fulfillOrder(orderId);

    res.status(201).json({
      order_id: orderId,
      total,
      payfast: false,
      message: "Order placed successfully.",
    });
  } catch (err) {
    console.error("Order checkout error:", err.message);
    res.status(500).json({ message: err.message });
  }
});

router.get("/my-orders", authenticate, (req, res) => {
  try {
    const orders = db.queryAll("SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC", [req.user.id]);
    for (const order of orders) {
      order.items = db.queryAll("SELECT * FROM order_items WHERE order_id = ?", [order.id]);
    }
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/admin/all", authenticate, authorize("admin"), (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    let sql = "SELECT o.*, u.name as customer_name, u.email as customer_email FROM orders o JOIN users u ON o.user_id = u.id";
    const params = [];

    if (status) { sql += " WHERE o.status = ?"; params.push(status); }
    sql += " ORDER BY o.created_at DESC LIMIT ? OFFSET ?";
    params.push(Number(limit), (page - 1) * limit);

    const orders = db.queryAll(sql, params);
    const countResult = db.queryGet("SELECT COUNT(*) as total FROM orders");

    res.json({ orders, total: countResult.total });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/:id", authenticate, (req, res) => {
  try {
    const order = db.queryGet("SELECT * FROM orders WHERE id = ?", [req.params.id]);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (req.user.role !== "admin" && order.user_id !== req.user.id)
      return res.status(403).json({ message: "Access denied" });

    order.items = db.queryAll("SELECT * FROM order_items WHERE order_id = ?", [order.id]);
    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put("/:id", authenticate, authorize("admin"), (req, res) => {
  try {
    const { status, tracking_number } = req.body;
    const fields = [];
    const params = [];

    if (status) { fields.push("status = ?"); params.push(status); }
    if (tracking_number) { fields.push("tracking_number = ?"); params.push(tracking_number); }

    if (!fields.length) return res.status(400).json({ message: "Nothing to update" });

    params.push(req.params.id);
    db.queryRun(`UPDATE orders SET ${fields.join(", ")} WHERE id = ?`, params);
    res.json({ message: "Order updated" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
