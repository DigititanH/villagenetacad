/** Primary public site URL (first entry if CLIENT_URL is comma-separated). */
const getClientUrl = () => {
  const raw = process.env.CLIENT_URL || "http://localhost:5173";
  const primary = raw.split(",")[0].trim();
  return primary.replace(/\/$/, "");
};

const getAllowedOrigins = () => {
  const raw = process.env.CLIENT_URL;
  if (!raw) return ["http://localhost:5173"];
  return raw.split(",").map((s) => s.trim()).filter(Boolean);
};

module.exports = { getClientUrl, getAllowedOrigins };
