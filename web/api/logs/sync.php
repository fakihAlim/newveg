<?php
/**
 * Food Logs Sync Endpoint
 * POST /api/logs/sync.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

// Require authenticated user token
$user = requireAuth();
$userId = $user['user_id'];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['logs']) || !is_array($input['logs'])) {
    sendError('Invalid request format. "logs" array is required.');
}

$logs = $input['logs'];
if (empty($logs)) {
    sendSuccess('No logs to sync.', ['synced_count' => 0]);
}

$db = getDatabaseConnection();

try {
    $db->beginTransaction();

    $insertedLogs = [];
    $totalPointsEarned = 0;

    $stmt = $db->prepare("
        INSERT INTO food_logs (user_id, food_name, image_url, calories, carbs, fats, protein, is_compliant, points_earned, created_at)
        VALUES (:user_id, :food_name, :image_url, :calories, :carbs, :fats, :protein, :is_compliant, :points_earned, :created_at)
    ");

    foreach ($logs as $log) {
        // Validation with defaults
        $foodName = trim($log['food_name'] ?? '');
        if (empty($foodName)) {
            continue; // Skip invalid entries
        }

        $imageUrl = $log['image_url'] ?? null;
        $calories = floatval($log['calories'] ?? 0);
        $carbs = floatval($log['carbs'] ?? 0);
        $fats = floatval($log['fats'] ?? 0);
        $protein = floatval($log['protein'] ?? 0);
        $isCompliant = isset($log['is_compliant']) ? intval($log['is_compliant']) : 1;
        $pointsEarned = isset($log['points_earned']) ? intval($log['points_earned']) : 0;
        $createdAt = $log['created_at'] ?? date('Y-m-d H:i:s');

        $stmt->execute([
            ':user_id' => $userId,
            ':food_name' => $foodName,
            ':image_url' => $imageUrl,
            ':calories' => $calories,
            ':carbs' => $carbs,
            ':fats' => $fats,
            ':protein' => $protein,
            ':is_compliant' => $isCompliant,
            ':points_earned' => $pointsEarned,
            ':created_at' => $createdAt
        ]);

        $insertedId = $db->lastInsertId();
        $totalPointsEarned += $pointsEarned;

        $insertedLogs[] = [
            'id' => $insertedId,
            'food_name' => $foodName,
            'points_earned' => $pointsEarned
        ];
    }

    // Update user points
    if ($totalPointsEarned > 0) {
        $updateStmt = $db->prepare("UPDATE users SET total_points = total_points + ? WHERE id = ?");
        $updateStmt->execute([$totalPointsEarned, $userId]);
    }

    $db->commit();

    // Fetch updated user points
    $pointsStmt = $db->prepare("SELECT total_points FROM users WHERE id = ?");
    $pointsStmt->execute([$userId]);
    $userPoints = $pointsStmt->fetchColumn();

    sendSuccess('Food logs synchronized successfully.', [
        'synced_count' => count($insertedLogs),
        'points_added' => $totalPointsEarned,
        'total_points' => $userPoints,
        'synced_logs' => $insertedLogs
    ]);

} catch (PDOException $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Sync transaction failed: ' . $e->getMessage(), 500);
}
