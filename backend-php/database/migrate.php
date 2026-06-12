<?php

require_once dirname(__DIR__) . '/bootstrap.php';

function runSqlFile(PDO $pdo, string $path, bool $ignoreErrors = false): void
{
    if (!is_readable($path)) {
        throw new RuntimeException('SQL file not found: ' . $path);
    }

    $sql = file_get_contents($path);
    foreach (array_filter(array_map('trim', explode(';', $sql))) as $stmt) {
        if ($stmt === '' || str_starts_with($stmt, '--')) {
            continue;
        }
        try {
            $pdo->exec($stmt);
        } catch (PDOException $e) {
            if (!$ignoreErrors) {
                throw $e;
            }
        }
    }
}

function runSqlFilesInDirectory(PDO $pdo, string $directory, bool $ignoreErrors = false): void
{
    if (!is_dir($directory)) {
        throw new RuntimeException('SQL directory not found: ' . $directory);
    }

    $files = glob($directory . DIRECTORY_SEPARATOR . '*.sql');
    if ($files === false || $files === []) {
        throw new RuntimeException('No SQL files found in: ' . $directory);
    }

    sort($files, SORT_NATURAL);
    foreach ($files as $file) {
        runSqlFile($pdo, $file, $ignoreErrors);
    }
}

function ensureDatabaseExists(): void
{
    $host = Env::get('DB_HOST', '127.0.0.1');
    $port = Env::get('DB_PORT', '3306');
    $name = Env::get('DB_NAME', 'village_netacad');
    $user = Env::get('DB_USER', 'root');
    $pass = Env::get('DB_PASSWORD', '');

    $dsn = sprintf('mysql:host=%s;port=%s;charset=utf8mb4', $host, $port);
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    $pdo->exec(
        sprintf(
            'CREATE DATABASE IF NOT EXISTS `%s` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci',
            str_replace('`', '``', (string) $name)
        )
    );
}

try {
    ensureDatabaseExists();

    $pdo = Database::connection();
    $dbDir = __DIR__;

    runSqlFilesInDirectory($pdo, $dbDir . DIRECTORY_SEPARATOR . 'tables');
    runSqlFile($pdo, $dbDir . DIRECTORY_SEPARATOR . 'migrations.sql', true);
    runSqlFile($pdo, $dbDir . DIRECTORY_SEPARATOR . 'seed.sql');

    $existing = Database::queryGet(
        'SELECT r.id FROM registrations r
         JOIN logins l ON l.registration_id = r.id
         WHERE l.email = ?',
        ['admin@villagenetacad.com']
    );
    if (!$existing) {
        $hash = password_hash('Admin123!', PASSWORD_BCRYPT, ['cost' => 12]);
        $result = Database::queryRun(
            'INSERT INTO registrations (name, role, is_verified, is_approved) VALUES (?, ?, ?, ?)',
            ['Admin', 'admin', 1, 'approved']
        );
        Database::queryRun(
            'INSERT INTO logins (registration_id, email, password) VALUES (?, ?, ?)',
            [$result['lastInsertRowid'], 'admin@villagenetacad.com', $hash]
        );
    }

    echo "Database migrated and seeded successfully!\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Migration failed: ' . $e->getMessage() . "\n");
    exit(1);
}
