<?php
/**
 * Smart Gemini API Key Rotation & Load Balancing Service
 * Optimized for Gemini 3.6 Flash Model
 * PHP 8.3+ Native Compatible
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/security.php';

class GeminiService {
  private PDO $db;
  private string $model = 'gemini-3.6-flash';

  public function __construct() {
    $this->db = getDatabaseConnection();
  }

  /**
   * Run content generation request using the best available rotated key
   */
  public function generateFoodAnalysis(string $base64Image, string $mimeType): array {
    $retries = 3;
    $attempt = 0;
    
    // System instruction prompt forcing structured JSON outputs
    $prompt = "You are an AI nutritionist. Analyze this food image and estimate its nutritional values in Indonesian language. "
            . "Respond ONLY with the following JSON format, without markdown fences or text formatting:\n"
            . "{\n"
            . "  \"foodName\": \"Nama Makanan\",\n"
            . "  \"calories\": 0,\n"
            . "  \"carbs\": 0,\n"
            . "  \"fats\": 0,\n"
            . "  \"protein\": 0,\n"
            . "  \"isPlantBased\": true,\n"
            . "  \"description\": \"Detailed description in Indonesian language\"\n"
            . "}";

    while ($attempt < $retries) {
      $attempt++;
      
      // 1. Fetch key using Load Balancing logic (least used first)
      $stmt = $this->db->prepare("
        SELECT id, encrypted_key, used_today, daily_limit 
        FROM gemini_api_keys 
        WHERE is_active = 1 AND used_today < daily_limit 
        ORDER BY used_today ASC 
        LIMIT 1
      ");
      $stmt->execute();
      $keyRow = $stmt->fetch();

      if (!$keyRow) {
        throw new Exception("All Gemini API keys have exceeded their daily scan quota limits.");
      }

      $keyId = $keyRow['id'];
      $decryptedKey = decrypt_key($keyRow['encrypted_key']);
      
      $startTime = microtime(true);
      
      // 2. Call Gemini API endpoint
      $url = "https://generativelanguage.googleapis.com/v1beta/models/{$this->model}:generateContent?key={$decryptedKey}";
      
      $payload = [
        "contents" => [
          [
            "parts" => [
              ["text" => $prompt],
              [
                "inlineData" => [
                  "mimeType" => $mimeType,
                  "data" => $base64Image
                ]
              ]
            ]
          ]
        ],
        "generationConfig" => [
          "responseMimeType" => "application/json"
        ]
      ];

      $ch = curl_init($url);
      curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
      curl_setopt($ch, CURLOPT_POST, true);
      curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
      curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
      curl_setopt($ch, CURLOPT_TIMEOUT, 30);
      
      $response = curl_exec($ch);
      $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
      curl_close($ch);
      
      $endTime = microtime(true);
      $executionTimeMs = (int)(($endTime - $startTime) * 1000);

      // 3. Handle quota limit / HTTP 429
      if ($httpCode === 429) {
        // Flag key logs
        $logStmt = $this->db->prepare("
          INSERT INTO gemini_key_logs (key_id, status, error_message, execution_time_ms) 
          VALUES (?, 'ERROR_429', '429 Quota Exceeded from API provider', ?)
        ");
        $logStmt->execute([$keyId, $executionTimeMs]);
        
        // Push key usage to daily limit to skip it in next query
        $updateLimitStmt = $this->db->prepare("UPDATE gemini_api_keys SET used_today = daily_limit WHERE id = ?");
        $updateLimitStmt->execute([$keyId]);
        
        // Loop and try next key
        continue;
      }

      // 4. Handle other error codes
      if ($httpCode !== 200 || !$response) {
        $errorMsg = $response ? "API Error (HTTP $httpCode): " . $response : "API Connection timeout/failure";
        $logStmt = $this->db->prepare("
          INSERT INTO gemini_key_logs (key_id, status, error_message, execution_time_ms) 
          VALUES (?, 'ERROR_OTHER', ?, ?)
        ");
        $logStmt->execute([$keyId, substr($errorMsg, 0, 500), $executionTimeMs]);
        
        // Try next key if it's potentially an API key issue, or fail on last retry
        if ($attempt < $retries) {
          continue;
        }
        throw new Exception("Gemini API call failed with response code $httpCode: $response");
      }

      // 5. On Success
      $responseData = json_decode($response, true);
      
      // Verify response structure
      if (!isset($responseData['candidates'][0]['content']['parts'][0]['text'])) {
        $logStmt = $this->db->prepare("
          INSERT INTO gemini_key_logs (key_id, status, error_message, execution_time_ms) 
          VALUES (?, 'ERROR_OTHER', 'Invalid API response candidates payload structure', ?)
        ");
        $logStmt->execute([$keyId, $executionTimeMs]);
        throw new Exception("Gemini API returned an invalid response structure: " . $response);
      }

      // Increment usage metrics
      $updateStmt = $this->db->prepare("
        UPDATE gemini_api_keys 
        SET used_today = used_today + 1, total_used = total_used + 1, last_used_at = CURRENT_TIMESTAMP 
        WHERE id = ?
      ");
      $updateStmt->execute([$keyId]);

      // Log success statistics
      $logStmt = $this->db->prepare("
        INSERT INTO gemini_key_logs (key_id, status, execution_time_ms) 
        VALUES (?, 'SUCCESS', ?)
      ");
      $logStmt->execute([$keyId, $executionTimeMs]);

      $rawText = $responseData['candidates'][0]['content']['parts'][0]['text'];
      
      // Clean up markdown markers if any
      $cleanJson = trim(str_replace(['```json', '```'], '', $rawText));
      return json_decode($cleanJson, true) ?: [];
    }

    throw new Exception("API query attempts failed after $retries retries due to quota limits or errors.");
  }
}
