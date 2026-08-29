# Customer reviews + returns (live)

Branch: `cursor/customer-reviews-returns-09ad`

Enables **Leave a review** and **Request return** on delivered orders in the mobile app (was stubbed as “later phase”).

## What it does

| Action | API | Behaviour |
|--------|-----|-----------|
| Review | `POST /api/orders/{id}/review` | Stars + comment → `reviews` for each product on the order |
| Return | `POST /api/orders/{id}/return` | Within **7 days** of `delivered_at`; status → `return_requested`; emails customer + `SITE_EMAIL` |

Ops Admin → set status **delivered** now also sets `delivered_at` (drives the return window).

## Upload order (Afrihost)

1. **phpMyAdmin** → run `migration.sql` (backup DB first).  
   If “Duplicate column” / “Duplicate key” → that step already applied; continue.
2. Upload into `public_html/backend-php/`:
   - `controllers/OrdersController.php`
   - `routes/Router.php` (or `lib/Router.php` if that is where your live Router lives — match your layout)
   - `lib/AppEmails.php`
3. Sync Flutter: `INSTALL-REVIEWS-RETURNS.ps1` from `S:\WORK\VillageNetAcad`, then `flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za`

## Download (PowerShell → Downloads)

```powershell
cd $env:USERPROFILE\Downloads
$b = "cursor/customer-reviews-returns-09ad"
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@$b/deploy/phase-reviews-returns-live"
Invoke-WebRequest -Uri "$base/OrdersController.php" -OutFile "OrdersController.php"
Invoke-WebRequest -Uri "$base/Router.php" -OutFile "Router.php"
Invoke-WebRequest -Uri "$base/AppEmails.php" -OutFile "AppEmails.php"
Invoke-WebRequest -Uri "$base/migration.sql" -OutFile "migration.sql"
dir OrdersController.php, Router.php, AppEmails.php, migration.sql
```

## UAT

1. Pay a test order → Ops: **shipped** → **delivered** (do **not** cancel if you want review/return).
2. App → Profile → My orders → open order.
3. **Leave a review** (stars + text) → success; button becomes “You reviewed…”.
4. On another delivered order (or same if still in window): **Request return** → reason → customer email + ops email; status return requested.

Note: order **#19** was cancelled after deliver — review/return need a **delivered** (not cancelled) order.
