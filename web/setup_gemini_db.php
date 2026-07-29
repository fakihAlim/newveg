<?php
/**
 * Setup script to run Gemini key rotation migrations
 * Encrypts current API key and seeds the key tables.
 * PHP 8.3 Optimized
 */

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/config/security.php';

echo "Starting Gemini migration & seeding...\n";

$db = getDatabaseConnection();

try {
    // 1. Run migration_gemini.sql script
    $migrationPath = __DIR__ . '/migration_gemini.sql';
    if (!file_exists($migrationPath)) {
        die("Error: migration_gemini.sql not found.\n");
    }
    
    $sql = file_get_contents($migrationPath);
    $db->exec($sql);
    echo "Gemini API key rotation tables created/verified successfully.\n";

    // 2. Fetch default key from env to encrypt and seed
    $plainKey = getenv('GEMINI_API_KEY') ?: 'YOUR_GEMINI_API_KEY_HERE';
    
    if ($plainKey !== 'YOUR_GEMINI_API_KEY_HERE') {
        $encryptedKey = encrypt_key($plainKey);

        // Check if key already exists in table
        $checkStmt = $db->prepare("SELECT COUNT(*) FROM gemini_api_keys WHERE encrypted_key = ?");
        $checkStmt->execute([$encryptedKey]);
        $count = $checkStmt->fetchColumn();

        if ($count == 0) {
            $stmt = $db->prepare("INSERT INTO gemini_api_keys (encrypted_key, daily_limit) VALUES (?, ?)");
            $stmt->execute([$encryptedKey, 100]); // Default daily limit of 100 scans
            echo "Encrypted default Gemini API key successfully seeded into rotation table.\n";
        } else {
            echo "Default Gemini API key already exists in rotation table.\n";
        }
    } else {
        echo "Warning: No active GEMINI_API_KEY found in .env. Seeding skipped.\n";
    }

} catch (PDOException $e) {
    die("Setup Failed: " . $e->getMessage() . "\n");
}
