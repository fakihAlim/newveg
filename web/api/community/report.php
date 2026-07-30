<?php
/**
 * Report Community Post Endpoint
 * POST /api/community/report.php
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

if (empty($input['post_id']) || empty($input['reason'])) {
    sendError('Missing required fields: post_id and reason are required.');
}

$postId = intval($input['post_id']);
$reason = trim($input['reason']);

$db = getDatabaseConnection();

try {
    // 1. Verify post exists
    $verifyStmt = $db->prepare("SELECT id FROM community_posts WHERE id = ?");
    $verifyStmt->execute([$postId]);
    if (!$verifyStmt->fetch()) {
        sendError('Post not found.', 404);
    }

    // 2. Insert report
    $insertStmt = $db->prepare("
        INSERT INTO community_reports (post_id, user_id, reason)
        VALUES (?, ?, ?)
    ");
    $insertStmt->execute([$postId, $userId, $reason]);

    sendSuccess('Post reported successfully.', null, 201);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
