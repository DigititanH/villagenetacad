# Phase 8 — R5 paid-order fix (My Orders + ITN)

**Live API tree only:** `public_html/backend-php/`

## Symptoms this pack fixes

1. **My Orders** showed only order # / status / amount — no product name or image (API did not JOIN `products`; list UI ignored items).
2. **Wallets stayed R0** after PayFast COMPLETE — ITN often failed local signature (FIELD_ORDER vs posted order) and never called `OrderFulfillment::fulfill()`.

## Upload (cPanel File Manager / FTP)

Overwrite these under **`public_html/backend-php/`**:

| Local file | Live path |
|------------|-----------|
| `OrdersController.php` | `controllers/OrdersController.php` |
| `PayfastController.php` | `controllers/PayfastController.php` |
| `Payfast.php` | `lib/Payfast.php` |

Optional (only if `https://www.villagenetacad.co.za/payfast/notify.php` is still a stub):

| Local file | Live path |
|------------|-----------|
| `notify.php` | `public_html/payfast/notify.php` (sibling of `backend-php`, **not** under `backend-php/payfast/`) |

## After upload — check this R5 order (phpMyAdmin)

```sql
SELECT id, user_id, total, payment_status, status, referral_code, created_at
FROM orders
ORDER BY id DESC
LIMIT 5;

SELECT * FROM commissions WHERE order_id = <ORDER_ID>;

SELECT id, referral_code, wallet_balance, total_earned
FROM reseller_profiles
WHERE referral_code IN ('VNA-B-067FA503', 'VNA-C-3D1342F6');
```

### If `payment_status` is still `pending` (PayFast took R5)

One-time recover on the server (File Manager → temporary PHP, then delete):

Create `public_html/backend-php/public/_fulfill_once.php`:

```php
<?php
require_once dirname(__DIR__) . '/bootstrap.php';
$id = (int) ($_GET['id'] ?? 0);
if ($id < 1) { http_response_code(400); echo 'id required'; exit; }
$order = Database::queryGet('SELECT id, payment_status, total, referral_code FROM orders WHERE id = ?', [$id]);
if (!$order) { http_response_code(404); echo 'not found'; exit; }
if ($order['payment_status'] === 'paid') { echo 'already paid'; exit; }
OrderFulfillment::fulfill($id);
$after = Database::queryGet('SELECT id, payment_status, status FROM orders WHERE id = ?', [$id]);
header('Content-Type: application/json');
echo json_encode(['before' => $order, 'after' => $after]);
```

Visit once:

`https://villagenetacad.co.za/_fulfill_once.php?id=<ORDER_ID>`

Then **delete** `_fulfill_once.php`.

Expect wallets ≈ **R2.65** (seller 53%) and **R1.30** (centre 26%) on a R5 affiliated sale, plus a digititan commission row (no wallet).

## Mobile app

Re-run `INSTALL-PHASE8-LEDGER.ps1` from branch `cursor/phase8-ledger-clients-09ad`, then:

```text
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

My Orders list + detail should show product name and thumbnail.
