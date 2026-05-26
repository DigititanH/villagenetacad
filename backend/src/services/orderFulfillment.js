const db = require("../config/db");
const sendEmail = require("../config/email");
const { SITE_EMAIL } = require("../config/site");

/** Complete a paid order: stock, commission, cart, emails */
function fulfillOrder(orderId) {
  const order = db.queryGet("SELECT * FROM orders WHERE id = ?", [orderId]);
  if (!order) throw new Error("Order not found");
  if (order.payment_status === "paid") return order;

  const items = db.queryAll(
    `SELECT oi.*, p.name, p.stock FROM order_items oi
     JOIN products p ON p.id = oi.product_id WHERE oi.order_id = ?`,
    [orderId]
  );

  for (const item of items) {
    if (item.stock < item.quantity) {
      throw new Error(`${item.name} is out of stock`);
    }
    db.queryRun("UPDATE products SET stock = stock - ? WHERE id = ?", [item.quantity, item.product_id]);
  }

  const code = order.referral_code?.trim();
  if (code) {
    const reseller = db.queryGet(
      "SELECT id, commission_rate FROM reseller_profiles WHERE referral_code = ? AND status = 'approved'",
      [code]
    );
    if (reseller) {
      const existing = db.queryGet("SELECT id FROM commissions WHERE order_id = ?", [orderId]);
      if (!existing) {
        const commission = order.total * (reseller.commission_rate / 100);
        db.queryRun("INSERT INTO commissions (reseller_id, order_id, amount) VALUES (?, ?, ?)", [
          reseller.id,
          orderId,
          commission,
        ]);
        db.queryRun(
          "UPDATE reseller_profiles SET wallet_balance = wallet_balance + ?, total_earned = total_earned + ? WHERE id = ?",
          [commission, commission, reseller.id]
        );
      }
    }
  }

  db.queryRun(
    "UPDATE orders SET payment_status = 'paid', status = 'processing', updated_at = datetime('now') WHERE id = ?",
    [orderId]
  );
  db.queryRun("DELETE FROM cart WHERE user_id = ?", [order.user_id]);

  const user = db.queryGet("SELECT name, email FROM users WHERE id = ?", [order.user_id]);
  if (user) {
    const itemsList = items
      .map((i) => `${i.name} × ${i.quantity} (R${(i.price * i.quantity).toFixed(2)})`)
      .join("<br>");
    sendEmail({
      to: SITE_EMAIL,
      replyTo: user.email,
      subject: `Paid order #${orderId} — R${Number(order.total).toFixed(2)}`,
      html: `<p><strong>Customer:</strong> ${user.name} (${user.email})</p>
        <p><strong>Order ID:</strong> ${orderId}</p>
        <p><strong>Total paid:</strong> R${Number(order.total).toFixed(2)}</p>
        <p><strong>Items:</strong><br>${itemsList}</p>`,
    });
  }

  return db.queryGet("SELECT * FROM orders WHERE id = ?", [orderId]);
}

module.exports = { fulfillOrder };
