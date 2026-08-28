<?php
/**
 * PASTE AS: public_html/backend-php/public/_notify_backfill_once.php
 * (must end in .php)
 *
 * Also required: public_html/backend-php/lib/InAppNotifications.php
 */
header('Content-Type: text/plain; charset=utf-8');
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

echo "STEP1 ok\n";

$boot = dirname(__DIR__) . '/bootstrap.php';
echo "bootstrap path: $boot\n";
echo "bootstrap exists: " . (is_file($boot) ? 'yes' : 'NO') . "\n";

$classFile = dirname(__DIR__) . '/lib/InAppNotifications.php';
echo "class file: $classFile\n";
echo "class file exists: " . (is_file($classFile) ? 'yes' : 'NO') . "\n";

if (!is_file($boot)) {
    http_response_code(500);
    echo "FAIL: bootstrap.php missing\n";
    exit;
}

try {
    require_once $boot;
    echo "STEP2 bootstrap loaded\n";
} catch (Throwable $e) {
    http_response_code(500);
    echo "FAIL bootstrap: " . $e->getMessage() . "\n";
    exit;
}

if (!class_exists('InAppNotifications')) {
    // Force-load once more with clear error
    if (is_file($classFile)) {
        require_once $classFile;
    }
}
if (!class_exists('InAppNotifications')) {
    http_response_code(500);
    echo "FAIL: class InAppNotifications not found.\n";
    echo "Upload file EXACTLY as: public_html/backend-php/lib/InAppNotifications.php\n";
    echo "(Not 'InAppNotifications' without .php)\n";
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
    echo "OK — delete this file now\n";
} catch (Throwable $e) {
    http_response_code(500);
    echo "FAIL: " . $e->getMessage() . "\n";
    echo $e->getFile() . ':' . $e->getLine() . "\n";
}
