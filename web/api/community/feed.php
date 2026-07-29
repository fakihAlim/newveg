<?php
/**
 * Community Social Feed Endpoint
 * GET /api/community/feed.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

// Auth Guard
$userToken = requireAuth();
$requestUserId = intval($userToken['user_id']);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

// Ensure the community_likes table exists
try {
    $db->exec("
        CREATE TABLE IF NOT EXISTS `community_likes` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `post_id` INT NOT NULL,
          `user_id` INT NOT NULL,
          `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE KEY `user_post_like` (`user_id`, `post_id`),
          FOREIGN KEY (`post_id`) REFERENCES `community_posts`(`id`) ON DELETE CASCADE,
          FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
} catch (PDOException $e) {
    // Silent fail if table already exists or schema cannot be modified
}

$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = isset($_GET['limit']) ? max(1, intval($_GET['limit'])) : 20;
$offset = ($page - 1) * $limit;

try {
    // Fetch posts with author and image url details
    $stmt = $db->prepare("
        SELECT 
            p.id, 
            p.caption, 
            p.likes_count, 
            p.created_at, 
            p.user_id,
            u.full_name as author_name,
            f.image_url as food_image
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

    $feedData = [];

    foreach ($posts as $post) {
        $postId = intval($post['id']);
        
        // Construct fully-qualified URLs
        $rawImage = $post['food_image'] ?? '';
        $imageUrl = '';
        if (!empty($rawImage)) {
            $imageUrl = str_starts_with($rawImage, 'http') ? $rawImage : 'https://yodi.my.id/veg/web/' . $rawImage;
        }

        $authorAvatar = 'https://yodi.my.id/veg/uploads/avatars/user' . $post['user_id'] . '.jpg';

        // Check if liked by the requesting user
        $likeStmt = $db->prepare("SELECT 1 FROM community_likes WHERE post_id = ? AND user_id = ? LIMIT 1");
        $likeStmt->execute([$postId, $requestUserId]);
        $isLikedByMe = $likeStmt->fetch() ? true : false;

        // Fetch comments count
        $commentCountStmt = $db->prepare("SELECT COUNT(*) FROM comments WHERE post_id = ?");
        $commentCountStmt->execute([$postId]);
        $commentsCount = intval($commentCountStmt->fetchColumn());

        $feedData[] = [
            'id' => $postId,
            'authorName' => $post['author_name'] ?? 'Anonymous User',
            'authorAvatar' => $authorAvatar,
            'imageUrl' => $imageUrl,
            'caption' => $post['caption'] ?? '',
            'likesCount' => intval($post['likes_count']),
            'commentsCount' => $commentsCount,
            'isLikedByMe' => $isLikedByMe,
            'createdAt' => $post['created_at']
        ];
    }

    sendResponse(true, 'Feed fetched successfully.', [
        'status' => 'success',
        'data' => $feedData
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
