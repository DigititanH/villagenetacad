# Phase 7 / 8 — PayFast ITN (notify → fulfill)

**Status (28 Aug 2026): UAT PASSED** — live auto-fulfill works.

## What it is
After PayFast payment, ITN hits the server so orders mark as paid and `OrderFulfillment` credits wallets (53/26/21).

## Live URL (working)
`https://www.villagenetacad.co.za/payfast/notify.php`  
→ `public_html/backend-php/public/payfast/notify.php` → `PayfastController::notify()`

Do **not** use the dead stub under `backend-php/payfast/notify` (no `.php`).

## UAT PASSED (28 Aug 2026)

| Check | Result |
|--------|--------|
| Order **17** | Paid via manual recover first (pre-fix); proved 53/26/21 |
| Order **18** | **Auto** `paid` after PayFast (no `_fulfill_once`) |
| Referral | `VNA-B-067FA503` (affiliated Nkuna Centre) |
| Seller wallet | R2.65 then **R5.30** after order 18 |
| Centre `VNA-C-3D1342F6` | R1.30 then **R2.60** |
| Digititan ledger | 21% commission row (no wallet) |

### Fix that made auto-fulfill work
Live `notify()` required **both** local signature **and** host `VALID`. Host validate often fails on Afrihost.  
Updated `PayfastController.php`: accept **either** local sig **or** host VALID; still require matching `merchant_id` + amount + `COMPLETE`.

**Overwrite on live:** `controllers/PayfastController.php` only.  
**Leave alone:** `public/payfast/notify.php`, `lib/Payfast.php`.

Pack: `deploy/phase8-r5-orders-itn-live/`

## Optional later
- Prefer `/api/payfast/notify` in `.env` if you want one canonical path (legacy `notify.php` can keep forwarding).
- SMTP order emails still best-effort / parked.
