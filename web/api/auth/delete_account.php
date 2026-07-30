<?php
/**
 * Delete User Account Endpoint
 * POST /api/auth/delete_account.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

// Auth Guard
$user = requireAuth();
$userId = intval($user['user_id']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$db = getDatabaseConnection();

try {
    // 1. Delete user (cascades to food_logs, community_posts, comments, likes, reports, blocks)
    $stmt = $db->prepare("DELETE FROM users WHERE id = ?");
    $stmt->execute([$userId]);

    sendSuccess('Account and all associated data permanently deleted successfully.', null, 200);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
