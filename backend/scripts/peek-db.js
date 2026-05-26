const Database = require("better-sqlite3");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const dbPath = process.env.DATABASE_PATH
  ? path.resolve(__dirname, "..", process.env.DATABASE_PATH)
  : path.join(__dirname, "..", "database.sqlite");

const db = new Database(dbPath, { readonly: true });

const tables = db
  .prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
  .all();

console.log("Database:", dbPath);
console.log("\nTables:");
for (const { name } of tables) {
  const { n } = db.prepare(`SELECT COUNT(*) as n FROM "${name}"`).get();
  console.log(`  - ${name}: ${n} row(s)`);
}

const samples = [
  ["users", "SELECT id, name, email, role, is_approved FROM users LIMIT 20"],
  ["products", "SELECT id, name, slug, price, stock FROM products LIMIT 10"],
  ["donations", "SELECT id, donor_name, amount, payment_status, academy, created_at FROM donations LIMIT 10"],
  ["orders", "SELECT id, user_id, total, status, payment_status FROM orders LIMIT 10"],
];

for (const [label, sql] of samples) {
  try {
    const rows = db.prepare(sql).all();
    if (rows.length) {
      console.log(`\n${label}:`);
      console.log(JSON.stringify(rows, null, 2));
    }
  } catch {
    /* table empty or missing */
  }
}

db.close();
