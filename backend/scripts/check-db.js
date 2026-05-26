/**
 * Database health check. Run: node scripts/check-db.js
 */
const path = require("path");
const fs = require("fs");

const dbPath = path.join(__dirname, "..", "database.sqlite");

console.log("=== Database check ===\n");
console.log("Node version:", process.version);
console.log("DB file:", dbPath);
console.log("Exists:", fs.existsSync(dbPath));
if (fs.existsSync(dbPath)) {
  console.log("Size:", fs.statSync(dbPath).size, "bytes");
}

let db;
try {
  db = require("../src/config/db");
  console.log("\nConnection: OK (better-sqlite3 loaded)");
} catch (err) {
  console.error("\nConnection: FAILED");
  console.error("Error:", err.message);
  if (err.message.includes("NODE_MODULE_VERSION")) {
    console.error("\nFix: stop the backend (Ctrl+C), then run:");
    console.error("  npm rebuild better-sqlite3");
    console.error("  npm run db:migrate");
  }
  process.exit(1);
}

const tables = db.queryAll("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name");
console.log("\nTables:", tables.length ? tables.map((t) => t.name).join(", ") : "(none — run npm run db:migrate)");

const counts = {};
for (const { name } of tables) {
  counts[name] = db.queryGet(`SELECT COUNT(*) AS n FROM ${name}`).n;
}
console.log("\nRow counts:");
for (const [table, n] of Object.entries(counts)) {
  console.log(`  ${table}: ${n}`);
}

if (counts.users !== undefined) {
  const sample = db.queryAll("SELECT id, email, role FROM users LIMIT 3");
  if (sample.length) console.log("\nSample users:", sample);
}

console.log("\n=== Done ===");
