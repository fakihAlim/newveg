<?php
/**
 * News / Articles Endpoint
 * GET /api/content/news.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

$category = isset($_GET['category']) ? trim($_GET['category']) : '';
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;

try {
    if (!empty($category)) {
        $stmt = $db->prepare("
            SELECT * FROM news 
            WHERE category = :category 
            ORDER BY published_at DESC 
            LIMIT :limit
        ");
        $stmt->bindValue(':category', $category, PDO::PARAM_STR);
    } else {
        $stmt = $db->prepare("
            SELECT * FROM news 
            ORDER BY published_at DESC 
            LIMIT :limit
        ");
    }

    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();

    $newsList = $stmt->fetchAll();

    sendSuccess('News articles fetched successfully.', [
        'count' => count($newsList),
        'news' => $newsList
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
