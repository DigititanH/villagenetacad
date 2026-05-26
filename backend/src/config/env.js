const { isPayFastConfigured } = require("./payfast");
const { getNotifyUrl, isNotifyUrlLocal } = require("./payfast");

const isProduction = () => process.env.NODE_ENV === "production";

const validateProductionEnv = () => {
  if (!isProduction()) return;

  const errors = [];
  const warnings = [];

  if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
    errors.push("JWT_SECRET must be set and at least 32 characters");
  }
  if (/CHANGE_ME|your_jwt|placeholder/i.test(process.env.JWT_SECRET || "")) {
    errors.push("JWT_SECRET must be a strong random value (not a placeholder)");
  }

  if (!process.env.CLIENT_URL) {
    errors.push("CLIENT_URL must be your public site URL (e.g. https://villagenetacad.co.za)");
  }

  if (isPayFastConfigured()) {
    if (!process.env.API_URL) {
      errors.push("API_URL must be your public HTTPS API URL when PayFast is enabled");
    }
    const notify = getNotifyUrl();
    if (isNotifyUrlLocal(notify)) {
      errors.push(
        "PayFast ITN requires a public HTTPS notify URL — set PAYFAST_NOTIFY_URL or API_URL to your live domain"
      );
    }
    if (process.env.PAYFAST_SANDBOX !== "false") {
      warnings.push("PAYFAST_SANDBOX is not false — you are using PayFast sandbox, not live payments");
    }
  }

  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
    warnings.push("SMTP is not configured — contact forms and emails will not send");
  }

  for (const w of warnings) console.warn(`[env] ${w}`);
  if (errors.length) {
    console.error("[env] Production configuration errors:");
    errors.forEach((e) => console.error(`  - ${e}`));
    process.exit(1);
  }
};

module.exports = { isProduction, validateProductionEnv };
