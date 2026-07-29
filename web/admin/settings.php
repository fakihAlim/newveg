<?php
/**
 * System Configuration Panel
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - System Settings";
$headerTitle = "System Configuration Panel";
$headerSubtitle = "Manage global variables, Gemini API integrations, and system restrictions";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/security.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle configuration updates for global variables
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['settings'])) {
    try {
        $db->beginTransaction();
        
        $stmt = $db->prepare("UPDATE system_settings SET setting_value = ? WHERE setting_key = ?");
        
        foreach ($_POST['settings'] as $key => $value) {
            $stmt->execute([trim($value), $key]);
        }
        
        $db->commit();
        $message = 'System configuration updated successfully!';
    } catch (PDOException $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        $error = 'Failed to save settings: ' . $e->getMessage();
    }
}

// Handle key rotation pool actions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] === 'add_key') {
        $newKey = trim($_POST['new_key'] ?? '');
        $limit = intval($_POST['daily_limit'] ?? 100);
        if (!empty($newKey)) {
            try {
                $encrypted = encrypt_key($newKey);
                $stmt = $db->prepare("INSERT INTO gemini_api_keys (encrypted_key, daily_limit) VALUES (?, ?)");
                $stmt->execute([$encrypted, $limit]);
                $message = 'New Gemini API key added to rotation pool successfully!';
            } catch (PDOException $e) {
                $error = 'Failed to add API key: ' . $e->getMessage();
            }
        } else {
            $error = 'API Key field cannot be empty.';
        }
    }
}

// Handle GET actions for key rotation pool
if (isset($_GET['action'])) {
    $action = $_GET['action'];
    $keyId = intval($_GET['id'] ?? 0);
    
    try {
        if ($action === 'toggle' && isset($_GET['status'])) {
            $status = intval($_GET['status']);
            $stmt = $db->prepare("UPDATE gemini_api_keys SET is_active = ? WHERE id = ?");
            $stmt->execute([$status, $keyId]);
            header("Location: settings.php?msg=Status updated");
            exit;
        } elseif ($action === 'reset') {
            $stmt = $db->prepare("UPDATE gemini_api_keys SET used_today = 0 WHERE id = ?");
            $stmt->execute([$keyId]);
            header("Location: settings.php?msg=Usage statistics reset");
            exit;
        } elseif ($action === 'delete') {
            $stmt = $db->prepare("DELETE FROM gemini_api_keys WHERE id = ?");
            $stmt->execute([$keyId]);
            header("Location: settings.php?msg=API key removed from pool");
            exit;
        }
    } catch (PDOException $e) {
        $error = 'Action failed: ' . $e->getMessage();
    }
}

if (isset($_GET['msg'])) {
    $message = trim($_GET['msg']);
}

// Fetch settings from database
try {
    $settingsStmt = $db->query("SELECT * FROM system_settings ORDER BY setting_key ASC");
    $settings = $settingsStmt->fetchAll();
} catch (PDOException $e) {
    $settings = [];
}

// Fetch Gemini API Keys from database
try {
    $keysStmt = $db->query("SELECT * FROM gemini_api_keys ORDER BY created_at DESC");
    $apiKeys = $keysStmt->fetchAll();
} catch (PDOException $e) {
    $apiKeys = [];
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

    <div class="row g-4">
        <!-- Configuration Editor -->
        <div class="col-12 col-lg-8">
            <div class="glass-card p-4">
                <h5 class="fw-bold mb-4"><i class="bi bi-sliders text-teal me-2" style="color: #0d9488;"></i>Active Settings</h5>
                
                <form method="POST">
                    <?php if (empty($settings)): ?>
                        <p class="text-secondary">No configuration settings found in database.</p>
                    <?php else: ?>
                        <?php foreach ($settings as $setting): ?>
                            <div class="mb-4">
                                <label class="form-label fw-semibold">
                                    <?= htmlspecialchars(str_replace('_', ' ', $setting['setting_key'])) ?>
                                    <span class="badge bg-secondary bg-opacity-10 text-secondary ms-2" style="font-size: 11px;"><?= htmlspecialchars($setting['setting_key']) ?></span>
                                </label>
                                
                                <?php if ($setting['setting_key'] === 'GEMINI_API_KEY'): ?>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-light-subtle text-secondary"><i class="bi bi-key-fill"></i></span>
                                        <input type="text" class="form-control" name="settings[<?= htmlspecialchars($setting['setting_key']) ?>]" value="<?= htmlspecialchars($setting['setting_value']) ?>" placeholder="AI API Key...">
                                    </div>
                                <?php elseif ($setting['setting_key'] === 'DAILY_FREE_SCAN_LIMIT'): ?>
                                    <div class="input-group" style="max-width: 250px;">
                                        <span class="input-group-text bg-light border-light-subtle text-secondary"><i class="bi bi-hash"></i></span>
                                        <input type="number" class="form-control" name="settings[<?= htmlspecialchars($setting['setting_key']) ?>]" value="<?= intval($setting['setting_value']) ?>">
                                    </div>
                                <?php else: ?>
                                    <input type="text" class="form-control" name="settings[<?= htmlspecialchars($setting['setting_key']) ?>]" value="<?= htmlspecialchars($setting['setting_value']) ?>">
                                <?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                        
                        <div class="mt-4 pt-3 border-top border-secondary border-opacity-10">
                            <button type="submit" class="btn btn-custom px-4"><i class="bi bi-save me-2"></i>Save Configurations</button>
                        </div>
                    <?php endif; ?>
                </form>
            </div>

            <!-- Gemini Key Rotation Pool Management -->
            <div class="glass-card p-4 mt-4">
                <h5 class="fw-bold mb-4"><i class="bi bi-key-fill text-teal me-2" style="color: #0d9488;"></i>Gemini API Key Rotation Pool</h5>
                
                <!-- Add Key Form -->
                <form method="POST" class="row g-3 align-items-end mb-4 pb-4 border-bottom border-light-subtle">
                    <input type="hidden" name="action" value="add_key">
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold">Add New API Key</label>
                        <input type="text" class="form-control" name="new_key" required placeholder="AIzaSy...">
                    </div>
                    <div class="col-12 col-md-3">
                        <label class="form-label fw-semibold">Daily Limit</label>
                        <input type="number" class="form-control" name="daily_limit" value="100" min="1" required>
                    </div>
                    <div class="col-12 col-md-3">
                        <button type="submit" class="btn btn-custom w-100"><i class="bi bi-plus-circle me-2"></i>Add to Pool</button>
                    </div>
                </form>

                <!-- Key List Table -->
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Decrypted Key (Masked)</th>
                                <th>Today Usage (Limit)</th>
                                <th>Total Usage</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($apiKeys)): ?>
                                <tr>
                                    <td colspan="5" class="text-center text-secondary py-4">No API keys in rotation pool. Add your first key above.</td>
                                </tr>
                            <?php else: ?>
                                <?php foreach ($apiKeys as $key): 
                                    $decrypted = decrypt_key($key['encrypted_key']);
                                    $masked = strlen($decrypted) > 10 ? substr($decrypted, 0, 8) . '...' . substr($decrypted, -4) : 'Decryption Failed';
                                    $percent = min(100, intval(($key['used_today'] / $key['daily_limit']) * 100));
                                    $barClass = $percent >= 90 ? 'bg-danger' : ($percent >= 75 ? 'bg-warning' : 'bg-success');
                                ?>
                                    <tr>
                                        <td>
                                            <code class="text-teal fw-bold" style="font-size: 13px; color: #0d9488;"><?= htmlspecialchars($masked) ?></code>
                                        </td>
                                        <td>
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <small class="fw-semibold"><?= intval($key['used_today']) ?> / <?= intval($key['daily_limit']) ?></small>
                                                <small class="text-secondary"><?= $percent ?>%</small>
                                            </div>
                                            <div class="progress" style="height: 6px; background-color: #e2e8f0;">
                                                <div class="progress-bar <?= $barClass ?>" role="progressbar" style="width: <?= $percent ?>%" aria-valuenow="<?= $percent ?>" aria-valuemin="0" aria-valuemax="100"></div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-semibold text-secondary" style="font-size: 13px;"><?= intval($key['total_used']) ?> scans</span>
                                        </td>
                                        <td>
                                            <?php if ($key['is_active'] == 1): ?>
                                                <a href="settings.php?action=toggle&id=<?= $key['id'] ?>&status=0" class="badge bg-emerald-glow px-2 py-1 text-decoration-none" style="font-size: 11px;">Active</a>
                                            <?php else: ?>
                                                <a href="settings.php?action=toggle&id=<?= $key['id'] ?>&status=1" class="badge bg-secondary bg-opacity-10 text-secondary px-2 py-1 text-decoration-none" style="font-size: 11px;">Inactive</a>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <a href="settings.php?action=reset&id=<?= $key['id'] ?>" class="btn btn-sm btn-outline-secondary me-1" title="Reset Today Usage"><i class="bi bi-arrow-counterclockwise"></i></a>
                                            <a href="settings.php?action=delete&id=<?= $key['id'] ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to remove this API key?')" title="Delete Key"><i class="bi bi-trash"></i></a>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Details Help Box -->
        <div class="col-12 col-lg-4">
            <div class="glass-card p-4 mb-4">
                <h5 class="fw-bold mb-3"><i class="bi bi-info-circle text-teal me-2" style="color: #0d9488;"></i>Integration Tips</h5>
                <p class="text-secondary fs-14">These variables are served dynamically to the Flutter client app through the public API path:</p>
                <code class="d-block p-2 bg-light rounded border border-light-subtle text-teal mb-3" style="font-size: 13px; color: #0d9488;">GET /api/system/config.php</code>
                <p class="text-secondary fs-14">Updating the <strong>Gemini API Key</strong> here changes the computer vision model behavior immediately in production without rebuilding or restarting Nginx/Apache.</p>
            </div>

            <div class="glass-card p-4">
                <h5 class="fw-bold mb-3 text-warning"><i class="bi bi-shield-lock-fill me-2"></i>Security Guard</h5>
                <p class="text-secondary fs-14">Never commit production API keys to Git. Keep them securely inside this dynamic database configuration panel or use environment overrides.</p>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
