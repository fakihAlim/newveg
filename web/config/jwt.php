<?php
/**
 * Lightweight JWT Utility
 * PHP 8.3 Native Implementation using HMAC-SHA256
 */

define('JWT_SECRET_KEY', 'NewVeg_MHealth_Secure_JWT_Secret_Token_Key_2026'); // Can be moved to env/db config

function base64UrlEncode(string $data): string {
    return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
}

function base64UrlDecode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode(str_replace(['-', '_'], ['+', '/'], $data));
}

/**
 * Generate a JWT access token for a user
 */
function generateJWT(array $payload, int $expirySeconds = 2592000): string { // 30 days default
    $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']);
    
    $payload['iat'] = time();
    $payload['exp'] = time() + $expirySeconds;
    $payload_json = json_encode($payload);

    $base64UrlHeader = base64UrlEncode($header);
    $base64UrlPayload = base64UrlEncode($payload_json);

    $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET_KEY, true);
    $base64UrlSignature = base64UrlEncode($signature);

    return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
}

/**
 * Validate JWT from authorization header
 * Returns payload array on success, false on failure or expiration
 */
function validateJWT(string $token): array|false {
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return false;
    }

    list($base64UrlHeader, $base64UrlPayload, $base64UrlSignature) = $parts;

    $signature = base64UrlDecode($base64UrlSignature);
    $expectedSignature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET_KEY, true);

    if (!hash_equals($signature, $expectedSignature)) {
        return false; // Signature mismatch
    }

    $payload = json_decode(base64UrlDecode($base64UrlPayload), true);

    // Check expiration
    if (isset($payload['exp']) && $payload['exp'] < time()) {
        return false; // Token expired
    }

    return $payload;
}

/**
 * Get JWT token from HTTP Authorization header
 */
function getBearerToken(): ?string {
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
            return $matches[1];
        }
    }
    // Check capitalization variations or alternative environments
    foreach ($headers as $name => $value) {
        if (strcasecmp($name, 'Authorization') === 0) {
            if (preg_match('/Bearer\s(\S+)/', $value, $matches)) {
                return $matches[1];
            }
        }
    }
    return null;
}

/**
 * Require valid JWT authentication for an endpoint
 * Sets response code and exits on failure
 */
function requireAuth(): array {
    $token = getBearerToken();
    if (!$token) {
        header('Content-Type: application/json', true, 401);
        echo json_encode(['success' => false, 'message' => 'Authorization token is missing.']);
        exit;
    }

    $payload = validateJWT($token);
    if (!$payload) {
        header('Content-Type: application/json', true, 401);
        echo json_encode(['success' => false, 'message' => 'Token is invalid or expired.']);
        exit;
    }

    return $payload;
}
