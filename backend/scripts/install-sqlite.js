try {
  require("better-sqlite3");
} catch {
  const { execSync } = require("child_process");
  const path = require("path");
  const prebuild = path.join(__dirname, "../node_modules/prebuild-install/bin.js");
  console.log("Installing better-sqlite3 native binary...");
  execSync(`node "${prebuild}"`, { stdio: "inherit", cwd: path.join(__dirname, "../node_modules/better-sqlite3") });
}
