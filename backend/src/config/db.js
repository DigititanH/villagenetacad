const Database = require("better-sqlite3");
const { getDbPath, ensureDir } = require("./paths");

const dbPath = getDbPath();
ensureDir(require("path").dirname(dbPath));

const db = new Database(dbPath);

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

db.queryAll = (sql, params = []) => db.prepare(sql).all(...params);
db.queryRun = (sql, params = []) => db.prepare(sql).run(...params);
db.queryGet = (sql, params = []) => db.prepare(sql).get(...params);

module.exports = db;
