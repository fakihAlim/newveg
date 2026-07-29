<?php
/**
 * Production Database Migration Script
 * Can be run via CLI or browser.
 */

// If running via browser, add a security check to prevent unauthorized schema resets
if (php_sapi_name() !== 'cli') {
    $secret = $_GET['secret'] ?? '';
    $expectedSecret = 'migrate_secure_key_2026'; // Change this key for production security
    if ($secret !== $expectedSecret) {
        http_response_code(403);
        die("Unauthorized access. Please provide the correct secret token to run migration.");
    }
}

// Set VPS database environment credentials (fallback to config/database.php defaults if not set in server .env)
putenv("DB_HOST=127.0.0.1");
putenv("DB_DATABASE=newvegdb");
putenv("DB_USERNAME=unewveg");
putenv("DB_PASSWORD=RWZQ6lnoS26N70jl5uqf");

// Update server env arrays so config/database.php picks it up
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_DATABASE'] = 'newvegdb';
$_ENV['DB_USERNAME'] = 'unewveg';
$_ENV['DB_PASSWORD'] = 'RWZQ6lnoS26N70jl5uqf';

require_once __DIR__ . '/config/database.php';

echo php_sapi_name() === 'cli' ? "" : "<pre>";
echo "Starting Database Migration on Production Server...\n";

try {
    $db = getDatabaseConnection();
    
    $schemaPath = __DIR__ . '/schema.sql';
    if (!file_exists($schemaPath)) {
        die("Error: schema.sql not found at $schemaPath\n");
    }

    $sql = file_get_contents($schemaPath);
    
    // Execute schema imports
    $db->exec($sql);
    echo "Database migrated successfully. All tables and seed data created.\n";
    echo "Migration Complete!\n";

} catch (PDOException $e) {
    die("Migration Failed: " . $e->getMessage() . "\n");
}

echo php_sapi_name() === 'cli' ? "" : "</pre>";
