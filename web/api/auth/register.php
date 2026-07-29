<?php
/**
 * Register Endpoint
 * POST /api/auth/register.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['email']) || empty($input['password']) || empty($input['full_name'])) {
    sendError('Missing required fields: email, password, and full_name are required.');
}

$email = filter_var(trim($input['email']), FILTER_SANITIZE_EMAIL);
$password = $input['password'];
$fullName = trim($input['full_name']);

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendError('Invalid email format.');
}

if (strlen($password) < 6) {
    sendError('Password must be at least 6 characters long.');
}

$gender = $input['gender'] ?? null;
$age = isset($input['age']) ? intval($input['age']) : null;
$height = isset($input['height']) ? floatval($input['height']) : null;
$weight = isset($input['weight']) ? floatval($input['weight']) : null;
$dietPreference = $input['diet_preference'] ?? 'Vegan';
$ttmStage = $input['ttm_stage'] ?? 'Precontemplation';

$db = getDatabaseConnection();

// Check if email already exists
try {
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        sendError('Email address is already registered.', 409);
    }
} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}

// Insert new user
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

try {
    $stmt = $db->prepare("
        INSERT INTO users (email, password, full_name, gender, age, height, weight, diet_preference, ttm_stage)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $email,
        $hashedPassword,
        $fullName,
        $gender,
        $age,
        $height,
        $weight,
        $dietPreference,
        $ttmStage
    ]);
    
    $userId = $db->lastInsertId();
    
    // Fetch newly created user profile
    $stmt = $db->prepare("SELECT id, email, full_name, gender, age, height, weight, diet_preference, ttm_stage, total_points, is_premium, is_admin, created_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    // Generate JWT payload
    $tokenPayload = [
        'user_id' => $user['id'],
        'email' => $user['email'],
        'is_admin' => $user['is_admin']
    ];
    $token = generateJWT($tokenPayload);

    sendSuccess('Registration successful.', [
        'token' => $token,
        'user' => $user
    ], 210); // Custom success/created code
    
} catch (PDOException $e) {
    sendError('Registration failed: ' . $e->getMessage(), 500);
}
