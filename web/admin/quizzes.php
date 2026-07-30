<?php
/**
 * Daily Quiz CRUD Editor
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Daily Quizzes";
$headerTitle = "Daily Quiz Center";
$headerSubtitle = "Add daily gamified nutrition questions to reward user learning";

require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// ---------------------------------------------------------------------------
// AJAX Live Search & Pagination Handler
// ---------------------------------------------------------------------------
if (isset($_GET['ajax']) && $_GET['ajax'] == '1') {
    header('Content-Type: application/json');
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = 10;
    $offset = ($page - 1) * $limit;

    try {
        $countQuery = "SELECT COUNT(*) FROM quizzes";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE question LIKE ? OR explanation LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "SELECT * FROM quizzes";
        if (!empty($search)) {
            $dataQuery .= " WHERE question LIKE ? OR explanation LIKE ?";
        }
        $dataQuery .= " ORDER BY id DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $quizzes = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($quizzes)) {
            $html = '<tr><td colspan="5" class="text-center text-secondary py-4">No quizzes found.</td></tr>';
        } else {
            foreach ($quizzes as $quiz) {
                $quizJson = htmlspecialchars(json_encode([
                    'id' => $quiz['id'],
                    'question' => $quiz['question'],
                    'option_a' => $quiz['option_a'],
                    'option_b' => $quiz['option_b'],
                    'option_c' => $quiz['option_c'],
                    'option_d' => $quiz['option_d'],
                    'correct_option' => $quiz['correct_option'],
                    'explanation' => $quiz['explanation'],
                    'points_reward' => $quiz['points_reward']
                ]), ENT_QUOTES, 'UTF-8');

                $html .= '<tr>
                    <td>' . intval($quiz['id']) . '</td>
                    <td>
                        <div class="fw-semibold text-white">' . htmlspecialchars($quiz['question']) . '</div>
                        <div class="text-secondary fs-12 text-truncate" style="max-width: 320px;">' . htmlspecialchars($quiz['explanation']) . '</div>
                    </td>
                    <td>
                        <div class="fs-13 text-secondary">
                            <span class="' . ($quiz['correct_option'] === 'A' ? 'text-success fw-bold' : '') . '">A: ' . htmlspecialchars($quiz['option_a']) . '</span> |
                            <span class="' . ($quiz['correct_option'] === 'B' ? 'text-success fw-bold' : '') . '">B: ' . htmlspecialchars($quiz['option_b']) . '</span> |
                            <span class="' . ($quiz['correct_option'] === 'C' ? 'text-success fw-bold' : '') . '">C: ' . htmlspecialchars($quiz['option_c']) . '</span> |
                            <span class="' . ($quiz['correct_option'] === 'D' ? 'text-success fw-bold' : '') . '">D: ' . htmlspecialchars($quiz['option_d']) . '</span>
                        </div>
                        <div class="text-teal fs-12 fw-semibold mt-1">Correct Answer: Option ' . htmlspecialchars($quiz['correct_option']) . '</div>
                    </td>
                    <td class="text-white fw-bold">' . intval($quiz['points_reward']) . ' pts</td>
                    <td class="text-end">
                        <a href="#" class="action-link btn-edit-quiz" data-quiz="' . $quizJson . '">[ Edit ]</a>
                        <a href="quizzes.php?action=delete&id=' . $quiz['id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Are you sure you want to delete this quiz?\');">[ Hapus ]</a>
                    </td>
                </tr>';
            }
        }

        // Render Pagination HTML
        $paginationHtml = '';
        if ($totalPages > 1) {
            $prevPage = $page - 1;
            $nextPage = $page + 1;
            
            if ($page > 1) {
                $paginationHtml .= '<button type="button" class="btn btn-secondary-custom py-1 px-2.5 me-1" onclick="changePage(' . $prevPage . ')">Sebelumnya</button>';
            } else {
                $paginationHtml .= '<button type="button" class="btn btn-secondary-custom py-1 px-2.5 me-1" disabled>Sebelumnya</button>';
            }

            for ($i = 1; $i <= $totalPages; $i++) {
                $activeClass = ($i === $page) ? 'btn-custom' : 'btn-secondary-custom';
                $paginationHtml .= '<button type="button" class="btn ' . $activeClass . ' py-1 px-2.5 me-1" onclick="changePage(' . $i . ')">' . $i . '</button>';
            }

            if ($page < $totalPages) {
                $paginationHtml .= '<button type="button" class="btn btn-secondary-custom py-1 px-2.5" onclick="changePage(' . $nextPage . ')">Berikutnya</button>';
            } else {
                $paginationHtml .= '<button type="button" class="btn btn-secondary-custom py-1 px-2.5" disabled>Berikutnya</button>';
            }
        }

        echo json_encode([
            'success' => true,
            'html' => $html,
            'pagination' => $paginationHtml,
            'info' => "Halaman $page dari $totalPages (Total: $totalItems data)"
        ]);
        exit;

    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        exit;
    }
}

// ---------------------------------------------------------------------------
// Form Submission POST Handlers
// ---------------------------------------------------------------------------
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

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM quizzes");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("SELECT * FROM quizzes ORDER BY id DESC LIMIT :limit OFFSET :offset");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $quizzes = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $quizzes = [];
    $totalItems = 0;
    $totalPages = 1;
}

require_once __DIR__ . '/includes/header.php';
?>

<div class="animated-fade mb-5">
    
    <?php if (!empty($message)): ?>
        <div class="alert alert-success border-0 bg-success bg-opacity-10 text-success p-3 mb-4 rounded-3 d-flex align-items-center">
            <div><?= htmlspecialchars($message) ?></div>
        </div>
    <?php endif; ?>

    <?php if (!empty($error)): ?>
        <div class="alert alert-danger border-0 bg-danger bg-opacity-10 text-danger p-3 mb-4 rounded-3 d-flex align-items-center">
            <div><?= htmlspecialchars($error) ?></div>
        </div>
    <?php endif; ?>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold m-0">Quizzes Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addQuizModal">
            [ Tambah Kuis Baru ]
        </button>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="quiz-search" class="form-control" placeholder="Cari kuis berdasarkan pertanyaan/penjelasan...">
        </div>
        <div>
            <span id="quiz-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
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
                <tbody id="quiz-table-body">
                    <?php if (empty($quizzes)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No quizzes found. Click "[ Tambah Kuis Baru ]" to begin.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($quizzes as $quiz): 
                            $quizJson = htmlspecialchars(json_encode([
                                'id' => $quiz['id'],
                                'question' => $quiz['question'],
                                'option_a' => $quiz['option_a'],
                                'option_b' => $quiz['option_b'],
                                'option_c' => $quiz['option_c'],
                                'option_d' => $quiz['option_d'],
                                'correct_option' => $quiz['correct_option'],
                                'explanation' => $quiz['explanation'],
                                'points_reward' => $quiz['points_reward']
                            ]), ENT_QUOTES, 'UTF-8');
                        ?>
                            <tr>
                                <td><?= intval($quiz['id']) ?></td>
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
                                <td class="text-white fw-bold"><?= intval($quiz['points_reward']) ?> pts</td>
                                <td class="text-end">
                                    <a href="#" class="action-link btn-edit-quiz" data-quiz="<?= $quizJson ?>">[ Edit ]</a>
                                    <a href="quizzes.php?action=delete&id=<?= $quiz['id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Are you sure you want to delete this quiz?');">
                                        [ Hapus ]
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Pagination controls -->
        <div class="d-flex justify-content-center mt-3" id="quiz-pagination">
            <?php if ($totalPages > 1): ?>
                <button type="button" class="btn btn-secondary-custom py-1 px-2.5 me-1" disabled>Sebelumnya</button>
                <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                    <button type="button" class="btn <?= ($i === 1) ? 'btn-custom' : 'btn-secondary-custom' ?> py-1 px-2.5 me-1" onclick="changePage(<?= $i ?>)"><?= $i ?></button>
                <?php endfor; ?>
                <button type="button" class="btn btn-secondary-custom py-1 px-2.5" onclick="changePage(2)">Berikutnya</button>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Shared Edit Modal -->
<div class="modal fade" id="editQuizModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Edit Quiz Question</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="edit-id">
                    
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Question Text</label>
                            <textarea class="form-control" name="question" id="edit-question" rows="3" required></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option A</label>
                            <input type="text" class="form-control" name="option_a" id="edit-option-a" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option B</label>
                            <input type="text" class="form-control" name="option_b" id="edit-option-b" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option C</label>
                            <input type="text" class="form-control" name="option_c" id="edit-option-c" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option D</label>
                            <input type="text" class="form-control" name="option_d" id="edit-option-d" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Correct Option</label>
                            <select class="form-select" name="correct_option" id="edit-correct-option">
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Points Reward</label>
                            <input type="number" class="form-control" name="points_reward" id="edit-points-reward" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Explanation</label>
                            <textarea class="form-control" name="explanation" id="edit-explanation" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">[ Batal ]</button>
                    <button type="submit" class="btn btn-custom">[ Simpan Perubahan ]</button>
                </div>
            </form>
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
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Question Text</label>
                            <textarea class="form-control" name="question" required placeholder="Type the question content..."></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option A</label>
                            <input type="text" class="form-control" name="option_a" required placeholder="Option A text">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option B</label>
                            <input type="text" class="form-control" name="option_b" required placeholder="Option B text">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option C</label>
                            <input type="text" class="form-control" name="option_c" required placeholder="Option C text">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Option D</label>
                            <input type="text" class="form-control" name="option_d" required placeholder="Option D text">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Correct Option</label>
                            <select class="form-select" name="correct_option">
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Points Reward</label>
                            <input type="number" class="form-control" name="points_reward" value="10" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Explanation</label>
                            <textarea class="form-control" name="explanation" rows="3" placeholder="Provide a brief explanation of why the correct option is right..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">[ Batal ]</button>
                    <button type="submit" class="btn btn-custom">[ Buat Kuis ]</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- JS debounced live search and pagination -->
<script>
let currentSearch = '';
let currentPage = 1;
let debounceTimer = null;

function changePage(page) {
    currentPage = page;
    fetchData();
}

function fetchData() {
    fetch(`quizzes.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('quiz-table-body').innerHTML = res.html;
                document.getElementById('quiz-pagination').innerHTML = res.pagination;
                document.getElementById('quiz-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('quiz-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1;
    debounceTimer = setTimeout(fetchData, 300);
});

// Dynamic edit modal data hydration
document.addEventListener('click', function(e) {
    const editBtn = e.target.closest('.btn-edit-quiz');
    if (editBtn) {
        e.preventDefault();
        try {
            const quiz = JSON.parse(editBtn.getAttribute('data-quiz'));
            
            // Populate fields
            document.getElementById('edit-id').value = quiz.id;
            document.getElementById('edit-question').value = quiz.question;
            document.getElementById('edit-option-a').value = quiz.option_a;
            document.getElementById('edit-option-b').value = quiz.option_b;
            document.getElementById('edit-option-c').value = quiz.option_c;
            document.getElementById('edit-option-d').value = quiz.option_d;
            document.getElementById('edit-correct-option').value = quiz.correct_option;
            document.getElementById('edit-points-reward').value = quiz.points_reward;
            document.getElementById('edit-explanation').value = quiz.explanation;

            // Trigger Bootstrap modal open
            const editModal = new bootstrap.Modal(document.getElementById('editQuizModal'));
            editModal.show();
        } catch (err) {
            console.error('Error parsing quiz JSON:', err);
        }
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
