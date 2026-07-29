<?php
/**
 * Recipes Endpoint
 * GET /api/content/recipes.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed. Use GET.', 405);
}

$db = getDatabaseConnection();

$search = isset($_GET['q']) ? trim($_GET['q']) : '';
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;

try {
    if (!empty($search)) {
        $stmt = $db->prepare("
            SELECT * FROM recipes 
            WHERE title LIKE :search OR description LIKE :search 
            ORDER BY id DESC 
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':search', '%' . $search . '%', PDO::PARAM_STR);
    } else {
        $stmt = $db->prepare("
            SELECT * FROM recipes 
            ORDER BY id DESC 
            LIMIT :limit OFFSET :offset
        ");
    }

    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $recipes = $stmt->fetchAll();

    // Map ingredients & instructions from raw text/JSON back into clean arrays
    foreach ($recipes as &$recipe) {
        $recipe['ingredients'] = json_decode($recipe['ingredients_json'] ?? '[]', true) ?: [];
        $recipe['instructions'] = json_decode($recipe['instructions_json'] ?? '[]', true) ?: [];
        unset($recipe['ingredients_json']);
        unset($recipe['instructions_json']);
    }

    sendSuccess('Recipes fetched successfully.', [
        'count' => count($recipes),
        'recipes' => $recipes
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
