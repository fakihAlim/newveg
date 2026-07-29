-- Migration: Gemini API Key Rotation & Logs
-- Optimized for MySQL/MariaDB (PHP 8.3+)

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `gemini_key_logs`;
DROP TABLE IF EXISTS `gemini_api_keys`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Table for encrypted Gemini API Keys
CREATE TABLE `gemini_api_keys` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `encrypted_key` TEXT NOT NULL,
  `used_today` INT DEFAULT 0,
  `total_used` INT DEFAULT 0,
  `daily_limit` INT DEFAULT 100,
  `is_active` TINYINT(1) DEFAULT 1,
  `last_used_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table for detailed API Key execution and failover logs
CREATE TABLE `gemini_key_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `key_id` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL, -- SUCCESS, ERROR_429, ERROR_OTHER
  `error_message` TEXT DEFAULT NULL,
  `execution_time_ms` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`key_id`) REFERENCES `gemini_api_keys`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
