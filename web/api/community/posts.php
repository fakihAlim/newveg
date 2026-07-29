<?php
/**
 * Community Feed Endpoint
 * GET /api/community/posts.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 15;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;

try {
    // Select posts with poster info and optional food log info
    $stmt = $db->prepare("
        SELECT 
            p.id, p.caption, p.likes_count, p.created_at,
            u.id as user_id, u.full_name as author_name, u.email as author_email, u.is_premium as author_is_premium,
            f.id as food_log_id, f.food_name, f.calories, f.carbs, f.fats, f.protein, f.image_url as food_image, f.is_compliant
        FROM community_posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN food_logs f ON p.food_log_id = f.id
        ORDER BY p.created_at DESC
        LIMIT :limit OFFSET :offset
    ");
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    
    $posts = $stmt->fetchAll();

    // Attach comments for each post
    foreach ($posts as &$post) {
        $commentStmt = $db->prepare("
            SELECT 
                c.id, c.comment_text, c.created_at,
                u.id as user_id, u.full_name as comment_author_name, u.is_premium as comment_author_is_premium
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.post_id = ?
            ORDER BY c.created_at ASC
        ");
        $commentStmt->execute([$post['id']]);
        $post['comments'] = $commentStmt->fetchAll();
    }

    sendSuccess('Community feed fetched successfully.', [
        'count' => count($posts),
        'posts' => $posts
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
