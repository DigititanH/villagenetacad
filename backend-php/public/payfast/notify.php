<?php
/**
 * Live PayFast ITN entry — PayFast posts here after payment.
 *
 * Upload to BOTH if unsure which URL is wired (status shows the active one):
 *   public_html/payfast/notify.php
 *   public_html/backend-php/public/payfast/notify.php
 *
 * Live status currently: https://www.villagenetacad.co.za/payfast/notify.php
 * → usually public_html/payfast/notify.php (sibling of backend-php).
 *
 * Do NOT use the dead stub under public_html/backend-php/payfast/notify (no .php).
 */
http_response_code(200);
header('Content-Type: text/plain; charset=utf-8');
echo 'OK';

if (function_exists('fastcgi_finish_request')) {
    @fastcgi_finish_request();
} else {
    if (ob_get_level()) {
        @ob_end_flush();
    }
    @flush();
}

$bootstraps = [
    dirname(__DIR__) . '/backend-php/bootstrap.php',                 // public_html/payfast/notify.php
    dirname(__DIR__, 2) . '/bootstrap.php',                          // backend-php/public/payfast/notify.php
    dirname(__DIR__) . '/bootstrap.php',                             // backend-php/payfast/notify.php (unusual)
];

$boot = null;
foreach ($bootstraps as $candidate) {
    if (is_file($candidate)) {
        $boot = $candidate;
        break;
    }
}

$logDirs = [
    dirname(__DIR__) . '/backend-php/payfast',
    dirname(__DIR__, 2) . '/payfast',
    dirname(__DIR__) . '/payfast',
];
$logLine = '[' . date('Y-m-d H:i:s') . '] notify.php hit boot='
    . ($boot ?: 'NONE')
    . ' post_keys=' . implode(',', array_keys($_POST))
    . ' m_payment_id=' . ($_POST['m_payment_id'] ?? '')
    . "\n";
foreach ($logDirs as $dir) {
    if (!is_dir($dir)) {
        @mkdir($dir, 0755, true);
    }
    if (is_dir($dir) && is_writable($dir)) {
        @file_put_contents($dir . '/payfast.log', $logLine, FILE_APPEND | LOCK_EX);
        break;
    }
}

if ($boot === null) {
    error_log('PayFast notify.php: bootstrap.php not found');
    return;
}

require_once $boot;

try {
    PayfastController::notify();
} catch (Throwable $e) {
    error_log('PayFast notify.php: ' . $e->getMessage());
    if (class_exists('Payfast') && method_exists('Payfast', 'itnLog')) {
        Payfast::itnLog('notify.php exception: ' . $e->getMessage());
    }
}
