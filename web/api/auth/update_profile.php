<?php
/**
 * Update User Profile/Metrics Endpoint
 * POST /api/auth/update_profile.php
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

$input = json_decode(file_get_contents('php://input'), true);

$gender = $input['gender'] ?? null;
$age = isset($input['age']) ? intval($input['age']) : null;
$height = isset($input['height']) ? floatval($input['height']) : null;
$weight = isset($input['weight']) ? floatval($input['weight']) : null;
$dietPreference = $input['diet_preference'] ?? null;
$ttmStage = $input['ttm_stage'] ?? null;
$totalPoints = isset($input['total_points']) ? intval($input['total_points']) : null;

$db = getDatabaseConnection();

try {
    // Build dynamic update query
    $fields = [];
    $params = [];
    
    if ($gender !== null) {
        $fields[] = "gender = ?";
        $params[] = $gender;
    }
    if ($age !== null) {
        $fields[] = "age = ?";
        $params[] = $age;
    }
    if ($height !== null) {
        $fields[] = "height = ?";
        $params[] = $height;
    }
    if ($weight !== null) {
        $fields[] = "weight = ?";
        $params[] = $weight;
    }
    if ($dietPreference !== null) {
        $fields[] = "diet_preference = ?";
        $params[] = $dietPreference;
    }
    if ($ttmStage !== null) {
        $fields[] = "ttm_stage = ?";
        $params[] = $ttmStage;
    }
    if ($totalPoints !== null) {
        $fields[] = "total_points = ?";
        $params[] = $totalPoints;
    }
    
    if (empty($fields)) {
        sendError('No fields to update.');
    }
    
    $params[] = $userId;
    $query = "UPDATE users SET " . implode(", ", $fields) . " WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    
    sendSuccess('Profile updated successfully.');
    
} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
