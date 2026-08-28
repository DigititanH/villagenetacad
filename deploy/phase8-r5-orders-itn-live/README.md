# Phase 8 — ITN auto-fulfill fix

**Why order 17 stayed `pending`:** PayFast hit `notify.php` (returned OK), but the controller required **both** a perfect local signature **and** PayFast host `VALID`. On Afrihost the host validate curl often fails, and/or passphrase encoding mismatches — so fulfill never ran.

**Fix:** accept **either** local signature **or** host VALID (still requires matching `merchant_id` + amount + COMPLETE).

## Upload (cPanel File Manager)

| File in this folder | Live path | Action |
|---------------------|-----------|--------|
| `PayfastController.php` | `public_html/backend-php/controllers/PayfastController.php` | **Overwrite** |
| — | `public_html/backend-php/public/payfast/notify.php` | **Leave as-is** (yours is already good) |

**Do not overwrite** `lib/Payfast.php` or `notify.php`.

## After upload — quick smoke test

1. Open (should still say OK):  
   `https://www.villagenetacad.co.za/payfast/notify.php`
2. Check log file:  
   `public_html/backend-php/payfast/payfast.log`  
   (created on first ITN / POST)

## UAT — next R5 paid order

1. Checkout with referral **`VNA-B-067FA503`**
2. Complete PayFast (real R5)
3. phpMyAdmin:

```sql
SELECT id, total, payment_status, referral_code
FROM orders ORDER BY id DESC LIMIT 3;

SELECT referral_code, wallet_balance, total_earned
FROM reseller_profiles
WHERE referral_code IN ('VNA-B-067FA503', 'VNA-C-3D1342F6');
```

**Pass:** new order becomes `paid` **without** `_fulfill_once.php`, seller +R2.65, centre +R1.30.

**Fail:** order stays `pending` → open `payfast.log` and paste the last lines here.

## Optional: Orders name/image

If My Orders still lacks product name/thumbnail, also upload `OrdersController.php` from this pack to  
`public_html/backend-php/controllers/OrdersController.php`.
