const Database = require("better-sqlite3");
const bcrypt = require("bcryptjs");
const { getDbPath, ensureDir } = require("../config/paths");

const dbPath = getDbPath();
ensureDir(require("path").dirname(dbPath));
const db = new Database(dbPath);

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

const schema = `
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT CHECK(role IN ('admin','reseller','customer')) DEFAULT 'customer',
  avatar TEXT DEFAULT NULL,
  phone TEXT DEFAULT NULL,
  is_verified INTEGER DEFAULT 0,
  is_approved TEXT CHECK(is_approved IN ('pending','approved','declined')) DEFAULT 'pending',
  verification_token TEXT DEFAULT NULL,
  reset_token TEXT DEFAULT NULL,
  reset_token_expires TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  image TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  compare_price REAL DEFAULT NULL,
  category_id INTEGER,
  image TEXT DEFAULT NULL,
  images TEXT DEFAULT NULL,
  stock INTEGER DEFAULT 0,
  sizes TEXT DEFAULT NULL,
  colors TEXT DEFAULT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  total REAL NOT NULL,
  status TEXT CHECK(status IN ('pending','processing','shipped','delivered','cancelled')) DEFAULT 'pending',
  shipping_address TEXT NOT NULL,
  payment_intent_id TEXT DEFAULT NULL,
  payment_status TEXT CHECK(payment_status IN ('pending','paid','failed','refunded')) DEFAULT 'pending',
  referral_code TEXT DEFAULT NULL,
  tracking_number TEXT DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  price REAL NOT NULL,
  size TEXT DEFAULT NULL,
  color TEXT DEFAULT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  size TEXT DEFAULT NULL,
  color TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS wishlist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE (user_id, product_id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS donations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER DEFAULT NULL,
  donor_name TEXT DEFAULT 'Anonymous',
  email TEXT DEFAULT NULL,
  amount REAL NOT NULL,
  is_recurring INTEGER DEFAULT 0,
  recurring_interval TEXT CHECK(recurring_interval IN ('monthly','yearly',NULL)) DEFAULT NULL,
  payment_intent_id TEXT DEFAULT NULL,
  payment_status TEXT CHECK(payment_status IN ('pending','completed','failed')) DEFAULT 'pending',
  message TEXT DEFAULT NULL,
  is_anonymous INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS reseller_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER UNIQUE NOT NULL,
  referral_code TEXT UNIQUE NOT NULL,
  commission_rate REAL DEFAULT 10.00,
  status TEXT CHECK(status IN ('pending','approved','rejected','suspended')) DEFAULT 'pending',
  wallet_balance REAL DEFAULT 0.00,
  total_earned REAL DEFAULT 0.00,
  bio TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS commissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  reseller_id INTEGER NOT NULL,
  order_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  status TEXT CHECK(status IN ('pending','paid')) DEFAULT 'pending',
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (reseller_id) REFERENCES reseller_profiles(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS withdrawals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  reseller_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  status TEXT CHECK(status IN ('pending','approved','rejected','completed')) DEFAULT 'pending',
  bank_details TEXT DEFAULT NULL,
  processed_at TEXT DEFAULT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (reseller_id) REFERENCES reseller_profiles(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  type TEXT CHECK(type IN ('info','success','warning','error')) DEFAULT 'info',
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT DEFAULT NULL,
  message TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);
`;

try {
  const statements = schema.split(";").map((s) => s.trim()).filter(Boolean);
  for (const stmt of statements) {
    db.exec(stmt);
  }

  // Seed admin user
  const existing = db.prepare("SELECT id FROM users WHERE email = ?").get("admin@villagenetacad.com");
  if (!existing) {
    const hash = bcrypt.hashSync("Admin123!", 12);
    db.prepare(
      "INSERT INTO users (name, email, password, role, is_verified, is_approved) VALUES (?, ?, ?, ?, ?, ?)"
    ).run("Admin", "admin@villagenetacad.com", hash, "admin", 1, "approved");
  }

  // Seed categories
  const cats = [
    ["T-Shirts", "t-shirts"],
    ["Hoodies", "hoodies"],
    ["Caps", "caps"],
    ["Stickers", "stickers"],
    ["Bags", "bags"],
    ["Books", "books"],
  ];
  try {
    db.exec("ALTER TABLE orders ADD COLUMN referral_code TEXT DEFAULT NULL");
  } catch {
    /* column may already exist */
  }

  try {
    db.exec("ALTER TABLE reseller_profiles ADD COLUMN academy TEXT DEFAULT NULL");
  } catch {
    /* column may already exist */
  }

  try {
    db.exec("ALTER TABLE donations ADD COLUMN academy TEXT DEFAULT NULL");
  } catch {
    /* column may already exist */
  }

  const insertCat = db.prepare("INSERT OR IGNORE INTO categories (name, slug) VALUES (?, ?)");
  for (const [name, slug] of cats) {
    insertCat.run(name, slug);
  }

  console.log("Database migrated and seeded successfully!");
} catch (err) {
  console.error("Migration failed:", err);
  process.exit(1);
} finally {
  db.close();
}
