<?php
/**
 * Database Connection Setup using PDO
 * PHP 8.3 Optimized
 */

// Load environment variables from .env if available
if (file_exists(__DIR__ . '/../.env')) {
    $lines = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (str_starts_with(trim($line), '#')) {
            continue;
        }
        $parts = explode('=', $line, 2);
        if (count($parts) === 2) {
            $key = trim($parts[0]);
            $val = trim($parts[1]);
            if (!array_key_exists($key, $_SERVER) && !array_key_exists($key, $_ENV)) {
                putenv("{$key}={$val}");
                $_ENV[$key] = $val;
                $_SERVER[$key] = $val;
            }
        }
    }
}

function getDatabaseConnection(): PDO {
    static $pdo = null;

    if ($pdo === null) {
        // Read database configuration with defaults optimized for local Laragon and easy production override
        $host = getenv('DB_HOST') ?: '127.0.0.1';
        $db   = getenv('DB_DATABASE') ?: 'newveg';
        $user = getenv('DB_USERNAME') ?: 'root';
        $pass = getenv('DB_PASSWORD') ?: '';
        $port = getenv('DB_PORT') ?: '3306';
        $charset = 'utf8mb4';

        $dsn = "mysql:host=$host;dbname=$db;port=$port;charset=$charset";
        
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
        ];

        try {
            $pdo = new PDO($dsn, $user, $pass, $options);
        } catch (PDOException $e) {
            // In API context, return JSON error instead of standard HTML traceback
            header('Content-Type: application/json', true, 500);
            echo json_encode([
                'success' => false,
                'message' => 'Database Connection Failed: ' . $e->getMessage()
            ]);
            exit;
        }
    }

    return $pdo;
}
