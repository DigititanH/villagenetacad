<?php
/**
 * ONE-TIME: backfill in-app notifications for a paid order.
 * Upload to: public_html/backend-php/public/_notify_backfill_once.php
 * Visit: https://villagenetacad.co.za/_notify_backfill_once.php?id=18
 * Then DELETE this file.
 */
ini_set('display_errors', '1');
error_reporting(E_ALL);
header('Content-Type: application/json; charset=utf-8');

try {
    $boot = dirname(__DIR__) . '/bootstrap.php';
    if (!is_file($boot)) {
        http_response_code(500);
        echo json_encode(['error' => 'bootstrap not found', 'path' => $boot]);
        exit;
    }
    require_once $boot;

    if (!class_exists('InAppNotifications')) {
        http_response_code(500);
        echo json_encode([
            'error' => 'InAppNotifications class missing',
            'hint' => 'Upload lib/InAppNotifications.php to public_html/backend-php/lib/',
            'expected' => dirname(__DIR__) . '/lib/InAppNotifications.php',
            'exists' => is_file(dirname(__DIR__) . '/lib/InAppNotifications.php'),
        ]);
        exit;
    }

    $id = (int) ($_GET['id'] ?? 18);
    $order = Database::queryGet('SELECT * FROM orders WHERE id = ?', [$id]);
    if (!$order) {
        http_response_code(404);
        echo json_encode(['error' => 'order not found', 'id' => $id]);
        exit;
    }

    $items = Database::queryAll(
        'SELECT oi.*, p.name FROM order_items oi
         LEFT JOIN products p ON p.id = oi.product_id
         WHERE oi.order_id = ?',
        [$id]
    );

    InAppNotifications::orderPaid($order, $items ?: []);

    $rows = Database::queryAll(
        'SELECT id, user_id, title, message, type, created_at
         FROM notifications ORDER BY id DESC LIMIT 15'
    );

    echo json_encode([
        'ok' => true,
        'order_id' => $id,
        'referral_code' => $order['referral_code'] ?? null,
        'notifications' => $rows,
    ], JSON_PRETTY_PRINT);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'error' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ], JSON_PRETTY_PRINT);
}
