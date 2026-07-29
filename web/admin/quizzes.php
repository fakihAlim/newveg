<?php
/**
 * Daily Quiz CRUD Editor
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - Daily Quizzes";
$headerTitle = "Daily Quiz Center";
$headerSubtitle = "Add daily gamified nutrition questions to reward user learning";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle Actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action']) && $_POST['action'] === 'add') {
        $question = trim($_POST['question'] ?? '');
        $optionA = trim($_POST['option_a'] ?? '');
        $optionB = trim($_POST['option_b'] ?? '');
        $optionC = trim($_POST['option_c'] ?? '');
        $optionD = trim($_POST['option_d'] ?? '');
        $correctOption = trim($_POST['correct_option'] ?? 'A');
        $explanation = trim($_POST['explanation'] ?? '');
        $pointsReward = intval($_POST['points_reward'] ?? 10);

        if (empty($question) || empty($optionA) || empty($optionB) || empty($optionC) || empty($optionD)) {
            $error = 'Question and all 4 options are required.';
        } else {
            try {
                $stmt = $db->prepare("
                    INSERT INTO quizzes (question, option_a, option_b, option_c, option_d, correct_option, explanation, points_reward)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ");
                $stmt->execute([$question, $optionA, $optionB, $optionC, $optionD, $correctOption, $explanation, $pointsReward]);
                $message = 'Quiz question added successfully!';
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }

    if (isset($_POST['action']) && $_POST['action'] === 'edit') {
        $id = intval($_POST['id']);
        $question = trim($_POST['question'] ?? '');
        $optionA = trim($_POST['option_a'] ?? '');
        $optionB = trim($_POST['option_b'] ?? '');
        $optionC = trim($_POST['option_c'] ?? '');
        $optionD = trim($_POST['option_d'] ?? '');
        $correctOption = trim($_POST['correct_option'] ?? 'A');
        $explanation = trim($_POST['explanation'] ?? '');
        $pointsReward = intval($_POST['points_reward'] ?? 10);

        if (empty($question) || empty($optionA) || empty($optionB) || empty($optionC) || empty($optionD)) {
            $error = 'Question and all 4 options are required.';
        } else {
            try {
                $stmt = $db->prepare("
                    UPDATE quizzes 
                    SET question = ?, option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_option = ?, explanation = ?, points_reward = ?
                    WHERE id = ?
                ");
                $stmt->execute([$question, $optionA, $optionB, $optionC, $optionD, $correctOption, $explanation, $pointsReward, $id]);
                $message = 'Quiz question updated successfully!';
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
        $stmt = $db->prepare("DELETE FROM quizzes WHERE id = ?");
        $stmt->execute([$id]);
        $message = 'Quiz question deleted successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete quiz: ' . $e->getMessage();
    }
}

// Fetch all quizzes
try {
    $quizzes = $db->query("SELECT * FROM quizzes ORDER BY id DESC")->fetchAll();
} catch (PDOException $e) {
    $quizzes = [];
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
        <h4 class="fw-bold m-0">Quizzes Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addQuizModal">
            <i class="bi bi-plus-lg me-2"></i>Add Quiz Question
        </button>
    </div>

    <!-- Quiz List Table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Question</th>
                        <th>Options (Correct)</th>
                        <th>Points Reward</th>
                        <th class="text-end" style="width: 120px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($quizzes)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No quizzes found. Click "Add Quiz Question" to begin.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($quizzes as $quiz): ?>
                            <tr>
                                <td class="text-secondary fw-semibold">#<?= $quiz['id'] ?></td>
                                <td>
                                    <div class="fw-semibold text-white"><?= htmlspecialchars($quiz['question']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 320px;"><?= htmlspecialchars($quiz['explanation']) ?></div>
                                </td>
                                <td>
                                    <div class="fs-13 text-secondary">
                                        <span class="<?= $quiz['correct_option'] === 'A' ? 'text-success fw-bold' : '' ?>">A: <?= htmlspecialchars($quiz['option_a']) ?></span> |
                                        <span class="<?= $quiz['correct_option'] === 'B' ? 'text-success fw-bold' : '' ?>">B: <?= htmlspecialchars($quiz['option_b']) ?></span> |
                                        <span class="<?= $quiz['correct_option'] === 'C' ? 'text-success fw-bold' : '' ?>">C: <?= htmlspecialchars($quiz['option_c']) ?></span> |
                                        <span class="<?= $quiz['correct_option'] === 'D' ? 'text-success fw-bold' : '' ?>">D: <?= htmlspecialchars($quiz['option_d']) ?></span>
                                    </div>
                                    <div class="text-teal fs-12 fw-semibold mt-1">Correct Answer: Option <?= htmlspecialchars($quiz['correct_option']) ?></div>
                                </td>
                                <td class="text-white fw-bold"><i class="bi bi-star-fill text-warning me-1"></i> <?= intval($quiz['points_reward']) ?> pts</td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-secondary-custom me-2" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#editQuizModal<?= $quiz['id'] ?>">
                                        <i class="bi bi-pencil-square"></i>
                                    </button>
                                    <a href="quizzes.php?action=delete&id=<?= $quiz['id'] ?>" 
                                       class="btn btn-sm btn-outline-danger border-0" 
                                       onclick="return confirm('Are you sure you want to delete this quiz question?');">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>

                            <!-- Edit Modal -->
                            <div class="modal fade" id="editQuizModal<?= $quiz['id'] ?>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
                                        <div class="modal-header border-0 pb-0">
                                            <h5 class="modal-title fw-bold">Edit Quiz Question</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form method="POST">
                                            <div class="modal-body py-4">
                                                <input type="hidden" name="action" value="edit">
                                                <input type="hidden" name="id" value="<?= $quiz['id'] ?>">
                                                
                                                <div class="row g-3">
                                                    <div class="col-12 col-md-9">
                                                        <label class="form-label text-secondary fw-semibold">Question</label>
                                                        <input type="text" class="form-control" name="question" value="<?= htmlspecialchars($quiz['question']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-3">
                                                        <label class="form-label text-secondary fw-semibold">Points Reward</label>
                                                        <input type="number" class="form-control" name="points_reward" value="<?= intval($quiz['points_reward']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Option A</label>
                                                        <input type="text" class="form-control" name="option_a" value="<?= htmlspecialchars($quiz['option_a']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Option B</label>
                                                        <input type="text" class="form-control" name="option_b" value="<?= htmlspecialchars($quiz['option_b']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Option C</label>
                                                        <input type="text" class="form-control" name="option_c" value="<?= htmlspecialchars($quiz['option_c']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Option D</label>
                                                        <input type="text" class="form-control" name="option_d" value="<?= htmlspecialchars($quiz['option_d']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-4">
                                                        <label class="form-label text-secondary fw-semibold">Correct Option</label>
                                                        <select class="form-select" name="correct_option">
                                                            <option value="A" <?= $quiz['correct_option'] === 'A' ? 'selected' : '' ?>>Option A</option>
                                                            <option value="B" <?= $quiz['correct_option'] === 'B' ? 'selected' : '' ?>>Option B</option>
                                                            <option value="C" <?= $quiz['correct_option'] === 'C' ? 'selected' : '' ?>>Option C</option>
                                                            <option value="D" <?= $quiz['correct_option'] === 'D' ? 'selected' : '' ?>>Option D</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Explanation</label>
                                                        <textarea class="form-control" name="explanation" rows="3" required><?= htmlspecialchars($quiz['explanation']) ?></textarea>
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
<div class="modal fade" id="addQuizModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Add New Quiz Question</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-9">
                            <label class="form-label text-secondary fw-semibold">Question</label>
                            <input type="text" class="form-control" name="question" required placeholder="e.g., Which vitamin is primarily deficient in raw unfortified plant foods?">
                        </div>
                        <div class="col-12 col-md-3">
                            <label class="form-label text-secondary fw-semibold">Points Reward</label>
                            <input type="number" class="form-control" name="points_reward" required value="10">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option A</label>
                            <input type="text" class="form-control" name="option_a" required placeholder="e.g., Vitamin A">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option B</label>
                            <input type="text" class="form-control" name="option_b" required placeholder="e.g., Vitamin C">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option C</label>
                            <input type="text" class="form-control" name="option_c" required placeholder="e.g., Vitamin D">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option D</label>
                            <input type="text" class="form-control" name="option_d" required placeholder="e.g., Vitamin B12">
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label text-secondary fw-semibold">Correct Option</label>
                            <select class="form-select" name="correct_option">
                                <option value="A">Option A</option>
                                <option value="B">Option B</option>
                                <option value="C">Option C</option>
                                <option value="D" selected>Option D</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Explanation</label>
                            <textarea class="form-control" name="explanation" rows="3" required placeholder="Explain why the correct answer is correct..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-custom">Create Quiz</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
