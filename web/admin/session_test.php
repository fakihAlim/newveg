<?php
/**
 * PHP Session Diagnostic Script
 */
session_start();

if (!isset($_SESSION['test_counter'])) {
    $_SESSION['test_counter'] = 1;
} else {
    $_SESSION['test_counter']++;
}

echo "<h3>PHP Session Diagnostic</h3>";
echo "Session counter: <b>" . $_SESSION['test_counter'] . "</b> (Refresh to test if it increments)<br>";
echo "Session ID: <b>" . session_id() . "</b><br>";
$savePath = session_save_path();
echo "Session save path: <b>" . ($savePath ?: 'Default/Empty') . "</b><br>";
$testPath = $savePath ?: sys_get_temp_dir();
echo "Session save path writable: <b>" . (is_writable($testPath) ? '<span style="color:green;">Yes</span>' : '<span style="color:red;">No</span>') . "</b> (Tested path: $testPath)<br>";
echo "Cookie Params: <pre>";
print_r(session_get_cookie_params());
echo "</pre>";
