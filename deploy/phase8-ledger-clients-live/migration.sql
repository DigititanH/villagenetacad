-- Phase 8 slice 2: clients CRM + multi-party commission party column.
-- Run once in phpMyAdmin on the live Digititan DB (public_html/backend-php MySQL).

CREATE TABLE IF NOT EXISTS reseller_clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  reseller_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  product_interest VARCHAR(255) DEFAULT NULL,
  status ENUM('pending','confirmed','bought','did_not_buy') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (reseller_id) REFERENCES reseller_profiles(id) ON DELETE CASCADE,
  INDEX idx_reseller_clients_reseller (reseller_id),
  INDEX idx_reseller_clients_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Safe if column already exists: run the ADD only once (ignore duplicate-column error).
ALTER TABLE commissions
  ADD COLUMN party ENUM('seller','centre','digititan') NOT NULL DEFAULT 'seller' AFTER amount,
  ADD COLUMN share_percent DECIMAL(5,2) DEFAULT NULL AFTER party;
