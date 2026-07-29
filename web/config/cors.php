<?php
/**
 * CORS and JSON Response Handler
 * PHP 8.3 Optimized
 */

// Allow from any origin (ideal for mHealth client apps/Flutter testing)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 86400"); // Cache preflight for 1 day

// Handle OPTIONS preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Standardized JSON Success Response
 */
function sendResponse(bool $success, string $message, array $data = [], int $statusCode = 200): void {
    header('Content-Type: application/json; charset=utf-8');
    http_response_code($statusCode);
    echo json_encode(array_merge([
        'success' => $success,
        'message' => $message
    ], $data), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

/**
 * Send standard HTTP JSON error response
 */
function sendError(string $message, int $statusCode = 400, array $extra = []): void {
    sendResponse(false, $message, $extra, $statusCode);
}

/**
 * Send standard HTTP JSON success response
 */
function sendSuccess(string $message, array $data = [], int $statusCode = 200): void {
    sendResponse(true, $message, $data, $statusCode);
}
