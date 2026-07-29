<?php
/**
 * Dashboard Overview
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - Dashboard";
$headerTitle = "Dashboard Control Panel";
$headerSubtitle = "Real-time statistics & user behavior metrics";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();

try {
    // 1. Fetch KPI Counts
    $countUsers = $db->query("SELECT COUNT(*) FROM users")->fetchColumn();
    $countRecipes = $db->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
    $countLogs = $db->query("SELECT COUNT(*) FROM food_logs")->fetchColumn();
    $countQuizzes = $db->query("SELECT COUNT(*) FROM quizzes")->fetchColumn();

    // 2. Fetch Recent Registrations
    $recentUsersStmt = $db->prepare("SELECT email, full_name, ttm_stage, total_points, created_at FROM users ORDER BY id DESC LIMIT 5");
    $recentUsersStmt->execute();
    $recentUsers = $recentUsersStmt->fetchAll();

    // 3. Fetch Recent Food Logs
    $recentLogsStmt = $db->prepare("
        SELECT f.food_name, f.calories, f.is_compliant, f.created_at, u.full_name as user_name 
        FROM food_logs f
        JOIN users u ON f.user_id = u.id
        ORDER BY f.id DESC LIMIT 5
    ");
    $recentLogsStmt->execute();
    $recentLogs = $recentLogsStmt->fetchAll();

} catch (PDOException $e) {
    echo '<div class="alert alert-danger">Database error: ' . htmlspecialchars($e->getMessage()) . '</div>';
    exit;
}
?>

<div class="row g-4 animated-fade">
    <!-- Stat 1: Total Users -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="glass-card p-4 d-flex align-items-center justify-content-between">
            <div>
                <span class="text-secondary fw-semibold d-block mb-1">Total Users</span>
                <h3 class="fw-bold m-0 text-white"><?= number_format($countUsers) ?></h3>
            </div>
            <div class="stat-icon bg-teal-glow">
                <i class="bi bi-people"></i>
            </div>
        </div>
    </div>
    
    <!-- Stat 2: Total Recipes -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="glass-card p-4 d-flex align-items-center justify-content-between">
            <div>
                <span class="text-secondary fw-semibold d-block mb-1">Active Recipes</span>
                <h3 class="fw-bold m-0 text-white"><?= number_format($countRecipes) ?></h3>
            </div>
            <div class="stat-icon bg-emerald-glow">
                <i class="bi bi-book"></i>
            </div>
        </div>
    </div>

    <!-- Stat 3: Synced Logs -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="glass-card p-4 d-flex align-items-center justify-content-between">
            <div>
                <span class="text-secondary fw-semibold d-block mb-1">Food Scans / Logs</span>
                <h3 class="fw-bold m-0 text-white"><?= number_format($countLogs) ?></h3>
            </div>
            <div class="stat-icon bg-purple-glow">
                <i class="bi bi-egg-fried"></i>
            </div>
        </div>
    </div>

    <!-- Stat 4: Quizzes Available -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="glass-card p-4 d-flex align-items-center justify-content-between">
            <div>
                <span class="text-secondary fw-semibold d-block mb-1">Daily Quizzes</span>
                <h3 class="fw-bold m-0 text-white"><?= number_format($countQuizzes) ?></h3>
            </div>
            <div class="stat-icon bg-orange-glow">
                <i class="bi bi-patch-check"></i>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 mt-2 animated-fade">
    <!-- Recent Users Table -->
    <div class="col-12 col-xl-7">
        <div class="glass-card p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="m-0 fw-bold"><i class="bi bi-person-plus-fill text-teal me-2" style="color: #06b6d4;"></i>Recent Registrations</h5>
                <a href="users.php" class="btn btn-sm btn-secondary-custom py-1.5 px-3">View All</a>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>User Details</th>
                            <th>TTM Stage</th>
                            <th>Points</th>
                            <th>Joined</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentUsers)): ?>
                            <tr>
                                <td colspan="4" class="text-center text-secondary py-4">No users registered yet.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($recentUsers as $user): ?>
                                <tr>
                                    <td>
                                        <div class="fw-semibold text-white"><?= htmlspecialchars($user['full_name']) ?></div>
                                        <div class="text-secondary fs-12"><?= htmlspecialchars($user['email']) ?></div>
                                    </td>
                                    <td>
                                        <span class="badge bg-opacity-10 text-teal p-2" style="background-color: rgba(6, 182, 212, 0.1); border: 1px solid rgba(6, 182, 212, 0.2);">
                                            <?= htmlspecialchars($user['ttm_stage']) ?>
                                        </span>
                                    </td>
                                    <td class="text-white fw-bold"><?= number_format($user['total_points']) ?> pts</td>
                                    <td class="text-secondary fs-12"><?= date('M d, Y', strtotime($user['created_at'])) ?></td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Recent Food Logs Table -->
    <div class="col-12 col-xl-5">
        <div class="glass-card p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="m-0 fw-bold"><i class="bi bi-egg-fried text-emerald me-2" style="color: #10b981;"></i>Recent Food Logs</h5>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>User & Food</th>
                            <th>Calories</th>
                            <th>Type</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentLogs)): ?>
                            <tr>
                                <td colspan="3" class="text-center text-secondary py-4">No food items logged yet.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($recentLogs as $log): ?>
                                <tr>
                                    <td>
                                        <div class="fw-semibold text-white"><?= htmlspecialchars($log['food_name']) ?></div>
                                        <div class="text-secondary fs-12">by <?= htmlspecialchars($log['user_name']) ?></div>
                                    </td>
                                    <td class="text-white"><?= number_format($log['calories'], 0) ?> kcal</td>
                                    <td>
                                        <?php if ($log['is_compliant'] == 1): ?>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">Plant-Based</span>
                                        <?php else: ?>
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">Non-Compliant</span>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 mt-2 animated-fade mb-5">
    <!-- Server Performance Info -->
    <div class="col-12">
        <div class="glass-card p-4">
            <h5 class="mb-3 fw-bold"><i class="bi bi-cpu text-purple me-2" style="color: #a855f7;"></i>Environment & Low-Memory VPS Status</h5>
            <div class="row g-3">
                <div class="col-12 col-md-3">
                    <span class="text-secondary d-block fs-12">PHP Version</span>
                    <strong class="text-white"><?= PHP_VERSION ?></strong>
                </div>
                <div class="col-12 col-md-3">
                    <span class="text-secondary d-block fs-12">Server Software</span>
                    <strong class="text-white"><?= htmlspecialchars($_SERVER['SERVER_SOFTWARE'] ?? 'Nginx/Apache') ?></strong>
                </div>
                <div class="col-12 col-md-3">
                    <span class="text-secondary d-block fs-12">PHP Execution Limit</span>
                    <strong class="text-white"><?= ini_get('max_execution_time') ?>s</strong>
                </div>
                <div class="col-12 col-md-3">
                    <span class="text-secondary d-block fs-12">Database Version</span>
                    <strong class="text-white">MySQL (PDO Driver)</strong>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
