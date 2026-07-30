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

// Self-migration: Ensure image_url column exists in community_posts
try {
    $db->exec("ALTER TABLE `community_posts` ADD COLUMN `image_url` VARCHAR(255) DEFAULT NULL");
} catch (PDOException $e) {
    // Silent fail if column already exists
}

try {
    // 1. Verify the food log exists and belongs to the authenticated user
    $verifyStmt = $db->prepare("SELECT id, image_url FROM food_logs WHERE id = ? AND user_id = ?");
    $verifyStmt->execute([$foodLogId, $userId]);
    $log = $verifyStmt->fetch();
    if (!$log) {
        sendError('Food log not found or access denied.', 404);
    }

    $rawImage = $log['image_url'] ?? '';
    // Normalize relative vs full URL
    $imageUrl = '';
    if (!empty($rawImage)) {
        if (str_starts_with($rawImage, 'http')) {
            $imageUrl = $rawImage;
        } else {
            // Ensure path does not double-prefix 'uploads/'
            $cleanPath = ltrim(str_replace('uploads/', '', $rawImage), '/');
            $imageUrl = 'uploads/' . $cleanPath;
        }
    }

    // 2. Insert new post into community_posts including image_url
    $insertStmt = $db->prepare("
        INSERT INTO community_posts (user_id, food_log_id, image_url, caption, likes_count)
        VALUES (?, ?, ?, ?, 0)
    ");
    $insertStmt->execute([$userId, $foodLogId, $imageUrl, $caption]);
    $newPostId = $db->lastInsertId();

    sendSuccess('Shared successfully', [
        'status' => 'success',
        'post_id' => intval($newPostId)
    ], 200);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
