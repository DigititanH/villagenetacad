const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config({
  override: process.env.NODE_ENV !== "production",
});

const { validateProductionEnv } = require("./config/env");
const { getAllowedOrigins } = require("./config/client");
const { getUploadsDir, ensureDir } = require("./config/paths");

validateProductionEnv();

const app = express();
const isProduction = process.env.NODE_ENV === "production";

if (isProduction) {
  app.set("trust proxy", 1);
}

const uploadsDir = getUploadsDir();
ensureDir(uploadsDir);

const allowedOrigins = getAllowedOrigins();
app.use(cors({ origin: isProduction ? allowedOrigins : true, credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static(uploadsDir));

app.use("/api/auth", require("./routes/auth"));
app.use("/api/products", require("./routes/products"));
app.use("/api/orders", require("./routes/orders"));
app.use("/api/donations", require("./routes/donations"));
app.use("/api/resellers", require("./routes/resellers"));
app.use("/api/admin", require("./routes/admin"));
app.use("/api/cart", require("./routes/cart"));
app.use("/api/reviews", require("./routes/reviews"));
app.use("/api/wishlist", require("./routes/wishlist"));
app.use("/api/contact", require("./routes/contact"));
const payfastRoutes = require("./routes/payfast");
app.use("/api/payfast", payfastRoutes);
app.post("/api/pay", payfastRoutes.handlePay);
app.use("/api/notifications", require("./routes/notifications"));
app.use("/api/search", require("./routes/search"));

app.get("/health", (req, res) =>
  res.json({
    status: "ok",
    env: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString(),
  })
);

const clientDist = path.join(__dirname, "..", "..", "frontend", "dist");
if (isProduction) {
  const fs = require("fs");
  if (fs.existsSync(clientDist)) {
    app.use(express.static(clientDist));
    app.get("*", (req, res, next) => {
      if (req.path.startsWith("/api") || req.path.startsWith("/uploads")) {
        return next();
      }
      res.sendFile(path.join(clientDist, "index.html"));
    });
  } else {
    console.warn("[server] frontend/dist not found — run: npm run build (in frontend/)");
  }
}

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: isProduction ? "Internal server error" : err.message });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Village NetAcad API on port ${PORT} [${process.env.NODE_ENV || "development"}]`);
});
