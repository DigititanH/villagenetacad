<?php

/**
 * Sends email via SMTP (Gmail App Password / any SMTP).
 * Falls back to error_log when SMTP_USER / SMTP_PASS are missing.
 */
class Mailer
{
    public static function send(array $opts): void
    {
        $to = $opts['to'] ?? '';
        $subject = $opts['subject'] ?? '';
        $html = $opts['html'] ?? '';
        $replyTo = $opts['replyTo'] ?? null;

        $smtpUser = Env::get('SMTP_USER');
        // Gmail App Passwords are often copied with spaces — strip them.
        $smtpPass = preg_replace('/\s+/', '', (string) (Env::get('SMTP_PASS') ?? ''));
        $from = $smtpUser ?: Site::email();
        $fromName = Env::get('SMTP_FROM', 'Village NetAcad') ?: 'Village NetAcad';

        if (!$to || !$subject) {
            error_log('[Mailer] Missing to/subject');
            return;
        }

        if (!$smtpUser || !$smtpPass) {
            error_log("[Mailer] SMTP not configured — would send to $to: $subject");
            return;
        }

        try {
            self::smtpSend([
                'host' => Env::get('SMTP_HOST', 'smtp.gmail.com'),
                'port' => (int) Env::get('SMTP_PORT', '587'),
                'user' => $smtpUser,
                'pass' => $smtpPass,
                'from' => $from,
                'fromName' => $fromName,
                'to' => $to,
                'replyTo' => $replyTo,
                'subject' => $subject,
                'html' => $html,
            ]);
        } catch (Throwable $e) {
            error_log('[Mailer] Send failed: ' . $e->getMessage());
            // Re-throw so temporary smtp-test.php can show the real error.
            throw $e;
        }
    }

    /** @param array<string,mixed> $c */
    private static function smtpSend(array $c): void
    {
        $host = (string) $c['host'];
        $port = (int) $c['port'];
        $errno = 0;
        $errstr = '';
        $remote = ($port === 465 ? 'ssl://' : 'tcp://') . $host . ':' . $port;
        $fp = @stream_socket_client($remote, $errno, $errstr, 20, STREAM_CLIENT_CONNECT);
        if (!$fp) {
            throw new RuntimeException("SMTP connect failed: $errstr ($errno)");
        }
        stream_set_timeout($fp, 20);

        self::expect($fp, 220);
        self::cmd($fp, 'EHLO villagenetacad.co.za', 250);

        if ($port === 587) {
            self::cmd($fp, 'STARTTLS', 220);
            if (!stream_socket_enable_crypto($fp, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                throw new RuntimeException('STARTTLS failed');
            }
            self::cmd($fp, 'EHLO villagenetacad.co.za', 250);
        }

        self::cmd($fp, 'AUTH LOGIN', 334);
        self::cmd($fp, base64_encode((string) $c['user']), 334);
        self::cmd($fp, base64_encode((string) $c['pass']), 235);

        self::cmd($fp, 'MAIL FROM:<' . $c['from'] . '>', 250);
        self::cmd($fp, 'RCPT TO:<' . $c['to'] . '>', 250);
        self::cmd($fp, 'DATA', 354);

        $headers = [
            'From: "' . self::headerSafe((string) $c['fromName']) . '" <' . $c['from'] . '>',
            'To: <' . $c['to'] . '>',
            'Subject: ' . self::encodeSubject((string) $c['subject']),
            'MIME-Version: 1.0',
            'Content-Type: text/html; charset=UTF-8',
            'Content-Transfer-Encoding: 8bit',
        ];
        if (!empty($c['replyTo'])) {
            $headers[] = 'Reply-To: <' . $c['replyTo'] . '>';
        }

        $body = str_replace(["\r\n", "\r"], "\n", (string) $c['html']);
        $body = str_replace("\n.", "\n..", $body);
        $data = implode("\r\n", $headers) . "\r\n\r\n" . str_replace("\n", "\r\n", $body) . "\r\n.";
        fwrite($fp, $data . "\r\n");
        self::expect($fp, 250);

        self::cmd($fp, 'QUIT', 221);
        fclose($fp);
    }

    /** @param resource $fp */
    private static function cmd($fp, string $line, int $expectCode): void
    {
        fwrite($fp, $line . "\r\n");
        self::expect($fp, $expectCode);
    }

    /** @param resource $fp */
    private static function expect($fp, int $code): void
    {
        $reply = '';
        while (($line = fgets($fp, 515)) !== false) {
            $reply .= $line;
            if (isset($line[3]) && $line[3] === ' ') {
                break;
            }
        }
        if ((int) substr($reply, 0, 3) !== $code) {
            throw new RuntimeException('SMTP unexpected reply (wanted ' . $code . '): ' . trim($reply));
        }
    }

    private static function headerSafe(string $s): string
    {
        return str_replace(["\r", "\n", '"'], '', $s);
    }

    private static function encodeSubject(string $s): string
    {
        if (preg_match('/^[\x20-\x7E]*$/', $s)) {
            return $s;
        }
        return '=?UTF-8?B?' . base64_encode($s) . '?=';
    }
}
