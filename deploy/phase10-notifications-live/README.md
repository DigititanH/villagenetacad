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

Create `public_html/backend-php/public/_notify_backfill_once.php`:

```php
<?php
require_once dirname(__DIR__) . '/bootstrap.php';
$id = (int) ($_GET['id'] ?? 18);
$order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$id]);
if (!$order) { http_response_code(404); echo 'not found'; exit; }
$items = Database::queryAll(
  'SELECT oi.*, p.name FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id = ?',
  [$id]
);
InAppNotifications::orderPaid($order, $items);
$rows = Database::queryAll('SELECT id, user_id, title, message FROM notifications ORDER BY id DESC LIMIT 10');
header('Content-Type: application/json');
echo json_encode($rows, JSON_PRETTY_PRINT);
```

Visit once: `https://villagenetacad.co.za/_notify_backfill_once.php?id=18`  
Then **delete** the file.

## App

```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE8-LEDGER.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

UAT: buyer Profile → Notifications sees payment confirmed; seller/centre see sale notices; Ops change order status → buyer sees order update.
