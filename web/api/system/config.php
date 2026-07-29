<?php
/**
 * System Settings Configuration Endpoint
 * GET /api/system/config.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

try {
    $stmt = $db->prepare("SELECT setting_key, setting_value FROM system_settings");
    $stmt->execute();
    $rows = $stmt->fetchAll();

    $configs = [];
    foreach ($rows as $row) {
        $configs[$row['setting_key']] = $row['setting_value'];
    }

    // fallback to env if settings not populated or empty
    if (!isset($configs['GEMINI_API_KEY']) || empty($configs['GEMINI_API_KEY'])) {
        $configs['GEMINI_API_KEY'] = getenv('GEMINI_API_KEY') ?: 'YOUR_GEMINI_API_KEY_HERE';
    }

    sendSuccess('System settings fetched successfully.', [
        'settings' => $configs
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
