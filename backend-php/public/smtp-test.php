<?php
/**
 * TEMPORARY browser SMTP test — DELETE this file after UAT.
 * Place at: backend-php/public/smtp-test.php
 * Open: https://villagenetacad.co.za/smtp-test.php?key=YOUR_JWT_SECRET_FIRST_8_CHARS
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

header('Content-Type: text/plain; charset=utf-8');

$secret = (string) Env::get('JWT_SECRET', '');
$key = (string) ($_GET['key'] ?? '');
if ($secret === '' || $key === '' || !hash_equals(substr($secret, 0, 8), $key)) {
    http_response_code(403);
    echo "Forbidden\n";
    exit;
}

$host = Env::get('SMTP_HOST', 'smtp.gmail.com');
$port = (int) Env::get('SMTP_PORT', '587');
$user = (string) Env::get('SMTP_USER', '');
$pass = preg_replace('/\s+/', '', (string) (Env::get('SMTP_PASS') ?? ''));

echo "HOST=$host PORT=$port USER=$user PASS_LEN=" . strlen($pass) . "\n\n";

if ($user === '' || $pass === '') {
    echo "FAIL: SMTP_USER/PASS empty\n";
    exit;
}

// Direct connect probe (shows Afrihost block clearly)
$remote = ($port === 465 ? 'ssl://' : 'tcp://') . $host . ':' . $port;
$errno = 0;
$errstr = '';
$fp = @stream_socket_client($remote, $errno, $errstr, 15, STREAM_CLIENT_CONNECT);
if (!$fp) {
    echo "CONNECT FAIL to $remote\n$errstr ($errno)\n\n";
    echo "Likely host firewall blocking Gmail SMTP.\n";
    echo "Switch .env to cPanel mailbox:\n";
    echo "SMTP_HOST=localhost\n";
    echo "SMTP_PORT=587\n";
    echo "SMTP_USER=info@villagenetacad.co.za\n";
    echo "SMTP_PASS=<cpanel email password>\n";
    exit;
}
fclose($fp);
echo "CONNECT OK to $remote\n\n";

try {
    Mailer::send([
        'to' => $user,
        'subject' => 'Village NetAcad SMTP test ' . gmdate('c'),
        'html' => '<p>SMTP test succeeded from villagenetacad.co.za</p>',
    ]);
    echo "SEND OK — check inbox/spam for $user\n";
} catch (Throwable $e) {
    echo "SEND FAIL: " . $e->getMessage() . "\n";
}
