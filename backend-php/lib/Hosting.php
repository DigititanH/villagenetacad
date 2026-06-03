<?php

/**
 * Shared-hosting checks (Afrihost cPanel, Azure App Service PHP — no Composer, no Node).
 */
class Hosting
{
    public static function platformLabel(): string
    {
        if (getenv('WEBSITE_SITE_NAME') || getenv('WEBSITE_INSTANCE_ID')) {
            return 'azure-app-service';
        }
        return 'php-shared';
    }
    /** @var list<string> */
    private const REQUIRED_EXTENSIONS = ['pdo_sqlite', 'json', 'mbstring', 'curl', 'fileinfo'];

    /** @return list<string> */
    public static function missingExtensions(): array
    {
        $missing = [];
        foreach (self::REQUIRED_EXTENSIONS as $ext) {
            if (!extension_loaded($ext)) {
                $missing[] = $ext;
            }
        }
        return $missing;
    }

    /** @return list<string> */
    public static function productionConfigErrors(): array
    {
        if (!Env::isProduction()) {
            return [];
        }

        $errors = [];
        $jwt = Env::get('JWT_SECRET', '');
        if (strlen((string) $jwt) < 32) {
            $errors[] = 'JWT_SECRET must be set and at least 32 characters';
        } elseif (preg_match('/CHANGE_ME|your_jwt|placeholder|dev-secret/i', (string) $jwt)) {
            $errors[] = 'JWT_SECRET must be a strong random value (not a placeholder)';
        }
        if (!Env::get('CLIENT_URL')) {
            $errors[] = 'CLIENT_URL must be your public site URL';
        }

        $pfId = Env::get('PAYFAST_MERCHANT_ID', '');
        $pfKey = Env::get('PAYFAST_MERCHANT_KEY', '');
        if ($pfId !== '' && $pfKey !== '') {
            if (!Env::get('API_URL')) {
                $errors[] = 'API_URL must be your public HTTPS URL when PayFast is enabled';
            }
            $notify = trim((string) Env::get('PAYFAST_NOTIFY_URL', ''));
            if ($notify === '') {
                $api = rtrim((string) Env::get('API_URL', ''), '/');
                $notify = ($api !== '' ? $api : 'http://localhost') . '/api/payfast/notify';
            }
            if (preg_match('/localhost|127\.0\.0\.1|0\.0\.0\.0/i', $notify)) {
                $errors[] = 'PayFast ITN requires a public HTTPS notify URL (PAYFAST_NOTIFY_URL)';
            }
        }

        return $errors;
    }

    /** @return list<string> */
    public static function writablePathErrors(): array
    {
        $errors = [];
        $uploads = Paths::getUploadsDir();
        Paths::ensureDir($uploads);
        if (!is_dir($uploads) || !is_writable($uploads)) {
            $errors[] = 'UPLOADS_DIR is not writable: ' . $uploads;
        }

        $dbPath = Paths::getDbPath();
        $dbDir = dirname($dbPath);
        Paths::ensureDir($dbDir);
        if (!is_dir($dbDir) || !is_writable($dbDir)) {
            $errors[] = 'Database directory is not writable: ' . $dbDir;
        }
        if (is_file($dbPath) && !is_writable($dbPath)) {
            $errors[] = 'DATABASE_PATH file is not writable: ' . $dbPath;
        }

        return $errors;
    }

    /** @return array<string, mixed> */
    public static function healthPayload(): array
    {
        $extMissing = self::missingExtensions();
        $writableErrors = self::writablePathErrors();
        $configErrors = self::productionConfigErrors();
        $ok = $extMissing === [] && $writableErrors === [] && $configErrors === [];

        return [
            'status' => $ok ? 'ok' : 'degraded',
            'env' => Env::get('NODE_ENV', 'development'),
            'php' => PHP_VERSION,
            'hosting' => self::platformLabel(),
            'timestamp' => gmdate('c'),
            'checks' => [
                'extensions' => [
                    'ok' => $extMissing === [],
                    'missing' => $extMissing,
                    'required' => self::REQUIRED_EXTENSIONS,
                ],
                'writable' => [
                    'ok' => $writableErrors === [],
                    'errors' => $writableErrors,
                    'database_path' => Paths::getDbPath(),
                    'uploads_dir' => Paths::getUploadsDir(),
                ],
                'config' => [
                    'ok' => $configErrors === [],
                    'errors' => $configErrors,
                ],
            ],
        ];
    }
}
