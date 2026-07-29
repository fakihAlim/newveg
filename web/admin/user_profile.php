<?php
/**
 * User Profiling Details Page
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - User Profiling";
$headerTitle = "User Profiling Dashboard";
$headerSubtitle = "Detailed nutritional history, demographics, and behavioral profiling";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$userId = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Fetch user data
try {
    $stmt = $db->prepare("SELECT * FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
} catch (PDOException $e) {
    $user = null;
}

if (!$user) {
    echo '<div class="alert alert-danger border-0 bg-danger bg-opacity-10 text-danger p-3 mb-4 rounded-3 d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>User not found or database query failed.</div>
          </div>';
    echo '<a href="users.php" class="btn btn-custom"><i class="bi bi-arrow-left me-2"></i>Back to Users Directory</a>';
    require_once __DIR__ . '/includes/footer.php';
    exit;
}

// Fetch user's food logs
try {
    $logsStmt = $db->prepare("SELECT * FROM food_logs WHERE user_id = ? ORDER BY id DESC");
    $logsStmt->execute([$userId]);
    $logs = $logsStmt->fetchAll();
} catch (PDOException $e) {
    $logs = [];
}

// Calculate Stats
$totalLogs = count($logs);
$totalCalories = 0;
$compliantLogs = 0;
$totalProtein = 0;
$totalCarbs = 0;
$totalFats = 0;

foreach ($logs as $log) {
    $totalCalories += floatval($log['calories']);
    $totalProtein += floatval($log['protein'] ?? 0);
    $totalCarbs += floatval($log['carbs'] ?? 0);
    $totalFats += floatval($log['fats'] ?? 0);
    if ($log['is_compliant'] == 1) {
        $compliantLogs++;
    }
}

$avgCalories = $totalLogs > 0 ? $totalCalories / $totalLogs : 0;
$complianceRate = $totalLogs > 0 ? ($compliantLogs / $totalLogs) * 100 : 0;

// BMI Calculation
$bmi = 'N/A';
$bmiClass = '';
$bmiCategory = 'N/A';
if ($user['height'] && $user['weight']) {
    $heightInM = floatval($user['height']) / 100;
    if ($heightInM > 0) {
        $bmiVal = floatval($user['weight']) / ($heightInM * $heightInM);
        $bmi = number_format($bmiVal, 1);
        if ($bmiVal < 18.5) {
            $bmiCategory = 'Underweight';
            $bmiClass = 'text-warning';
        } elseif ($bmiVal < 25) {
            $bmiCategory = 'Normal';
            $bmiClass = 'text-success';
        } elseif ($bmiVal < 30) {
            $bmiCategory = 'Overweight';
            $bmiClass = 'text-warning';
        } else {
            $bmiCategory = 'Obese';
            $bmiClass = 'text-danger';
        }
    }
}
?>

<div class="animated-fade mb-5">
    
    <div class="mb-4">
        <a href="users.php" class="btn btn-secondary-custom py-1.5"><i class="bi bi-arrow-left me-2"></i>Back to Users Directory</a>
    </div>

    <!-- User Header Card -->
    <div class="glass-card p-4 mb-4">
        <div class="row align-items-center g-3">
            <div class="col-12 col-md-auto">
                <div class="rounded-circle bg-teal-glow d-flex align-items-center justify-content-center" style="width: 72px; height: 72px;">
                    <i class="bi bi-person-fill fs-1"></i>
                </div>
            </div>
            <div class="col-12 col-md">
                <div class="d-flex align-items-center flex-wrap gap-2 mb-1">
                    <h3 class="fw-bold m-0"><?= htmlspecialchars($user['full_name']) ?></h3>
                    <?php if ($user['is_premium'] == 1): ?>
                        <span class="badge bg-emerald-glow badge-glow">Premium PRO</span>
                    <?php else: ?>
                        <span class="badge bg-secondary bg-opacity-10 text-secondary">Free Tier</span>
                    <?php endif; ?>
                    <?php if ($user['is_admin'] == 1): ?>
                        <span class="badge bg-purple-glow badge-glow">Admin</span>
                    <?php endif; ?>
                </div>
                <p class="text-secondary m-0 fs-14">
                    <span class="me-3"><i class="bi bi-envelope me-1"></i><?= htmlspecialchars($user['email']) ?></span>
                    <span><i class="bi bi-calendar-check me-1"></i>Joined <?= date('F d, Y', strtotime($user['created_at'])) ?></span>
                </p>
            </div>
            <div class="col-12 col-md-auto text-md-end">
                <span class="text-secondary d-block fs-12 fw-semibold">GAMIFICATION WALLET</span>
                <h2 class="fw-bold text-teal m-0" style="color: #0d9488;"><i class="bi bi-star-fill text-warning me-1"></i><?= number_format($user['total_points']) ?> <span class="fs-14 text-secondary">pts</span></h2>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Demographics & Health Profile -->
        <div class="col-12 col-lg-4">
            <div class="glass-card p-4 h-100">
                <h5 class="fw-bold mb-4 border-bottom border-light-subtle pb-2"><i class="bi bi-clipboard2-pulse text-teal me-2" style="color: #0d9488;"></i>Health & Demographic Profile</h5>
                
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Gender</span>
                    <strong class="fs-15"><?= htmlspecialchars($user['gender'] ?? 'Not Specified') ?></strong>
                </div>
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Age</span>
                    <strong class="fs-15"><?= $user['age'] ? intval($user['age']) . ' years old' : 'Not Specified' ?></strong>
                </div>
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Height & Weight</span>
                    <strong class="fs-15"><?= $user['height'] ? floatval($user['height']) . ' cm' : 'N/A' ?> / <?= $user['weight'] ? floatval($user['weight']) . ' kg' : 'N/A' ?></strong>
                </div>
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Body Mass Index (BMI)</span>
                    <strong class="fs-15 <?= $bmiClass ?>"><?= $bmi ?></strong>
                    <?php if ($bmiCategory !== 'N/A'): ?>
                        <span class="badge bg-light border border-light-subtle text-secondary ms-2" style="font-size: 11px;"><?= $bmiCategory ?></span>
                    <?php endif; ?>
                </div>
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Dietary Preference</span>
                    <span class="badge bg-opacity-10 text-teal mt-1 p-2" style="background-color: rgba(6, 182, 212, 0.1); border: 1px solid rgba(6, 182, 212, 0.2);">
                        <?= htmlspecialchars($user['diet_preference'] ?? 'Vegan') ?>
                    </span>
                </div>
                <div class="mb-3">
                    <span class="text-secondary d-block fs-12">Transtheoretical Model (TTM) Stage</span>
                    <?php 
                    $stage = $user['ttm_stage'];
                    $badgeClass = 'bg-secondary';
                    if ($stage === 'Maintenance') $badgeClass = 'bg-success';
                    elseif ($stage === 'Action') $badgeClass = 'bg-primary';
                    elseif ($stage === 'Preparation') $badgeClass = 'bg-info';
                    elseif ($stage === 'Contemplation') $badgeClass = 'bg-warning text-dark';
                    ?>
                    <span class="badge <?= $badgeClass ?> mt-1 p-2" style="font-size: 13px;"><?= htmlspecialchars($stage) ?></span>
                </div>
            </div>
        </div>

        <!-- Food Scans & Nutritional Metrics Summary -->
        <div class="col-12 col-lg-8">
            <div class="glass-card p-4 h-100">
                <h5 class="fw-bold mb-4 border-bottom border-light-subtle pb-2"><i class="bi bi-activity text-teal me-2" style="color: #0d9488;"></i>Nutritional Summary & Statistics</h5>
                
                <div class="row g-4 mb-4">
                    <div class="col-6 col-sm-3 text-center border-end border-light-subtle">
                        <span class="text-secondary d-block fs-12 mb-1">Total Scans</span>
                        <h2 class="fw-bold text-dark m-0"><?= $totalLogs ?></h2>
                    </div>
                    <div class="col-6 col-sm-3 text-center border-end border-light-subtle">
                        <span class="text-secondary d-block fs-12 mb-1">Avg Calories</span>
                        <h2 class="fw-bold text-dark m-0"><?= number_format($avgCalories, 0) ?> <span class="fs-12 text-secondary">kcal</span></h2>
                    </div>
                    <div class="col-6 col-sm-3 text-center border-end border-light-subtle">
                        <span class="text-secondary d-block fs-12 mb-1">Compliance Rate</span>
                        <h2 class="fw-bold text-teal m-0" style="color: #0d9488;"><?= number_format($complianceRate, 1) ?>%</h2>
                    </div>
                    <div class="col-6 col-sm-3 text-center">
                        <span class="text-secondary d-block fs-12 mb-1">Compliant Meals</span>
                        <h2 class="fw-bold text-success m-0"><?= $compliantLogs ?></h2>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Accumulated Macro Intake (Logged)</h6>
                <div class="row g-3">
                    <div class="col-4">
                        <div class="p-3 bg-light border border-light-subtle rounded-3 text-center">
                            <span class="text-secondary d-block fs-11">Total Protein</span>
                            <strong class="fs-15 text-primary"><?= number_format($totalProtein, 1) ?> g</strong>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="p-3 bg-light border border-light-subtle rounded-3 text-center">
                            <span class="text-secondary d-block fs-11">Total Carbs</span>
                            <strong class="fs-15 text-success"><?= number_format($totalCarbs, 1) ?> g</strong>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="p-3 bg-light border border-light-subtle rounded-3 text-center">
                            <span class="text-secondary d-block fs-11">Total Fats</span>
                            <strong class="fs-15 text-warning"><?= number_format($totalFats, 1) ?> g</strong>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Detailed User Food Log History -->
    <div class="glass-card p-4 mt-4">
        <h5 class="fw-bold mb-4"><i class="bi bi-journal-text text-teal me-2" style="color: #0d9488;"></i>User Food Log History</h5>
        
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>Date & Time</th>
                        <th>Meal / Food Name</th>
                        <th>Calories</th>
                        <th>Macros (P / C / F)</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($logs)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">This user has not logged any meals yet.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($logs as $log): ?>
                            <tr>
                                <td>
                                    <span class="fw-semibold text-secondary" style="font-size: 13px;"><?= date('M d, Y H:i', strtotime($log['created_at'])) ?></span>
                                </td>
                                <td>
                                    <span class="fw-bold"><?= htmlspecialchars($log['food_name']) ?></span>
                                </td>
                                <td>
                                    <strong class="text-dark"><?= number_format($log['calories'], 0) ?> kcal</strong>
                                </td>
                                <td>
                                    <span class="badge bg-light border border-light-subtle text-secondary px-2">
                                        P: <?= number_format($log['protein'] ?? 0, 1) ?>g
                                    </span>
                                    <span class="badge bg-light border border-light-subtle text-secondary px-2">
                                        C: <?= number_format($log['carbs'] ?? 0, 1) ?>g
                                    </span>
                                    <span class="badge bg-light border border-light-subtle text-secondary px-2">
                                        F: <?= number_format($log['fats'] ?? 0, 1) ?>g
                                    </span>
                                </td>
                                <td>
                                    <?php if ($log['is_compliant'] == 1): ?>
                                        <span class="badge bg-success-subtle text-success border border-success-subtle">Plant-Based</span>
                                    <?php else: ?>
                                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle">Non-Compliant</span>
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

<?php require_once __DIR__ . '/includes/footer.php'; ?>
