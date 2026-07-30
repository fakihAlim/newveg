<?php
/**
 * Food Image Analysis Endpoint using Rotated Gemini API Keys
 * POST /api/food/analyze.php
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../services/gemini_service.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed. Use POST.', 405);
}

// Check if image file was uploaded
if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    $fileError = $_FILES['image']['error'] ?? UPLOAD_ERR_NO_FILE;
    switch ($fileError) {
        case UPLOAD_ERR_INI_SIZE:
            $errorMsg = 'Image file exceeds the upload_max_filesize directive in php.ini.';
            break;
        case UPLOAD_ERR_FORM_SIZE:
            $errorMsg = 'Image file exceeds the MAX_FILE_SIZE directive specified in the HTML form.';
            break;
        case UPLOAD_ERR_PARTIAL:
            $errorMsg = 'Image file was only partially uploaded.';
            break;
        case UPLOAD_ERR_NO_FILE:
            $errorMsg = 'No image file was uploaded.';
            break;
        case UPLOAD_ERR_NO_TMP_DIR:
            $errorMsg = 'Missing a temporary folder on the server.';
            break;
        case UPLOAD_ERR_CANT_WRITE:
            $errorMsg = 'Failed to write image file to disk.';
            break;
        default:
            $errorMsg = 'Unknown upload error occurred (Code: ' . $fileError . ').';
            break;
    }
    sendError($errorMsg);
}

$fileTmpPath = $_FILES['image']['tmp_name'];
$fileName = $_FILES['image']['name'];
$fileSize = $_FILES['image']['size'];

// Detect MIME type securely on the server
$fileType = null;
if (function_exists('finfo_open')) {
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $fileType = finfo_file($finfo, $fileTmpPath);
    finfo_close($finfo);
} elseif (function_exists('mime_content_type')) {
    $fileType = mime_content_type($fileTmpPath);
}

// Fallback to client-provided type or extension check if server detection fails
if (!$fileType || $fileType === 'application/octet-stream') {
    $fileType = $_FILES['image']['type'] ?? '';
    
    // Check extension as final fallback
    $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
    if ($ext === 'jpg' || $ext === 'jpeg') {
        $fileType = 'image/jpeg';
    } elseif ($ext === 'png') {
        $fileType = 'image/png';
    } elseif ($ext === 'webp') {
        $fileType = 'image/webp';
    }
}

// Validate allowed image types
$allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($fileType, $allowedMimeTypes)) {
    sendError('Invalid image format. Allowed formats: JPEG, PNG, WEBP. Detected: ' . htmlspecialchars($fileType));
}

// Limit image upload size (e.g. 5MB maximum for Gemini vision inputs)
if ($fileSize > 5 * 1024 * 1024) {
    sendError('Image size exceeds maximum limit of 5MB.');
}

try {
    // Read and encode image to base64
    $imageData = file_get_contents($fileTmpPath);
    if ($imageData === false) {
        throw new Exception("Failed to read uploaded image bytes.");
    }
    
    $base64Image = base64_encode($imageData);
    
    // Call Rotation Gemini Service
    $gemini = new GeminiService();
    $analysisResult = $gemini->generateFoodAnalysis($base64Image, $fileType);

    if (empty($analysisResult)) {
        throw new Exception("Gemini analysis returned empty or invalid nutritional response.");
    }

    sendSuccess('Food image analyzed successfully.', [
        'data' => $analysisResult
    ]);

} catch (Exception $e) {
    // Write error log for remote debugging
    $logMessage = "[" . date('Y-m-d H:i:s') . "] " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n\n";
    @file_put_contents(__DIR__ . '/error_log.txt', $logMessage, FILE_APPEND);
    sendError('Analysis failed: ' . $e->getMessage(), 500);
}
