-- Database Schema for Plant-Based Diet mHealth Application
-- Optimized for MySQL / MariaDB (PHP 8.3 native compatible)

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `community_posts`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `quizzes`;
DROP TABLE IF EXISTS `myths_facts`;
DROP TABLE IF EXISTS `news`;
DROP TABLE IF EXISTS `recipes`;
DROP TABLE IF EXISTS `food_logs`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Users Table
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(191) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `gender` VARCHAR(20) DEFAULT NULL,
  `age` INT DEFAULT NULL,
  `height` DECIMAL(5,2) DEFAULT NULL, -- height in cm
  `weight` DECIMAL(5,2) DEFAULT NULL, -- weight in kg
  `diet_preference` VARCHAR(50) DEFAULT 'Vegan',
  `ttm_stage` VARCHAR(50) DEFAULT 'Precontemplation', -- Precontemplation, Contemplation, Preparation, Action, Maintenance
  `total_points` INT DEFAULT 0,
  `is_premium` TINYINT(1) DEFAULT 0,
  `is_admin` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Food Logs Table
CREATE TABLE `food_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `food_name` VARCHAR(255) NOT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `calories` DECIMAL(6,2) DEFAULT 0.00,
  `carbs` DECIMAL(6,2) DEFAULT 0.00,
  `fats` DECIMAL(6,2) DEFAULT 0.00,
  `protein` DECIMAL(6,2) DEFAULT 0.00,
  `is_compliant` TINYINT(1) DEFAULT 1,
  `points_earned` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Recipes Table
CREATE TABLE `recipes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `calories` DECIMAL(6,2) DEFAULT 0.00,
  `prep_time_mins` INT DEFAULT 0,
  `difficulty` VARCHAR(50) DEFAULT 'Easy',
  `ingredients_json` TEXT DEFAULT NULL, -- JSON formatted array
  `instructions_json` TEXT DEFAULT NULL, -- JSON formatted array
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. News / Articles Table
CREATE TABLE `news` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL,
  `category` VARCHAR(100) DEFAULT 'Nutrition',
  `image_url` VARCHAR(255) DEFAULT NULL,
  `published_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Myths & Facts Table
CREATE TABLE `myths_facts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `myth_text` TEXT NOT NULL,
  `truth_text` TEXT NOT NULL,
  `category` VARCHAR(100) DEFAULT 'Nutrition'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Quizzes Table
CREATE TABLE `quizzes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `question` TEXT NOT NULL,
  `option_a` VARCHAR(255) NOT NULL,
  `option_b` VARCHAR(255) NOT NULL,
  `option_c` VARCHAR(255) NOT NULL,
  `option_d` VARCHAR(255) NOT NULL,
  `correct_option` CHAR(1) NOT NULL, -- A, B, C, or D
  `explanation` TEXT DEFAULT NULL,
  `points_reward` INT DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. System Settings Table
CREATE TABLE `system_settings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `setting_key` VARCHAR(100) NOT NULL UNIQUE,
  `setting_value` TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Community Posts Table
CREATE TABLE `community_posts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `food_log_id` INT DEFAULT NULL,
  `caption` TEXT DEFAULT NULL,
  `likes_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`food_log_id`) REFERENCES `food_logs`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Comments Table
CREATE TABLE `comments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `post_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `comment_text` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`post_id`) REFERENCES `community_posts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Seed Data
-- Default System Settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`) VALUES
('GEMINI_API_KEY', 'YOUR_GEMINI_API_KEY_HERE'),
('DAILY_FREE_SCAN_LIMIT', '5'),
('APP_NAME', 'NewVeg Plant-Based App');

-- Default Admin User (Password is 'admin123')
-- Hashed using password_hash('admin123', PASSWORD_BCRYPT)
INSERT INTO `users` (`email`, `password`, `full_name`, `gender`, `age`, `height`, `weight`, `diet_preference`, `ttm_stage`, `total_points`, `is_premium`, `is_admin`) VALUES
('admin@aa.com', '$2y$10$fxCz/mipMz1WkBhirmm1o.0aCjYmEEaHMhdShzqtZfxNcXNehTn8u', 'System Administrator', 'Male', 30, 175.00, 70.00, 'Vegan', 'Maintenance', 100, 1, 1),
('user@newveg.com', '$2y$10$fxCz/mipMz1WkBhirmm1o.0aCjYmEEaHMhdShzqtZfxNcXNehTn8u', 'John Doe', 'Male', 25, 180.00, 75.00, 'Vegetarian', 'Preparation', 50, 0, 0);

-- Initial Recipes
INSERT INTO `recipes` (`title`, `description`, `image_url`, `calories`, `prep_time_mins`, `difficulty`, `ingredients_json`, `instructions_json`) VALUES
('Avocado Toast with Chickpeas', 'A quick, simple, and high-protein plant-based breakfast.', 'uploads/recipes/avocado_toast.jpg', 320.00, 10, 'Easy', 
 '["1 slice of whole-grain bread", "1/2 ripe avocado", "1/4 cup canned chickpeas, drained and rinsed", "Pinch of red pepper flakes", "Salt and pepper to taste"]', 
 '["Toast the slice of bread to your liking.", "Mash the avocado on the toast and spread evenly.", "Top with chickpeas and gently press them down.", "Season with salt, pepper, and red pepper flakes."]');

-- Initial News
INSERT INTO `news` (`title`, `content`, `category`, `image_url`) VALUES
('5 Benefits of a Plant-Based Diet', 'Research shows that shifting to a plant-based diet can lower your cholesterol, reduce your carbon footprint, improve cardiovascular health, lower blood sugar levels, and help manage weight.', 'Nutrition', 'uploads/news/benefits.jpg');

-- Initial Myths vs Facts
INSERT INTO `myths_facts` (`myth_text`, `truth_text`, `category`) VALUES
('Plant-based diets lack protein.', 'Plants like lentils, chickpeas, tofu, tempeh, quinoa, and green peas contain rich amounts of high-quality protein. It is easy to meet daily protein goals on a varied plant-based diet.', 'Protein');

-- Initial Quizzes
INSERT INTO `quizzes` (`question`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `explanation`, `points_reward`) VALUES
('Which of the following plant foods has the highest protein content per 100g?', 'Lentils', 'Tofu', 'Tempeh', 'Quinoa', 'C', 'Tempeh typically contains around 19g of protein per 100g, which is higher than lentils (9g), tofu (8g), and quinoa (4.4g).', 15);

-- 11. UGC Moderation / Reports Table
CREATE TABLE IF NOT EXISTS `community_reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `post_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `reason` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`post_id`) REFERENCES `community_posts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Blocked Users Table
CREATE TABLE IF NOT EXISTS `blocked_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `blocked_user_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_block` (`user_id`, `blocked_user_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`blocked_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
