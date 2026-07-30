<?php
require_once __DIR__ . '/config/database.php';
$db = getDatabaseConnection();

$db->exec("
    CREATE TABLE IF NOT EXISTS `community_reports` (
      `id` INT AUTO_INCREMENT PRIMARY KEY,
      `post_id` INT NOT NULL,
      `user_id` INT NOT NULL,
      `reason` VARCHAR(255) NOT NULL,
      `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (`post_id`) REFERENCES `community_posts`(`id`) ON DELETE CASCADE,
      FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
");

$db->exec("
    CREATE TABLE IF NOT EXISTS `blocked_users` (
      `id` INT AUTO_INCREMENT PRIMARY KEY,
      `user_id` INT NOT NULL,
      `blocked_user_id` INT NOT NULL,
      `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY `unique_block` (`user_id`, `blocked_user_id`),
      FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
      FOREIGN KEY (`blocked_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
");

echo "Tables created successfully.\n";
unlink(__FILE__);
