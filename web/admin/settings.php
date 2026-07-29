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

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle configuration updates
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

// Fetch settings from database
try {
    $settingsStmt = $db->query("SELECT * FROM system_settings ORDER BY setting_key ASC");
    $settings = $settingsStmt->fetchAll();
} catch (PDOException $e) {
    $settings = [];
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
                <h5 class="fw-bold mb-4"><i class="bi bi-sliders text-teal me-2" style="color: #06b6d4;"></i>Active Settings</h5>
                
                <form method="POST">
                    <?php if (empty($settings)): ?>
                        <p class="text-secondary">No configuration settings found in database.</p>
                    <?php else: ?>
                        <?php foreach ($settings as $setting): ?>
                            <div class="mb-4">
                                <label class="form-label text-white fw-semibold">
                                    <?= htmlspecialchars(str_replace('_', ' ', $setting['setting_key'])) ?>
                                    <span class="badge bg-secondary bg-opacity-10 text-secondary ms-2" style="font-size: 11px;"><?= htmlspecialchars($setting['setting_key']) ?></span>
                                </label>
                                
                                <?php if ($setting['setting_key'] === 'GEMINI_API_KEY'): ?>
                                    <div class="input-group">
                                        <span class="input-group-text bg-dark border-secondary border-opacity-10 text-secondary"><i class="bi bi-key-fill"></i></span>
                                        <input type="text" class="form-control" name="settings[<?= htmlspecialchars($setting['setting_key']) ?>]" value="<?= htmlspecialchars($setting['setting_value']) ?>" placeholder="AI API Key...">
                                    </div>
                                <?php elseif ($setting['setting_key'] === 'DAILY_FREE_SCAN_LIMIT'): ?>
                                    <div class="input-group" style="max-width: 250px;">
                                        <span class="input-group-text bg-dark border-secondary border-opacity-10 text-secondary"><i class="bi bi-hash"></i></span>
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
        </div>

        <!-- Details Help Box -->
        <div class="col-12 col-lg-4">
            <div class="glass-card p-4 mb-4">
                <h5 class="fw-bold mb-3"><i class="bi bi-info-circle text-teal me-2" style="color: #06b6d4;"></i>Integration Tips</h5>
                <p class="text-secondary fs-14">These variables are served dynamically to the Flutter client app through the public API path:</p>
                <code class="d-block p-2 bg-dark rounded border border-secondary border-opacity-10 text-teal mb-3" style="font-size: 13px;">GET /api/system/config.php</code>
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
