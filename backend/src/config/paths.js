const path = require("path");
const fs = require("fs");

const backendRoot = path.join(__dirname, "..", "..");

const getDbPath = () => {
  const custom = process.env.DATABASE_PATH?.trim();
  if (custom) return path.resolve(custom);
  return path.join(backendRoot, "database.sqlite");
};

const getUploadsDir = () => {
  const custom = process.env.UPLOADS_DIR?.trim();
  if (custom) return path.resolve(custom);
  return path.join(backendRoot, "uploads");
};

const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
};

module.exports = { backendRoot, getDbPath, getUploadsDir, ensureDir };
