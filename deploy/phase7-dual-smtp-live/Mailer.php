<?php

/**
 * Dual SMTP profiles in one .env (shared API with website):
 * - APP_SMTP_* → mobile app mailbox (app@…)
 * - SMTP_*     → website team mailbox (they configure)
 *
 * Channel auto-pick: mobile request → app; else web.
 * Force with opts['channel'] = 'app'|'web'.
 * Background (ITN): prefers APP_SMTP if set, else SMTP_*.
 */
class Mailer
{
    public static function send(array $opts): void
    {
        $to = $opts['to'] ?? '';
        $subject = $opts['subject'] ?? '';
        $html = $opts['html'] ?? '';
        $replyTo = $opts['replyTo'] ?? null;

        if (!$to || !$subject) {
            error_log('[Mailer] Missing to/subject');
            return;
        }

        $channel = self::resolveChannel($opts['channel'] ?? null);
        $cfg = self::profile($channel);

        if ($cfg['user'] === '' || $cfg['pass'] === '') {
            error_log("[Mailer] $channel SMTP not configured — would send to $to: $subject");
            return;
        }

        try {
            self::smtpSend([
                'host' => $cfg['host'],
                'port' => $cfg['port'],
                'user' => $cfg['user'],
                'pass' => $cfg['pass'],
                'from' => $cfg['from'],
                'fromName' => $cfg['fromName'],
                'to' => $to,
                'replyTo' => $replyTo,
                'subject' => $subject,
                'html' => $html,
            ]);
        } catch (Throwable $e) {
            error_log('[Mailer] Send failed (' . $channel . '): ' . $e->getMessage());
        }
    }

    /**
     * Throws on failure — used by smtp-ping diagnostic.
     *
     * @param array{to:string,subject?:string,html?:string,channel?:string} $opts
     */
    public static function sendOrFail(array $opts): void
    {
        $to = $opts['to'] ?? '';
        $subject = $opts['subject'] ?? 'Village NetAcad SMTP test';
        $html = $opts['html'] ?? '<p>SMTP test OK from villagenetacad.co.za</p>';

        $channel = self::resolveChannel($opts['channel'] ?? 'app');
        $cfg = self::profile($channel);

        if ($cfg['user'] === '' || $cfg['pass'] === '') {
            throw new RuntimeException(strtoupper($channel) . ' SMTP user/pass not set in .env (use APP_SMTP_* for mobile)');
        }
        if ($to === '') {
            throw new RuntimeException('Missing to address');
        }

        self::smtpSend([
            'host' => $cfg['host'],
            'port' => $cfg['port'],
            'user' => $cfg['user'],
            'pass' => $cfg['pass'],
            'from' => $cfg['from'],
            'fromName' => $cfg['fromName'],
            'to' => $to,
            'replyTo' => null,
            'subject' => $subject,
            'html' => $html,
        ]);
    }

    /** @param mixed $forced */
    public static function resolveChannel($forced = null): string
    {
        $f = strtolower(trim((string) ($forced ?? '')));
        if ($f === 'app' || $f === 'mobile') {
            return 'app';
        }
        if ($f === 'web' || $f === 'website') {
            return 'web';
        }
        // Flutter app only — never treat bare website/browser as app.
        if (Request::isMobileClient()) {
            return 'app';
        }
        // Website / browser / unknown HTTP → web profile (SMTP_*).
        // PayFast ITN and other system hooks must pass channel => 'app' explicitly.
        return 'web';
    }

    /**
     * @return array{host:string,port:int,user:string,pass:string,from:string,fromName:string}
     */
    public static function profile(string $channel): array
    {
        if ($channel === 'app') {
            $user = trim((string) (Env::get('APP_SMTP_USER') ?? ''));
            // Migration: if APP_SMTP_* empty but legacy SMTP_USER is app@, use SMTP_*.
            if ($user === '') {
                $legacyUser = trim((string) (Env::get('SMTP_USER') ?? ''));
                if (stripos($legacyUser, 'app@') === 0) {
                    return self::legacySmtpAsApp();
                }
            }
            $pass = preg_replace('/\s+/', '', (string) (Env::get('APP_SMTP_PASS') ?? ''));
            $from = $user !== '' ? $user : (Site::email() ?: 'app@villagenetacad.co.za');
            return [
                'host' => Env::get('APP_SMTP_HOST', 'villagenetacad.co.za') ?: 'villagenetacad.co.za',
                'port' => (int) (Env::get('APP_SMTP_PORT', '465') ?: 465),
                'user' => $user,
                'pass' => $pass,
                'from' => $from,
                'fromName' => Env::get('APP_SMTP_FROM', 'Village NetAcad') ?: 'Village NetAcad',
            ];
        }

        $user = trim((string) (Env::get('SMTP_USER') ?? ''));
        // Do not let website channel accidentally use app@ — that mailbox is mobile-only.
        if (stripos($user, 'app@') === 0) {
            $user = '';
        }
        $pass = preg_replace('/\s+/', '', (string) (Env::get('SMTP_PASS') ?? ''));
        $from = $user !== '' ? $user : (Site::email() ?: 'noreply@villagenetacad.co.za');
        return [
            'host' => Env::get('SMTP_HOST', 'localhost') ?: 'localhost',
            'port' => (int) (Env::get('SMTP_PORT', '587') ?: 587),
            'user' => $user,
            'pass' => $pass,
            'from' => $from,
            'fromName' => Env::get('SMTP_FROM', 'Village NetAcad') ?: 'Village NetAcad',
        ];
    }

    /** @return array{host:string,port:int,user:string,pass:string,from:string,fromName:string} */
    private static function legacySmtpAsApp(): array
    {
        $user = trim((string) (Env::get('SMTP_USER') ?? ''));
        $pass = preg_replace('/\s+/', '', (string) (Env::get('SMTP_PASS') ?? ''));
        return [
            'host' => Env::get('SMTP_HOST', 'villagenetacad.co.za') ?: 'villagenetacad.co.za',
            'port' => (int) (Env::get('SMTP_PORT', '465') ?: 465),
            'user' => $user,
            'pass' => $pass,
            'from' => $user,
            'fromName' => Env::get('SMTP_FROM', 'Village NetAcad') ?: 'Village NetAcad',
        ];
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
            throw new RuntimeException("SMTP connect failed: $errstr ($errno) via $remote");
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
