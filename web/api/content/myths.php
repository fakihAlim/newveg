<?php
/**
 * Myths & Facts Endpoint
 * GET /api/content/myths.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

try {
    $stmt = $db->prepare("SELECT * FROM myths_facts ORDER BY id DESC");
    $stmt->execute();
    $myths = $stmt->fetchAll();

    sendSuccess('Myths and Facts fetched successfully.', [
        'count' => count($myths),
        'myths' => $myths
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
