<?php
/**
 * ONE-SHOT installer + backfill.
 * Upload ONLY this file to:
 *   public_html/backend-php/public/_notify_backfill_once.php
 *
 * Visit:
 *   https://villagenetacad.co.za/_notify_backfill_once.php?id=18
 *
 * It will CREATE lib/InAppNotifications.php if missing, then backfill order 18.
 * DELETE this file afterwards.
 */
header('Content-Type: text/plain; charset=utf-8');
ini_set('display_errors', '1');
error_reporting(E_ALL);

echo "STEP1 ok\n";

$root = dirname(__DIR__); // .../backend-php
$boot = $root . '/bootstrap.php';
$classFile = $root . '/lib/InAppNotifications.php';

echo "root: $root\n";
echo "lib dir exists: " . (is_dir($root . '/lib') ? 'yes' : 'NO') . "\n";
echo "class file before: " . (is_file($classFile) ? 'yes' : 'NO') . "\n";

$classSource = <<<'PHP'
<?php

class InAppNotifications
{
    public static function notify(
        int $userId,
        string $title,
        string $message,
        string $type = 'info'
    ): void {
        if ($userId < 1) {
            return;
        }
        $allowed = ['info', 'success', 'warning', 'error'];
        if (!in_array($type, $allowed, true)) {
            $type = 'info';
        }
        $title = substr(trim($title), 0, 255);
        $message = trim($message);
        if ($title === '' || $message === '') {
            return;
        }

        try {
            Database::queryRun(
                'INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, ?, 0)',
                [$userId, $title, $message, $type]
            );
        } catch (Throwable $e) {
            error_log('InAppNotifications: ' . $e->getMessage());
        }
    }

    public static function orderPaid(array $order, array $items = []): void
    {
        $orderId = (int) ($order['id'] ?? 0);
        $userId = (int) ($order['user_id'] ?? 0);
        $total = number_format((float) ($order['total'] ?? 0), 2);
        $itemNames = [];
        foreach ($items as $item) {
            if (!empty($item['name'])) {
                $itemNames[] = $item['name'];
            }
        }
        $itemsLine = $itemNames ? implode(', ', array_slice($itemNames, 0, 3)) : 'your items';

        self::notify(
            $userId,
            'Payment confirmed',
            "Order #$orderId is paid (R$total). We are processing $itemsLine.",
            'success'
        );

        $code = trim((string) ($order['referral_code'] ?? ''));
        if ($code === '') {
            return;
        }

        $seller = Database::queryGet(
            "SELECT id, user_id, referral_code, academy FROM reseller_profiles
             WHERE referral_code = ? AND status = 'approved'",
            [$code]
        );
        if (!$seller) {
            return;
        }

        self::notify(
            (int) $seller['user_id'],
            'Reseller sale confirmed',
            "A sale on order #$orderId (R$total) was attributed to {$seller['referral_code']}. Check your wallet and statement.",
            'success'
        );

        $ref = strtoupper(trim((string) $seller['referral_code']));
        $isCentre = strpos($ref, 'VNA-C-') === 0;
        $academy = trim((string) ($seller['academy'] ?? ''));
        if ($isCentre || $academy === '') {
            return;
        }

        $centre = Database::queryGet(
            "SELECT rp.user_id, rp.referral_code
             FROM reseller_profiles rp
             JOIN registrations r ON r.id = rp.user_id
             WHERE rp.status = 'approved'
               AND UPPER(rp.referral_code) LIKE 'VNA-C-%'
               AND (
                 LOWER(TRIM(COALESCE(rp.academy, ''))) = LOWER(?)
                 OR LOWER(TRIM(r.name)) = LOWER(?)
               )
             ORDER BY rp.id ASC
             LIMIT 1",
            [$academy, $academy]
        );
        if ($centre && (int) $centre['user_id'] !== (int) $seller['user_id']) {
            self::notify(
                (int) $centre['user_id'],
                'Centre share earned',
                "Order #$orderId (R$total) credited a centre share to {$centre['referral_code']}.",
                'success'
            );
        }
    }

    public static function orderStatusChanged(
        array $order,
        ?string $oldStatus,
        ?string $newStatus,
        ?string $tracking = null
    ): void {
        $orderId = (int) ($order['id'] ?? 0);
        $userId = (int) ($order['user_id'] ?? 0);
        if ($userId < 1 || $newStatus === null || $newStatus === '') {
            return;
        }
        if ($oldStatus !== null && strcasecmp((string) $oldStatus, $newStatus) === 0 && !$tracking) {
            return;
        }

        $label = ucfirst(str_replace('_', ' ', $newStatus));
        $body = "Order #$orderId is now: $label.";
        if ($tracking) {
            $body .= " Tracking: $tracking.";
        }
        if (strcasecmp($newStatus, 'delivered') === 0) {
            $body .= ' You can leave a review in My orders.';
        }

        self::notify($userId, 'Order update', $body, 'info');
    }
}
PHP;

if (!is_file($classFile)) {
    if (!is_dir($root . '/lib')) {
        http_response_code(500);
        echo "FAIL: lib/ folder missing at {$root}/lib\n";
        exit;
    }
    $written = @file_put_contents($classFile, $classSource);
    echo "wrote class bytes: " . ($written === false ? 'FAIL' : $written) . "\n";
    echo "class file after write: " . (is_file($classFile) ? 'yes' : 'NO') . "\n";
    if ($written === false) {
        http_response_code(500);
        echo "FAIL: could not write $classFile (permissions?)\n";
        echo "lib writable: " . (is_writable($root . '/lib') ? 'yes' : 'NO') . "\n";
        exit;
    }
} else {
    echo "class already present — left as-is\n";
}

if (!is_file($boot)) {
    http_response_code(500);
    echo "FAIL: bootstrap missing\n";
    exit;
}

require_once $boot;
echo "STEP2 bootstrap loaded\n";

if (!class_exists('InAppNotifications')) {
    require_once $classFile;
}
if (!class_exists('InAppNotifications')) {
    http_response_code(500);
    echo "FAIL: class still not loadable after write\n";
    exit;
}
echo "STEP3 class OK\n";

try {
    $id = (int) ($_GET['id'] ?? 18);
    $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$id]);
    if (!$order) {
        http_response_code(404);
        echo "FAIL: order $id not found\n";
        exit;
    }
    echo "STEP4 order #$id referral=" . ($order['referral_code'] ?? '') . "\n";

    $items = Database::queryAll(
        'SELECT oi.*, p.name FROM order_items oi
         LEFT JOIN products p ON p.id = oi.product_id
         WHERE oi.order_id = ?',
        [$id]
    );
    echo "STEP5 items=" . count($items) . "\n";

    InAppNotifications::orderPaid($order, $items ?: []);
    echo "STEP6 orderPaid() done\n";

    $rows = Database::queryAll(
        'SELECT id, user_id, title FROM notifications ORDER BY id DESC LIMIT 10'
    );
    echo "STEP7 notifications:\n";
    foreach ($rows as $r) {
        echo "  #" . $r['id'] . " user=" . $r['user_id'] . " " . $r['title'] . "\n";
    }
    echo "OK — delete this file now (_notify_backfill_once.php)\n";
} catch (Throwable $e) {
    http_response_code(500);
    echo "FAIL: " . $e->getMessage() . "\n";
    echo $e->getFile() . ':' . $e->getLine() . "\n";
}
