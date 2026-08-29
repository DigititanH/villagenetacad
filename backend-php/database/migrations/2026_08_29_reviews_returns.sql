-- Customer reviews + returns (additive). Backup DB first.
-- Safe to re-run: duplicate column / duplicate key errors can be ignored.

-- 1) delivered_at for 7-day return window
ALTER TABLE orders
  ADD COLUMN delivered_at DATETIME NULL DEFAULT NULL AFTER tracking_number;

-- 2) Allow return_requested status (keeps existing values)
ALTER TABLE orders
  MODIFY COLUMN status ENUM(
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'return_requested'
  ) DEFAULT 'pending';

-- 3) Backfill delivered_at for orders already marked delivered
UPDATE orders
SET delivered_at = COALESCE(updated_at, created_at)
WHERE status IN ('delivered', 'return_requested')
  AND delivered_at IS NULL;

-- 4) Returns table
CREATE TABLE IF NOT EXISTS order_returns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  user_id INT NOT NULL,
  reason TEXT NOT NULL,
  status ENUM('requested','approved','rejected','completed') DEFAULT 'requested',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_order_return (order_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES registrations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5) One review per user per product (ignore if already exists)
ALTER TABLE reviews
  ADD UNIQUE KEY uniq_review_user_product (user_id, product_id);
