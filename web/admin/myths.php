<?php
/**
 * Myths & Facts CRUD Manager
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - Myths & Facts";
$headerTitle = "Myths vs Facts Control Room";
$headerSubtitle = "Address common misconceptions with verified scientific facts";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle Actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action']) && $_POST['action'] === 'add') {
        $myth = trim($_POST['myth_text'] ?? '');
        $truth = trim($_POST['truth_text'] ?? '');
        $category = trim($_POST['category'] ?? 'General');

        if (empty($myth) || empty($truth)) {
            $error = 'Both Myth and Fact explanation are required.';
        } else {
            try {
                $stmt = $db->prepare("INSERT INTO myths_facts (myth_text, truth_text, category) VALUES (?, ?, ?)");
                $stmt->execute([$myth, $truth, $category]);
                $message = 'Myth & Fact pair added successfully!';
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }

    if (isset($_POST['action']) && $_POST['action'] === 'edit') {
        $id = intval($_POST['id']);
        $myth = trim($_POST['myth_text'] ?? '');
        $truth = trim($_POST['truth_text'] ?? '');
        $category = trim($_POST['category'] ?? 'General');

        if (empty($myth) || empty($truth)) {
            $error = 'Both Myth and Fact explanation are required.';
        } else {
            try {
                $stmt = $db->prepare("UPDATE myths_facts SET myth_text = ?, truth_text = ?, category = ? WHERE id = ?");
                $stmt->execute([$myth, $truth, $category, $id]);
                $message = 'Myth & Fact pair updated successfully!';
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }
}

// Handle Delete
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $id = intval($_GET['id']);
    try {
        $stmt = $db->prepare("DELETE FROM myths_facts WHERE id = ?");
        $stmt->execute([$id]);
        $message = 'Myth & Fact pair deleted successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete entry: ' . $e->getMessage();
    }
}

// Fetch all myths
try {
    $myths = $db->query("SELECT * FROM myths_facts ORDER BY id DESC")->fetchAll();
} catch (PDOException $e) {
    $myths = [];
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

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold m-0">Myths vs Facts Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addMythModal">
            <i class="bi bi-plus-lg me-2"></i>Add Myth & Fact
        </button>
    </div>

    <!-- Myths List -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 80px;">ID</th>
                        <th>Myth Misconception</th>
                        <th>Fact Verification</th>
                        <th>Category</th>
                        <th class="text-end" style="width: 120px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($myths)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No myths & facts entries found. Click "Add Myth & Fact" to begin.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($myths as $item): ?>
                            <tr>
                                <td class="text-secondary fw-semibold">#<?= $item['id'] ?></td>
                                <td>
                                    <div class="text-danger fw-semibold"><i class="bi bi-x-circle me-1"></i> <?= htmlspecialchars($item['myth_text']) ?></div>
                                </td>
                                <td>
                                    <div class="text-success"><i class="bi bi-check-circle-fill me-1"></i> <?= htmlspecialchars($item['truth_text']) ?></div>
                                </td>
                                <td>
                                    <span class="badge bg-teal-glow px-2.5 py-1.5"><?= htmlspecialchars($item['category']) ?></span>
                                </td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-secondary-custom me-2" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#editMythModal<?= $item['id'] ?>">
                                        <i class="bi bi-pencil-square"></i>
                                    </button>
                                    <a href="myths.php?action=delete&id=<?= $item['id'] ?>" 
                                       class="btn btn-sm btn-outline-danger border-0" 
                                       onclick="return confirm('Are you sure you want to delete this myth/fact entry?');">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>

                            <!-- Edit Modal -->
                            <div class="modal fade" id="editMythModal<?= $item['id'] ?>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
                                        <div class="modal-header border-0 pb-0">
                                            <h5 class="modal-title fw-bold">Edit Myth & Fact</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form method="POST">
                                            <div class="modal-body py-4">
                                                <input type="hidden" name="action" value="edit">
                                                <input type="hidden" name="id" value="<?= $item['id'] ?>">
                                                
                                                <div class="row g-3">
                                                    <div class="col-12 col-md-4">
                                                        <label class="form-label text-secondary fw-semibold">Category</label>
                                                        <input type="text" class="form-control" name="category" value="<?= htmlspecialchars($item['category']) ?>" required>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Myth (Misconception Text)</label>
                                                        <textarea class="form-control" name="myth_text" rows="3" required><?= htmlspecialchars($item['myth_text']) ?></textarea>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Fact (Truth / Scientific Backing)</label>
                                                        <textarea class="form-control" name="truth_text" rows="4" required><?= htmlspecialchars($item['truth_text']) ?></textarea>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="modal-footer border-0 pt-0">
                                                <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-custom">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Modal -->
<div class="modal fade" id="addMythModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Add New Myth & Fact</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label text-secondary fw-semibold">Category</label>
                            <input type="text" class="form-control" name="category" required placeholder="e.g., Protein / B12 / Calcium" value="Nutrition">
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Myth (Misconception Text)</label>
                            <textarea class="form-control" name="myth_text" rows="3" required placeholder="e.g., Plant-based calcium is not absorbed by the body."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Fact (Truth / Scientific Backing)</label>
                            <textarea class="form-control" name="truth_text" rows="4" required placeholder="e.g., Many plant foods like kale, broccoli, and fortified plant milks have high absorption rates for calcium, often matching or exceeding cow's milk absorption."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-custom">Add Pair</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
