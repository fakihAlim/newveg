<?php
/**
 * Block User Endpoint
 * POST /api/community/block.php
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

// Parse request payload
$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['blocked_user_id'])) {
    sendError('Missing required field: blocked_user_id is required.');
}

$blockedUserId = intval($input['blocked_user_id']);

if ($userId === $blockedUserId) {
    sendError('You cannot block yourself.');
}

$db = getDatabaseConnection();

try {
    // 1. Verify user to block exists
    $verifyStmt = $db->prepare("SELECT id FROM users WHERE id = ?");
    $verifyStmt->execute([$blockedUserId]);
    if (!$verifyStmt->fetch()) {
        sendError('User not found.', 404);
    }

    // 2. Insert block (ignore if already blocked)
    $insertStmt = $db->prepare("
        INSERT IGNORE INTO blocked_users (user_id, blocked_user_id)
        VALUES (?, ?)
    ");
    $insertStmt->execute([$userId, $blockedUserId]);

    sendSuccess('User blocked successfully.', null, 201);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
