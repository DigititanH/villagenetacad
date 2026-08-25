# UAT — website pay path (sandbox)

Goal: prove app cart → website cart → PayFast **sandbox** → my orders.

## 1. Admin: create a test product (website)

Log in as admin on `https://villagenetacad.co.za` → **Admin → Products → Create Product**.

Suggested test SKU:

| Field | Example |
|-------|---------|
| Name | `Laptop (TESTING)` |
| Description | `This is for testing purchases` |
| Price | e.g. `50` (above PayFast min if enforced) |
| Category | Must be an existing one: `bags`, `books`, `caps`, `hoodies`, `stickers`, `t-shirts` |
| Stock | `10` (or enough to buy) |
| Sizes | optional (XS–XXL) |
| Colors | e.g. `Black, White` |
| Image | optional but better for app Store tiles |
| Active | **on** |

Save, then confirm `GET /api/products` returns the item (not `products: []`).

**Note:** Mobile Admin → Add product is **dummy only** — it does not write to MySQL.

## 2. Ops: PayFast **sandbox** on the server

Use **test** merchant keys from [PayFast sandbox](https://sandbox.payfast.co.za) — **not** production keys.

On the host that serves `backend-php`, set in `.env` (never commit real values):

```env
PAYFAST_MERCHANT_ID=<sandbox merchant id>
PAYFAST_MERCHANT_KEY=<sandbox merchant key>
PAYFAST_SANDBOX=true
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
```

- Leave passphrase empty unless sandbox Integration → Security has one set (then match exactly).
- Restart PHP / clear opcache if needed.
- Check `GET https://villagenetacad.co.za/api/payfast/status` → `"configured": true`, `"sandbox": true`.

Website Admin login alone does **not** set these — someone with server/env access must.

## 3. App UAT steps

```powershell
cd S:\WORK\VillageNetAcad
# INSTALL-PHASE6 if needed, then:
cd mobile
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

1. Sign in with the **same** customer account as the website.  
2. Store → add **Laptop (TESTING)** (live product, not sample).  
3. Cart → **Complete on website**.  
4. **Log in on the website first** (same browser), then open cart if needed.  
5. **Proceed to Checkout** → PayFast sandbox → complete test payment.  
6. App → Profile → **My orders** → order appears.

## 4. ASC academy registration (parity)

App **Academies → register org** opens the same Microsoft ASC form as the website  
(`AppConfig.ascRegistrationFormUrl`). No separate in-app field set.
