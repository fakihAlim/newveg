<?php
/**
 * CLI Helper to create an Admin account in the database
 * Usage: php create_admin.php <email> <password> "<full_name>"
 */

if (php_sapi_name() !== 'cli') {
    die("This helper utility must be run from the command line (CLI).\n");
}

if ($argc < 4) {
    echo "Usage: php create_admin.php <email> <password> \"<full_name>\"\n";
    echo "Example: php create_admin.php admin2@newveg.com securepass123 \"Admin User\"\n";
    exit(1);
}

require_once __DIR__ . '/config/database.php';

$email = filter_var(trim($argv[1]), FILTER_SANITIZE_EMAIL);
$password = $argv[2];
$fullName = trim($argv[3]);

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die("Error: Invalid email format.\n");
}

if (strlen($password) < 6) {
    die("Error: Password must be at least 6 characters.\n");
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT);
$db = getDatabaseConnection();

try {
    // Check if user already exists
    $checkStmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $checkStmt->execute([$email]);
    if ($checkStmt->fetch()) {
        die("Error: A user with this email address already exists.\n");
    }

    // Insert new administrator
    $stmt = $db->prepare("
        INSERT INTO users (email, password, full_name, is_admin, is_premium, ttm_stage)
        VALUES (?, ?, ?, 1, 1, 'Maintenance')
    ");
    $stmt->execute([$email, $hashedPassword, $fullName]);

    echo "Success: Admin account created successfully!\n";
    echo "Email: $email\n";
    echo "Name: $fullName\n";

} catch (PDOException $e) {
    die("Database Error: " . $e->getMessage() . "\n");
}
