<?php
/**
 * Daily Limit Reset Cron Job
 * Should be triggered at midnight (00:00) daily.
 * Target: crontab -> 0 0 * * * php /path/to/web/cron/reset_limits.php
 */

require_once __DIR__ . '/../config/database.php';

echo "[" . date('Y-m-d H:i:s') . "] Starting daily key limits reset...\n";

try {
    $db = getDatabaseConnection();
    
    // Reset key usage counters
    $stmt = $db->prepare("UPDATE gemini_api_keys SET used_today = 0");
    $stmt->execute();
    $rows = $stmt->rowCount();
    
    echo "[" . date('Y-m-d H:i:s') . "] Successfully reset daily quotas for $rows Gemini API keys.\n";

} catch (PDOException $e) {
    echo "[" . date('Y-m-d H:i:s') . "] Error resetting limits: " . $e->getMessage() . "\n";
    exit(1);
}
