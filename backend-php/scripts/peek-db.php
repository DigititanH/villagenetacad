<?php
require dirname(__DIR__) . '/bootstrap.php';

$db = Database::connection();
$path = Paths::getDbPath();

echo "Database: {$path}\n\n";

$tables = $db->query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")->fetchAll(PDO::FETCH_COLUMN);

foreach ($tables as $table) {
    $n = $db->query("SELECT COUNT(*) FROM \"{$table}\"")->fetchColumn();
    echo "  - {$table}: {$n} row(s)\n";
}

echo "\nUsers:\n";
foreach ($db->query('SELECT id, name, email, role, is_approved FROM users')->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo json_encode($row, JSON_UNESCAPED_SLASHES) . "\n";
}
