<?php
/**
 * Quizzes Endpoint
 * GET /api/content/quizzes.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

try {
    $stmt = $db->prepare("SELECT * FROM quizzes ORDER BY id DESC");
    $stmt->execute();
    $quizzes = $stmt->fetchAll();

    sendSuccess('Quizzes fetched successfully.', [
        'count' => count($quizzes),
        'quizzes' => $quizzes
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
