# Phase 10 — In-app notifications (no SMTP)

**Branch:** `cursor/phase8-ledger-clients-09ad`  
**Live tree:** `public_html/backend-php/`

## What it does
On **order paid** (PayFast ITN → fulfill) and **Ops order status** update:
- Buyer gets an in-app notice
- Attributed reseller gets “sale confirmed”
- Affiliated centre gets “centre share earned”
- Shown in app: **Profile → Notifications** (live `GET /api/notifications`)

No email / Gmail / SMTP.

## Upload (cPanel)

| File | Live path |
|------|-----------|
| `InAppNotifications.php` | `lib/InAppNotifications.php` |
| `OrderFulfillment.php` | `lib/OrderFulfillment.php` |
| `OrdersController.php` | `controllers/OrdersController.php` |

## phpMyAdmin

`notifications` table **already exists** on live — do **not** recreate it. Skip `notifications.sql` unless a fresh DB is missing the table.
## Backfill order 18 (optional one-time)

**First upload** `lib/InAppNotifications.php` (and the other two PHP files), or backfill will 500.

Use the safer script in this pack: `_notify_backfill_once.php`  
→ `public_html/backend-php/public/_notify_backfill_once.php`

Visit: `https://villagenetacad.co.za/_notify_backfill_once.php?id=18`  
Then **delete** the file. On failure it returns JSON with the real error (missing class / path / exception).

## App

```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE8-LEDGER.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

UAT: buyer Profile → Notifications sees payment confirmed; seller/centre see sale notices; Ops change order status → buyer sees order update.
