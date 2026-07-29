<?php
/**
 * User Directory & TTM Stage Viewer
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - Users Directory";
$headerTitle = "Registered Users Directory";
$headerSubtitle = "Track user progress, rewards points, and Transtheoretical Model (TTM) stages";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle actions (Toggle Premium or Admin)
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = intval($_GET['id']);
    $action = $_GET['action'];
    
    // Prevent self-demotion
    if ($id === intval($_SESSION['admin_user_id']) && $action === 'toggle_admin') {
        $error = 'You cannot revoke your own administrator privileges.';
    } else {
        try {
            if ($action === 'toggle_premium') {
                $stmt = $db->prepare("UPDATE users SET is_premium = 1 - is_premium WHERE id = ?");
                $stmt->execute([$id]);
                $message = 'User premium status updated successfully!';
            } elseif ($action === 'toggle_admin') {
                $stmt = $db->prepare("UPDATE users SET is_admin = 1 - is_admin WHERE id = ?");
                $stmt->execute([$id]);
                $message = 'User administrator privileges toggled successfully!';
            }
        } catch (PDOException $e) {
            $error = 'Action failed: ' . $e->getMessage();
        }
    }
}

// Fetch all users
try {
    $users = $db->query("SELECT * FROM users ORDER BY id DESC")->fetchAll();
} catch (PDOException $e) {
    $users = [];
}
?>

<div class="animated-fade mb-5">
    
    <?php if (!empty($message)): ?>
        <div class="alert alert-success border-0 bg-success bg-opacity-10 text-success p-3 mb-4 rounded-3 d-flex align-items-center">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div><?= htmlspecialchars($message) ?></div>
        </div>
    <?php endif; ?>

    <?php if (!empty($error)): ?>
        <div class="alert alert-danger border-0 bg-danger bg-opacity-10 text-danger p-3 mb-4 rounded-3 d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div><?= htmlspecialchars($error) ?></div>
        </div>
    <?php endif; ?>

    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>User Profile</th>
                        <th>Metrics (Age/Ht/Wt)</th>
                        <th>Diet Pref</th>
                        <th>TTM Stage</th>
                        <th>Points</th>
                        <th>Access Level</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($users)): ?>
                        <tr>
                            <td colspan="7" class="text-center text-secondary py-5">No registered users found.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($users as $user): ?>
                            <tr>
                                <td>
                                    <div class="fw-semibold text-white fs-5"><?= htmlspecialchars($user['full_name']) ?></div>
                                    <div class="text-secondary fs-13"><?= htmlspecialchars($user['email']) ?></div>
                                    <div class="text-secondary fs-11 mt-0.5">Registered: <?= date('M d, Y', strtotime($user['created_at'])) ?></div>
                                </td>
                                <td>
                                    <div class="text-white fs-13">
                                        Gender: <strong class="text-secondary"><?= htmlspecialchars($user['gender'] ?? 'N/A') ?></strong><br>
                                        Age: <strong class="text-secondary"><?= $user['age'] ? intval($user['age']) . ' yrs' : 'N/A' ?></strong><br>
                                        Ht/Wt: <strong class="text-secondary"><?= $user['height'] ? floatval($user['height']) . 'cm' : 'N/A' ?></strong> / 
                                        <strong class="text-secondary"><?= $user['weight'] ? floatval($user['weight']) . 'kg' : 'N/A' ?></strong>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-opacity-10 text-teal p-2" style="background-color: rgba(6, 182, 212, 0.1); border: 1px solid rgba(6, 182, 212, 0.2);">
                                        <?= htmlspecialchars($user['diet_preference'] ?? 'Vegan') ?>
                                    </span>
                                </td>
                                <td>
                                    <?php 
                                    $stage = $user['ttm_stage'];
                                    $badgeClass = 'bg-secondary';
                                    if ($stage === 'Maintenance') $badgeClass = 'bg-success';
                                    elseif ($stage === 'Action') $badgeClass = 'bg-primary';
                                    elseif ($stage === 'Preparation') $badgeClass = 'bg-info';
                                    elseif ($stage === 'Contemplation') $badgeClass = 'bg-warning text-dark';
                                    ?>
                                    <span class="badge <?= $badgeClass ?> p-2"><?= htmlspecialchars($stage) ?></span>
                                </td>
                                <td class="text-white fw-bold fs-5">
                                    <i class="bi bi-star-fill text-warning me-1"></i><?= number_format($user['total_points']) ?>
                                </td>
                                <td>
                                    <div class="d-flex flex-column gap-1">
                                        <?php if ($user['is_premium'] == 1): ?>
                                            <span class="badge bg-emerald-glow badge-glow text-center py-1">Premium PRO</span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary bg-opacity-10 text-secondary text-center py-1">Free Tier</span>
                                        <?php endif; ?>
                                        
                                        <?php if ($user['is_admin'] == 1): ?>
                                            <span class="badge bg-purple-glow badge-glow text-center py-1">Administrator</span>
                                        <?php endif; ?>
                                    </div>
                                </td>
                                <td class="text-end">
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-secondary-custom dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            Manage Access
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-dark border-secondary border-opacity-15 bg-dark">
                                            <li>
                                                <a class="dropdown-item fs-14 py-2" href="users.php?action=toggle_premium&id=<?= $user['id'] ?>">
                                                    <i class="bi <?= $user['is_premium'] == 1 ? 'bi-star' : 'bi-star-fill text-warning' ?> me-2"></i>
                                                    <?= $user['is_premium'] == 1 ? 'Downgrade to Free' : 'Grant Premium PRO' ?>
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item fs-14 py-2" href="users.php?action=toggle_admin&id=<?= $user['id'] ?>">
                                                    <i class="bi <?= $user['is_admin'] == 1 ? 'bi-shield-slash' : 'bi-shield-fill text-teal' ?> me-2"></i>
                                                    <?= $user['is_admin'] == 1 ? 'Revoke Admin role' : 'Make Administrator' ?>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
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
