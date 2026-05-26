const crypto = require("crypto");

const isSandbox = process.env.PAYFAST_SANDBOX !== "false";

const config = {
  merchantId: process.env.PAYFAST_MERCHANT_ID || "",
  merchantKey: process.env.PAYFAST_MERCHANT_KEY || "",
  passphrase: (process.env.PAYFAST_PASSPHRASE || "").trim(),
  sandbox: isSandbox,
  processUrl: isSandbox
    ? "https://sandbox.payfast.co.za/eng/process"
    : "https://www.payfast.co.za/eng/process",
  validateUrl: isSandbox
    ? "https://sandbox.payfast.co.za/eng/query/validate"
    : "https://www.payfast.co.za/eng/query/validate",
};

/** PayFast attribute order for signature (custom integration docs) */
const FIELD_ORDER = [
  "merchant_id",
  "merchant_key",
  "return_url",
  "cancel_url",
  "notify_url",
  "name_first",
  "name_last",
  "email_address",
  "cell_number",
  "m_payment_id",
  "amount",
  "item_name",
  "item_description",
  "custom_int1",
  "custom_int2",
  "custom_int3",
  "custom_int4",
  "custom_int5",
  "custom_str1",
  "custom_str2",
  "custom_str3",
  "custom_str4",
  "custom_str5",
  "email_confirmation",
  "confirmation_address",
  "payment_method",
];

const isPayFastConfigured = () => Boolean(config.merchantId && config.merchantKey);

/** Match PHP urlencode() used by PayFast */
const pfEncode = (value) =>
  encodeURIComponent(String(value).trim())
    .replace(/%20/g, "+")
    .replace(/!/g, "%21")
    .replace(/'/g, "%27")
    .replace(/\(/g, "%28")
    .replace(/\)/g, "%29")
    .replace(/\*/g, "%2A");

const buildSignatureString = (data, passphrase = config.passphrase) => {
  const payload = {};
  for (const [key, val] of Object.entries(data)) {
    if (key === "signature") continue;
    if (val === undefined || val === null) continue;
    const trimmed = String(val).trim();
    if (trimmed === "") continue;
    payload[key] = trimmed;
  }

  const orderedKeys = [
    ...FIELD_ORDER.filter((key) => payload[key] !== undefined),
    ...Object.keys(payload)
      .filter((key) => !FIELD_ORDER.includes(key))
      .sort(),
  ];

  let paramString = orderedKeys.map((key) => `${key}=${pfEncode(payload[key])}`).join("&");

  if (passphrase) {
    paramString += `&passphrase=${pfEncode(passphrase)}`;
  }
  return paramString;
};

const generateSignature = (data, passphrase = config.passphrase) =>
  crypto.createHash("md5").update(buildSignatureString(data, passphrase)).digest("hex");

const formatAmount = (amount) => {
  const n = Number(amount);
  if (!Number.isFinite(n) || n < 5) {
    throw new Error("PayFast requires a minimum amount of R5.00");
  }
  return n.toFixed(2);
};

const getApiBaseUrl = () => {
  const api = process.env.API_URL?.replace(/\/$/, "");
  if (api && !/your-public-api|example\.com|placeholder/i.test(api)) {
    return api;
  }
  return `http://localhost:${process.env.PORT || 5000}`;
};

const { getClientUrl } = require("./client");

const getNotifyUrl = () => {
  const custom = process.env.PAYFAST_NOTIFY_URL?.trim();
  if (custom) return custom.replace(/\/$/, "");
  return `${getApiBaseUrl()}/api/payfast/notify`;
};

const isNotifyUrlLocal = (url) => /localhost|127\.0\.0\.1|0\.0\.0\.0/i.test(url);

const splitName = (fullName = "") => {
  const parts = String(fullName).trim().split(/\s+/);
  return {
    first: parts[0] || "Customer",
    last: parts.length > 1 ? parts.slice(1).join(" ") : null,
  };
};

const buildPaymentPayload = ({
  amount,
  itemName,
  paymentId,
  email,
  name,
  returnPath,
  cancelPath,
  returnUrl,
  cancelUrl,
}) => {
  const { first, last } = splitName(name);
  const notifyUrl = getNotifyUrl();
  const clientUrl = getClientUrl();

  const paymentData = {
    merchant_id: config.merchantId,
    merchant_key: config.merchantKey,
    return_url: returnUrl || `${clientUrl}${returnPath || "/payment/success"}`,
    cancel_url: cancelUrl || `${clientUrl}${cancelPath || "/payment/cancel"}`,
    notify_url: notifyUrl,
    name_first: first,
    email_address: String(email).trim(),
    m_payment_id: paymentId || `pay-${Date.now()}`,
    amount: formatAmount(amount),
    item_name: String(itemName).replace(/#/g, "").slice(0, 100),
  };

  if (last) {
    paymentData.name_last = last;
  }

  const signature = generateSignature(paymentData);

  return {
    ...paymentData,
    signature,
  };
};

/** POST a probe payment to PayFast and return parsed error (dev diagnostics) */
const probePayFastCredentials = () =>
  new Promise((resolve) => {
    const fields = buildPaymentPayload({
      amount: 50,
      itemName: "Credential probe",
      paymentId: `probe-${Date.now()}`,
      email: "probe@test.com",
      name: "Probe",
      returnPath: "/payment/success",
      cancelPath: "/payment/cancel",
    });

    const body = new URLSearchParams(
      Object.entries(fields).map(([k, v]) => [k, String(v)])
    ).toString();

    const url = new URL(config.processUrl);
    const lib = url.protocol === "https:" ? require("https") : require("http");

    const req = lib.request(
      {
        hostname: url.hostname,
        path: url.pathname,
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Content-Length": Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          const plain = data.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
          const invalidMerchant = /invalid merchant id/i.test(plain);
          const missingKey = /merchant key.*required/i.test(plain);
          const signatureError = /signature/i.test(plain);
          const ok = res.statusCode >= 300 && res.statusCode < 400;

          resolve({
            http_status: res.statusCode,
            credentials_valid: ok || (!invalidMerchant && !missingKey && !signatureError && res.statusCode !== 400),
            payfast_message: plain.slice(0, 280) || null,
            invalid_merchant_id: invalidMerchant,
            merchant_key_required: missingKey,
            signature_mismatch: signatureError,
          });
        });
      }
    );

    req.on("error", (err) => resolve({ error: err.message }));
    req.write(body);
    req.end();
  });

module.exports = {
  config,
  isPayFastConfigured,
  generateSignature,
  buildSignatureString,
  formatAmount,
  getApiBaseUrl,
  getClientUrl,
  getNotifyUrl,
  isNotifyUrlLocal,
  buildPaymentPayload,
  probePayFastCredentials,
};
