const express = require("express");
const db = require("../config/db");
const { authenticate, authorize } = require("../middleware/auth");
const PDFDocument = require("pdfkit");
const { Parser: CsvParser } = require("json2csv");

const router = express.Router();

router.get("/dashboard", authenticate, authorize("admin"), (req, res) => {
  try {
    const users = db.queryAll("SELECT role, COUNT(*) as count FROM users GROUP BY role");
    const totalUsers = db.queryGet("SELECT COUNT(*) as total FROM users");
    const orders = db.queryGet("SELECT COUNT(*) as total, COALESCE(SUM(total),0) as revenue FROM orders");
    const pendingOrders = db.queryGet("SELECT COUNT(*) as total FROM orders WHERE status = 'pending'");
    const donations = db.queryGet("SELECT COUNT(*) as total, COALESCE(SUM(amount),0) as total_amount FROM donations WHERE payment_status = 'completed'");
    const products = db.queryGet("SELECT COUNT(*) as total FROM products");
    const pendingResellers = db.queryGet("SELECT COUNT(*) as total FROM reseller_profiles WHERE status = 'pending'");

    const monthlySales = db.queryAll(
      "SELECT strftime('%Y-%m', created_at) as month, SUM(total) as revenue, COUNT(*) as orders FROM orders GROUP BY month ORDER BY month DESC LIMIT 12"
    );

    const recentOrders = db.queryAll(
      "SELECT o.id, o.total, o.status, o.created_at, u.name FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC LIMIT 10"
    );

    const topProducts = db.queryAll(
      "SELECT p.name, SUM(oi.quantity) as sold, SUM(oi.quantity * oi.price) as revenue FROM order_items oi JOIN products p ON oi.product_id = p.id GROUP BY p.id ORDER BY sold DESC LIMIT 5"
    );

    res.json({
      stats: {
        total_users: totalUsers.total,
        users_by_role: users,
        total_orders: orders.total,
        total_revenue: orders.revenue,
        pending_orders: pendingOrders.total,
        total_donations: donations.total_amount,
        donation_count: donations.total,
        total_products: products.total,
        pending_resellers: pendingResellers.total,
      },
      monthly_sales: monthlySales,
      recent_orders: recentOrders,
      top_products: topProducts,
    });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/users", authenticate, authorize("admin"), (req, res) => {
  try {
    const { role, search, page = 1, limit = 20 } = req.query;
    let sql = "SELECT id, name, email, role, avatar, phone, is_verified, is_approved, created_at FROM users WHERE 1=1";
    const params = [];

    if (role) { sql += " AND role = ?"; params.push(role); }
    if (search) { sql += " AND (name LIKE ? OR email LIKE ?)"; params.push(`%${search}%`, `%${search}%`); }

    sql += " ORDER BY created_at DESC LIMIT ? OFFSET ?";
    params.push(Number(limit), (page - 1) * limit);

    const users = db.queryAll(sql, params);
    const count = db.queryGet("SELECT COUNT(*) as total FROM users");

    res.json({ users, total: count.total });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/users/:id/role", authenticate, authorize("admin"), (req, res) => {
  try {
    const { role } = req.body;
    if (!["admin", "reseller", "customer"].includes(role))
      return res.status(400).json({ message: "Invalid role" });
    db.queryRun("UPDATE users SET role = ? WHERE id = ?", [role, req.params.id]);
    res.json({ message: "User role updated" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put("/users/:id/approve", authenticate, authorize("admin"), (req, res) => {
  try {
    const { status } = req.body;
    if (!["approved", "declined"].includes(status))
      return res.status(400).json({ message: "Status must be 'approved' or 'declined'" });
    db.queryRun("UPDATE users SET is_approved = ? WHERE id = ?", [status, req.params.id]);

    const user = db.queryGet("SELECT role FROM users WHERE id = ?", [req.params.id]);
    if (user?.role === "reseller") {
      const profileStatus = status === "approved" ? "approved" : "rejected";
      db.queryRun("UPDATE reseller_profiles SET status = ? WHERE user_id = ?", [profileStatus, req.params.id]);
    }

    res.json({ message: `User ${status}` });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete("/users/:id", authenticate, authorize("admin"), (req, res) => {
  try {
    if (req.params.id == req.user.id) return res.status(400).json({ message: "Cannot delete yourself" });
    db.queryRun("DELETE FROM users WHERE id = ?", [req.params.id]);
    res.json({ message: "User deleted" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get("/contacts", authenticate, authorize("admin"), (req, res) => {
  try {
    const rows = db.queryAll("SELECT * FROM contact_messages ORDER BY created_at DESC");
    res.json(rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/notifications", authenticate, authorize("admin"), (req, res) => {
  try {
    const { user_id, title, message, type } = req.body;
    db.queryRun("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)", [user_id, title, message, type || "info"]);
    res.status(201).json({ message: "Notification sent" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post("/categories", authenticate, authorize("admin"), (req, res) => {
  try {
    const { name } = req.body;
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, "-");
    db.queryRun("INSERT INTO categories (name, slug) VALUES (?, ?)", [name, slug]);
    res.status(201).json({ message: "Category created" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete("/categories/:id", authenticate, authorize("admin"), (req, res) => {
  try {
    db.queryRun("DELETE FROM categories WHERE id = ?", [req.params.id]);
    res.json({ message: "Category deleted" });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// Sales report - CSV
router.get("/reports/sales/csv", authenticate, authorize("admin"), (req, res) => {
  try {
    const orders = db.queryAll(
      `SELECT o.id, u.name as customer, u.email, o.total, o.status, o.payment_status, o.tracking_number, o.created_at
       FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC`
    );

    const fields = ["id", "customer", "email", "total", "status", "payment_status", "tracking_number", "created_at"];
    const parser = new CsvParser({ fields });
    const csv = parser.parse(orders);

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", "attachment; filename=sales-report.csv");
    res.send(csv);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// Sales report - PDF
router.get("/reports/sales/pdf", authenticate, authorize("admin"), (req, res) => {
  try {
    const orders = db.queryAll(
      `SELECT o.id, u.name as customer, o.total, o.status, o.created_at
       FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC`
    );
    const summary = db.queryGet("SELECT COUNT(*) as count, COALESCE(SUM(total),0) as revenue FROM orders");

    const doc = new PDFDocument({ margin: 40, size: "A4" });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=sales-report.pdf");
    doc.pipe(res);

    // Header
    doc.fontSize(22).font("Helvetica-Bold").text("Village NetAcad", { align: "center" });
    doc.fontSize(14).font("Helvetica").text("Sales Report", { align: "center" });
    doc.fontSize(10).fillColor("#666").text(`Generated: ${new Date().toLocaleString()}`, { align: "center" });
    doc.moveDown(1.5);

    // Summary
    doc.fontSize(12).fillColor("#000").font("Helvetica-Bold").text("Summary");
    doc.fontSize(10).font("Helvetica");
    doc.text(`Total Orders: ${summary.count}`);
    doc.text(`Total Revenue: R${Number(summary.revenue).toFixed(2)}`);
    doc.moveDown(1);

    // Table header
    const startX = 40;
    let y = doc.y;
    doc.fontSize(9).font("Helvetica-Bold").fillColor("#333");
    doc.text("Order #", startX, y, { width: 50 });
    doc.text("Customer", startX + 55, y, { width: 140 });
    doc.text("Amount", startX + 200, y, { width: 80 });
    doc.text("Status", startX + 285, y, { width: 80 });
    doc.text("Date", startX + 370, y, { width: 120 });

    y += 15;
    doc.moveTo(startX, y).lineTo(startX + 490, y).strokeColor("#ddd").stroke();
    y += 5;

    // Table rows
    doc.font("Helvetica").fillColor("#000");
    for (const o of orders) {
      if (y > 750) { doc.addPage(); y = 40; }
      doc.fontSize(8);
      doc.text(String(o.id), startX, y, { width: 50 });
      doc.text(o.customer, startX + 55, y, { width: 140 });
      doc.text(`R${Number(o.total).toFixed(2)}`, startX + 200, y, { width: 80 });
      doc.text(o.status, startX + 285, y, { width: 80 });
      doc.text(new Date(o.created_at).toLocaleDateString(), startX + 370, y, { width: 120 });
      y += 16;
    }

    doc.end();
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// Donations report - CSV
router.get("/reports/donations/csv", authenticate, authorize("admin"), (req, res) => {
  try {
    const donations = db.queryAll("SELECT id, donor_name, email, academy, amount, payment_status, is_recurring, message, created_at FROM donations ORDER BY created_at DESC");

    const fields = ["id", "donor_name", "email", "amount", "payment_status", "is_recurring", "message", "created_at"];
    const parser = new CsvParser({ fields });
    const csv = parser.parse(donations);

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", "attachment; filename=donations-report.csv");
    res.send(csv);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// Donations report - PDF
router.get("/reports/donations/pdf", authenticate, authorize("admin"), (req, res) => {
  try {
    const donations = db.queryAll("SELECT id, donor_name, amount, payment_status, created_at FROM donations ORDER BY created_at DESC");
    const summary = db.queryGet("SELECT COUNT(*) as count, COALESCE(SUM(amount),0) as total FROM donations WHERE payment_status = 'completed'");

    const doc = new PDFDocument({ margin: 40, size: "A4" });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=donations-report.pdf");
    doc.pipe(res);

    doc.fontSize(22).font("Helvetica-Bold").text("Village NetAcad", { align: "center" });
    doc.fontSize(14).font("Helvetica").text("Donations Report", { align: "center" });
    doc.fontSize(10).fillColor("#666").text(`Generated: ${new Date().toLocaleString()}`, { align: "center" });
    doc.moveDown(1.5);

    doc.fontSize(12).fillColor("#000").font("Helvetica-Bold").text("Summary");
    doc.fontSize(10).font("Helvetica");
    doc.text(`Total Donations: ${summary.count}`);
    doc.text(`Total Amount: R${Number(summary.total).toFixed(2)}`);
    doc.moveDown(1);

    const startX = 40;
    let y = doc.y;
    doc.fontSize(9).font("Helvetica-Bold").fillColor("#333");
    doc.text("#", startX, y, { width: 40 });
    doc.text("Donor", startX + 45, y, { width: 160 });
    doc.text("Amount", startX + 210, y, { width: 80 });
    doc.text("Status", startX + 295, y, { width: 80 });
    doc.text("Date", startX + 380, y, { width: 120 });

    y += 15;
    doc.moveTo(startX, y).lineTo(startX + 490, y).strokeColor("#ddd").stroke();
    y += 5;

    doc.font("Helvetica").fillColor("#000");
    for (const d of donations) {
      if (y > 750) { doc.addPage(); y = 40; }
      doc.fontSize(8);
      doc.text(String(d.id), startX, y, { width: 40 });
      doc.text(d.donor_name, startX + 45, y, { width: 160 });
      doc.text(`R${Number(d.amount).toFixed(2)}`, startX + 210, y, { width: 80 });
      doc.text(d.payment_status, startX + 295, y, { width: 80 });
      doc.text(new Date(d.created_at).toLocaleDateString(), startX + 380, y, { width: 120 });
      y += 16;
    }

    doc.end();
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
