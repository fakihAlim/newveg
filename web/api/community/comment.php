<?php
/**
 * Comment on Post Endpoint
 * POST /api/community/comment.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

// Auth Guard
$user = requireAuth();
$userId = $user['user_id'];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['post_id']) || empty($input['comment_text'])) {
    sendError('Missing required fields: post_id and comment_text are required.');
}

$postId = intval($input['post_id']);
$commentText = trim($input['comment_text']);

$db = getDatabaseConnection();

try {
    // Verify post exists
    $stmt = $db->prepare("SELECT id FROM community_posts WHERE id = ?");
    $stmt->execute([$postId]);
    if (!$stmt->fetch()) {
        sendError('Community post not found.', 404);
    }

    $insertStmt = $db->prepare("INSERT INTO comments (post_id, user_id, comment_text) VALUES (?, ?, ?)");
    $insertStmt->execute([$postId, $userId, $commentText]);
    
    $commentId = $db->lastInsertId();

    // Fetch commenter's name for display convenience
    $userStmt = $db->prepare("SELECT full_name, is_premium FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $commenter = $userStmt->fetch();

    sendSuccess('Comment posted successfully.', [
        'comment' => [
            'id' => $commentId,
            'post_id' => $postId,
            'user_id' => $userId,
            'comment_text' => $commentText,
            'comment_author_name' => $commenter['full_name'],
            'comment_author_is_premium' => $commenter['is_premium'],
            'created_at' => date('Y-m-d H:i:s')
        ]
    ], 201);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
