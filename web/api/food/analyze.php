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
    sendError('Image file is required and must upload successfully.');
}

$fileTmpPath = $_FILES['image']['tmp_name'];
$fileName = $_FILES['image']['name'];
$fileSize = $_FILES['image']['size'];
$fileType = $_FILES['image']['type'];

// Validate allowed image types
$allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($fileType, $allowedMimeTypes)) {
    sendError('Invalid image format. Allowed formats: JPEG, PNG, WEBP.');
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
    sendError('Analysis failed: ' . $e->getMessage(), 500);
}
