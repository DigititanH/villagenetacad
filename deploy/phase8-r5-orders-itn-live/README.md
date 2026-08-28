# Phase 8 — R5 paid-order fix (My Orders + ITN + wallets)

**Live API tree only:** `public_html/backend-php/`

## Symptoms this pack fixes

1. **My Orders** showed only order # / status / amount — no product name or image (`order_items` has no name/image; API must JOIN `products`).
2. **Wallets stayed R0** after PayFast COMPLETE — ITN never called `OrderFulfillment::fulfill()`, or live `OrderFulfillment.php` is missing the 53/26/21 credit logic.

## Upload (cPanel File Manager / FTP)

Overwrite these under **`public_html/backend-php/`**:

| Local file | Live path |
|------------|-----------|
| `OrdersController.php` | `controllers/OrdersController.php` |
| `PayfastController.php` | `controllers/PayfastController.php` |
| `Payfast.php` | `lib/Payfast.php` |
| `OrderFulfillment.php` | `lib/OrderFulfillment.php` |

Do **not** touch `public/payfast/notify.php` if it already bootstraps the API and calls `PayfastController::notify()`.

## After upload — diagnose this R5 payment (phpMyAdmin)

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

| Result | Meaning |
|--------|---------|
| `payment_status = pending` | PayFast took money but ITN did not fulfill — use recover script below |
| `payment_status = paid` but wallets still 0 | `referral_code` blank, or old `OrderFulfillment` — re-upload fulfill then recover once |
| `referral_code` NULL/empty | No commission possible for that order |

### Recover this R5 payment (after uploading `OrderFulfillment.php`)

Create `public_html/backend-php/public/_fulfill_once.php`:

```php
<?php
require_once dirname(__DIR__) . '/bootstrap.php';
$id = (int) ($_GET['id'] ?? 0);
if ($id < 1) { http_response_code(400); echo 'id required'; exit; }
$order = Database::queryGet('SELECT id, payment_status, total, referral_code FROM orders WHERE id = ?', [$id]);
if (!$order) { http_response_code(404); echo 'not found'; exit; }

if ($order['payment_status'] !== 'paid') {
    OrderFulfillment::fulfill($id);
} else {
    OrderFulfillment::ensureCommissions($id);
}

$after = Database::queryGet('SELECT id, payment_status, status, referral_code FROM orders WHERE id = ?', [$id]);
$comms = Database::queryAll('SELECT * FROM commissions WHERE order_id = ?', [$id]);
$wallets = Database::queryAll(
    "SELECT id, referral_code, wallet_balance, total_earned FROM reseller_profiles
     WHERE referral_code IN ('VNA-B-067FA503', 'VNA-C-3D1342F6')"
);
header('Content-Type: application/json');
echo json_encode(['before' => $order, 'after' => $after, 'commissions' => $comms, 'wallets' => $wallets]);
```

Visit once: `https://villagenetacad.co.za/_fulfill_once.php?id=<ORDER_ID>`  
Then **delete** `_fulfill_once.php`.

Expect on a R5 affiliated sale (`referral_code = VNA-B-067FA503`, academy Nkuna Centre): seller ≈ **R2.65**, centre ≈ **R1.30**.

## My Orders (name + image)

Only `OrdersController.php` is required for product name/image. After overwrite, reopen **Profile → Orders** (pull to refresh / leave and re-enter). List and detail both need `name` + `image` from the JOIN.
