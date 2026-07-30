<?php
/**
 * Share Food Log to Community Feed Endpoint
 * POST /api/community/share_log.php
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

if (empty($input['food_log_id'])) {
    sendError('Missing required field: food_log_id is required.');
}

$foodLogId = intval($input['food_log_id']);
$caption = isset($input['caption']) ? trim($input['caption']) : '';

$db = getDatabaseConnection();

try {
    // 1. Verify the food log exists and belongs to the authenticated user
    $verifyStmt = $db->prepare("SELECT id FROM food_logs WHERE id = ? AND user_id = ?");
    $verifyStmt->execute([$foodLogId, $userId]);
    if (!$verifyStmt->fetch()) {
        sendError('Food log not found or access denied.', 404);
    }

    // 2. Insert new post into community_posts
    $insertStmt = $db->prepare("
        INSERT INTO community_posts (user_id, food_log_id, caption, likes_count)
        VALUES (?, ?, ?, 0)
    ");
    $insertStmt->execute([$userId, $foodLogId, $caption]);
    $newPostId = $db->lastInsertId();

    sendSuccess('Food log shared to community successfully.', [
        'post_id' => intval($newPostId)
    ], 201);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
