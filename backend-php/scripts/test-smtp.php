<?php
/**
 * One-off SMTP test for cPanel.
 * Upload next to bootstrap: backend-php/scripts/test-smtp.php
 *
 * Browser (temporary):
 *   https://villagenetacad.co.za/api/../ won't work — document root is public/
 *
 * Prefer SSH/Terminal:
 *   cd ~/public_html/village-netacad/backend-php && php scripts/test-smtp.php
 *
 * Or put a copy at public/smtp-test.php (DELETE after test) that requires this file.
 */
declare(strict_types=1);

$root = dirname(__DIR__);
require_once $root . '/bootstrap.php';

header('Content-Type: text/plain; charset=utf-8');

$host = Env::get('SMTP_HOST', 'smtp.gmail.com');
$port = Env::get('SMTP_PORT', '587');
$user = Env::get('SMTP_USER', '');
$passSet = Env::get('SMTP_PASS') !== null && Env::get('SMTP_PASS') !== '';

echo "SMTP_HOST=$host\n";
echo "SMTP_PORT=$port\n";
echo "SMTP_USER=$user\n";
echo "SMTP_PASS_SET=" . ($passSet ? 'yes' : 'NO') . "\n";
echo "CLIENT_URL=" . (Env::get('CLIENT_URL') ?? '') . "\n\n";

if (!$user || !$passSet) {
    echo "FAIL: SMTP_USER / SMTP_PASS missing in backend-php/.env\n";
    exit(1);
}

$to = $user;
try {
    Mailer::send([
        'to' => $to,
        'subject' => 'Village NetAcad SMTP test ' . gmdate('c'),
        'html' => '<p>If you received this, Gmail/SMTP from the server works.</p>',
    ]);
    echo "Mailer::send() returned without throwing.\n";
    echo "Check inbox (and spam) for: $to\n";
    echo "If nothing arrives, open cPanel → Errors / email logs for [Mailer] lines.\n";
    echo "Afrihost often blocks outbound smtp.gmail.com — try hosting mail instead:\n";
    echo "  SMTP_HOST=mail.villagenetacad.co.za (or localhost)\n";
    echo "  SMTP_USER=info@villagenetacad.co.za (cPanel email account)\n";
    echo "  SMTP_PASS=<that mailbox password>\n";
} catch (Throwable $e) {
    echo "FAIL: " . $e->getMessage() . "\n";
    exit(1);
}
