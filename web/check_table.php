<?php
require_once __DIR__ . '/config/database.php';
$db = getDatabaseConnection();
$stmt = $db->query("DESCRIBE community_posts");
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
unlink(__FILE__);
