<?php
/**
 * Like Community Post Endpoint
 * POST /api/community/like.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

// Auth Guard
$user = requireAuth();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['post_id'])) {
    sendError('Missing required field: post_id.');
}

$postId = intval($input['post_id']);
$action = $input['action'] ?? 'like'; // 'like' or 'unlike'

$db = getDatabaseConnection();

try {
    // Verify post exists
    $stmt = $db->prepare("SELECT id, likes_count FROM community_posts WHERE id = ?");
    $stmt->execute([$postId]);
    $post = $stmt->fetch();

    if (!$post) {
        sendError('Community post not found.', 404);
    }

    if ($action === 'unlike') {
        $newLikes = max(0, $post['likes_count'] - 1);
    } else {
        $newLikes = $post['likes_count'] + 1;
    }

    $updateStmt = $db->prepare("UPDATE community_posts SET likes_count = ? WHERE id = ?");
    $updateStmt->execute([$newLikes, $postId]);

    sendSuccess('Post ' . ($action === 'unlike' ? 'unliked' : 'liked') . ' successfully.', [
        'post_id' => $postId,
        'likes_count' => $newLikes
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
