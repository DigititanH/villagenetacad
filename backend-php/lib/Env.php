<?php

class Env
{
    private static bool $loaded = false;

    public static function load(string $root): void
    {
        if (self::$loaded) {
            return;
        }

        $envFile = $root . DIRECTORY_SEPARATOR . '.env';
        if (is_file($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                $line = trim($line);
                if ($line === '' || str_starts_with($line, '#')) {
                    continue;
                }
                if (!str_contains($line, '=')) {
                    continue;
                }
                [$key, $value] = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value);
                if (
                    (str_starts_with($value, '"') && str_ends_with($value, '"')) ||
                    (str_starts_with($value, "'") && str_ends_with($value, "'"))
                ) {
                    $value = substr($value, 1, -1);
                }
                if (getenv($key) === false) {
                    putenv("$key=$value");
                    $_ENV[$key] = $value;
                }
            }
        }

        self::$loaded = true;
    }

    public static function get(string $key, ?string $default = null): ?string
    {
        $v = $_ENV[$key] ?? getenv($key);
        if ($v === false || $v === null || $v === '') {
            return $default;
        }
        return (string) $v;
    }

    public static function isProduction(): bool
    {
        return self::get('NODE_ENV', 'development') === 'production';
    }

    public static function validateProduction(): void
    {
        if (!self::isProduction()) {
            return;
        }

        $errors = [];
        $jwt = self::get('JWT_SECRET', '');
        if (strlen($jwt) < 32) {
            $errors[] = 'JWT_SECRET must be set and at least 32 characters';
        }
        if (preg_match('/CHANGE_ME|your_jwt|placeholder/i', $jwt)) {
            $errors[] = 'JWT_SECRET must be a strong random value (not a placeholder)';
        }
        if (!self::get('CLIENT_URL')) {
            $errors[] = 'CLIENT_URL must be your public site URL';
        }

        $pfId = self::get('PAYFAST_MERCHANT_ID', '');
        $pfKey = self::get('PAYFAST_MERCHANT_KEY', '');
        if ($pfId !== '' && $pfKey !== '') {
            if (!self::get('API_URL')) {
                $errors[] = 'API_URL must be your public HTTPS API URL when PayFast is enabled';
            }
            $notify = trim(self::get('PAYFAST_NOTIFY_URL', '') ?? '');
            if ($notify === '') {
                $api = rtrim(self::get('API_URL', '') ?? '', '/');
                $notify = ($api !== '' ? $api : 'http://localhost') . '/api/payfast/notify';
            }
            if (preg_match('/localhost|127\.0\.0\.1|0\.0\.0\.0/i', $notify)) {
                $errors[] = 'PayFast ITN requires a public HTTPS notify URL';
            }
        }

        if ($errors) {
            fwrite(STDERR, "[env] Production configuration errors:\n");
            foreach ($errors as $e) {
                fwrite(STDERR, "  - $e\n");
            }
            exit(1);
        }
    }
}
