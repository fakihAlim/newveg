<?php
/**
 * Login Endpoint
 * POST /api/auth/login.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['email']) || empty($input['password'])) {
    sendError('Missing email or password.');
}

$email = filter_var(trim($input['email']), FILTER_SANITIZE_EMAIL);
$password = $input['password'];

$db = getDatabaseConnection();

try {
    $stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user || !password_verify($password, $user['password'])) {
        sendError('Invalid email or password.', 401);
    }
    
    // Clean up sensitive fields before returning
    unset($user['password']);

    // Generate JWT token
    $tokenPayload = [
        'user_id' => $user['id'],
        'email' => $user['email'],
        'is_admin' => $user['is_admin']
    ];
    $token = generateJWT($tokenPayload);

    sendSuccess('Login successful.', [
        'token' => $token,
        'user' => $user
    ]);

} catch (PDOException $e) {
    sendError('Database error: ' . $e->getMessage(), 500);
}
