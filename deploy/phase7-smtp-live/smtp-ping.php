<?php

/**
 * TEMPORARY SMTP diagnostic for public_html/backend-php/public/
 *
 * Usage (browser):
 *   /smtp-ping.php?key=YOUR_SMTP_TEST_KEY&to=you@example.com
 *
 * Requires in .env:
 *   SMTP_TEST_KEY=...   (random secret you choose)
 *   SMTP_HOST / SMTP_PORT / SMTP_USER / SMTP_PASS
 *
 * DELETE this file after a successful test.
 */

require_once dirname(__DIR__) . '/bootstrap.php';

header('Content-Type: application/json; charset=utf-8');

$keyExpected = trim((string) (Env::get('SMTP_TEST_KEY') ?? ''));
$keyGot = trim((string) ($_GET['key'] ?? ''));
$to = trim((string) ($_GET['to'] ?? ''));

if ($keyExpected === '' || !hash_equals($keyExpected, $keyGot)) {
    http_response_code(403);
    echo json_encode(['ok' => false, 'error' => 'Forbidden — set SMTP_TEST_KEY in .env and pass ?key=']);
    exit;
}

if ($to === '' || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Pass a valid ?to=email@domain']);
    exit;
}

$host = Env::get('SMTP_HOST', 'localhost');
$port = (int) (Env::get('SMTP_PORT', '587') ?: 587);
$user = Env::get('SMTP_USER', '');

try {
    Mailer::sendOrFail([
        'to' => $to,
        'subject' => 'Village NetAcad SMTP ping OK',
        'html' => '<p>SMTP works from <strong>public_html/backend-php</strong>.</p>'
            . '<p>Host: ' . htmlspecialchars((string) $host) . ':' . $port . '</p>'
            . '<p>User: ' . htmlspecialchars((string) $user) . '</p>'
            . '<p><em>Delete public/smtp-ping.php after testing.</em></p>',
    ]);
    echo json_encode([
        'ok' => true,
        'message' => "Sent test mail to $to",
        'smtp_host' => $host,
        'smtp_port' => $port,
        'smtp_user' => $user,
        'reminder' => 'DELETE public/smtp-ping.php now',
    ]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => $e->getMessage(),
        'smtp_host' => $host,
        'smtp_port' => $port,
        'smtp_user' => $user,
        'hint' => 'Try SMTP_HOST=localhost or mail.villagenetacad.co.za, port 465 (SSL) or 587 (STARTTLS). Avoid smtp.gmail.com on Afrihost.',
    ]);
}
