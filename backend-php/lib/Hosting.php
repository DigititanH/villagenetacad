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
    private const REQUIRED_EXTENSIONS = ['pdo_mysql', 'json', 'mbstring', 'curl', 'fileinfo'];

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
        if (!Env::get('DB_NAME')) {
            $errors[] = 'DB_NAME must be set';
        }
        if (!Env::get('DB_USER')) {
            $errors[] = 'DB_USER must be set';
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

        return $errors;
    }

    /** @return list<string> */
    public static function databaseConnectionErrors(): array
    {
        try {
            Database::connection()->query('SELECT 1');
            return [];
        } catch (Throwable $e) {
            return ['Database connection failed: ' . $e->getMessage()];
        }
    }

    /** @return array<string, mixed> */
    public static function healthPayload(): array
    {
        $extMissing = self::missingExtensions();
        $writableErrors = self::writablePathErrors();
        $dbErrors = self::databaseConnectionErrors();
        $configErrors = self::productionConfigErrors();
        $ok = $extMissing === [] && $writableErrors === [] && $dbErrors === [] && $configErrors === [];

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
                    'uploads_dir' => Paths::getUploadsDir(),
                ],
                'database' => [
                    'ok' => $dbErrors === [],
                    'errors' => $dbErrors,
                    'name' => Paths::getDatabaseName(),
                    'host' => Env::get('DB_HOST', '127.0.0.1'),
                ],
                'config' => [
                    'ok' => $configErrors === [],
                    'errors' => $configErrors,
                ],
            ],
        ];
    }
}
