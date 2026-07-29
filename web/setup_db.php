<?php
/**
 * Database Auto-Installer Script
 * PHP 8.3 Optimized
 */

require_once __DIR__ . '/config/database.php';

echo "Starting database setup...\n";

// 1. Connect to MySQL server without selecting a database first
$host = getenv('DB_HOST') ?: '127.0.0.1';
$user = getenv('DB_USERNAME') ?: 'root';
$pass = getenv('DB_PASSWORD') ?: '';
$port = getenv('DB_PORT') ?: '3306';

try {
    $dsn = "mysql:host=$host;port=$port;charset=utf8mb4";
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    
    // 2. Create the database
    $dbName = getenv('DB_DATABASE') ?: 'newveg';
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$dbName` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
    echo "Database `$dbName` created or verified successfully.\n";

    // 3. Connect to the database
    $pdo->exec("USE `$dbName`;");

    // 4. Read schema.sql file
    $schemaPath = __DIR__ . '/schema.sql';
    if (!file_exists($schemaPath)) {
        die("Error: schema.sql file not found at $schemaPath\n");
    }

    $sql = file_get_contents($schemaPath);
    
    // Execute schema queries
    $pdo->exec($sql);
    echo "Database schema imported successfully with all default seed data.\n";
    echo "Setup complete!\n";

} catch (PDOException $e) {
    die("Setup Error: " . $e->getMessage() . "\n");
}
