<?php
/**
 * Myths & Facts CRUD Manager
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Myths & Facts";
$headerTitle = "Myths vs Facts Control Room";
$headerSubtitle = "Address common misconceptions with verified scientific facts";

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
        $countQuery = "SELECT COUNT(*) FROM myths_facts";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE myth_text LIKE ? OR truth_text LIKE ? OR category LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "SELECT * FROM myths_facts";
        if (!empty($search)) {
            $dataQuery .= " WHERE myth_text LIKE ? OR truth_text LIKE ? OR category LIKE ?";
        }
        $dataQuery .= " ORDER BY id DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $myths = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($myths)) {
            $html = '<tr><td colspan="5" class="text-center text-secondary py-4">No myths & facts found.</td></tr>';
        } else {
            foreach ($myths as $item) {
                $mythJson = htmlspecialchars(json_encode([
                    'id' => $item['id'],
                    'myth_text' => $item['myth_text'],
                    'truth_text' => $item['truth_text'],
                    'category' => $item['category']
                ]), ENT_QUOTES, 'UTF-8');

                $html .= '<tr>
                    <td>' . intval($item['id']) . '</td>
                    <td>
                        <div class="text-danger fw-semibold">Myth: ' . htmlspecialchars($item['myth_text']) . '</div>
                    </td>
                    <td>
                        <div class="text-success">Fact: ' . htmlspecialchars($item['truth_text']) . '</div>
                    </td>
                    <td>
                        <span class="badge bg-teal-glow">' . htmlspecialchars($item['category']) . '</span>
                    </td>
                    <td class="text-end">
                        <a href="#" class="action-link btn-edit-myth" data-myth="' . $mythJson . '">[ Edit ]</a>
                        <a href="myths.php?action=delete&id=' . $item['id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Are you sure you want to delete this myth/fact entry?\');">[ Hapus ]</a>
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

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM myths_facts");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("SELECT * FROM myths_facts ORDER BY id DESC LIMIT :limit OFFSET :offset");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $myths = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $myths = [];
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
        <h4 class="fw-bold m-0">Myths vs Facts Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addMythModal">
            [ Tambah Mitos Baru ]
        </button>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="myth-search" class="form-control" placeholder="Cari mitos/fakta berdasarkan teks/kategori...">
        </div>
        <div>
            <span id="myth-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
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
                <tbody id="myth-table-body">
                    <?php if (empty($myths)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No myths & facts entries found. Click "[ Tambah Mitos Baru ]" to begin.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($myths as $item): 
                            $mythJson = htmlspecialchars(json_encode([
                                'id' => $item['id'],
                                'myth_text' => $item['myth_text'],
                                'truth_text' => $item['truth_text'],
                                'category' => $item['category']
                            ]), ENT_QUOTES, 'UTF-8');
                        ?>
                            <tr>
                                <td><?= intval($item['id']) ?></td>
                                <td>
                                    <div class="text-danger fw-semibold">Myth: <?= htmlspecialchars($item['myth_text']) ?></div>
                                </td>
                                <td>
                                    <div class="text-success">Fact: <?= htmlspecialchars($item['truth_text']) ?></div>
                                </td>
                                <td>
                                    <span class="badge bg-teal-glow"><?= htmlspecialchars($item['category']) ?></span>
                                </td>
                                <td class="text-end">
                                    <a href="#" class="action-link btn-edit-myth" data-myth="<?= $mythJson ?>">[ Edit ]</a>
                                    <a href="myths.php?action=delete&id=<?= $item['id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Are you sure you want to delete this myth/fact entry?');">
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
        <div class="d-flex justify-content-center mt-3" id="myth-pagination">
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
<div class="modal fade" id="editMythModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Edit Myth & Fact</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="edit-id">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label text-secondary fw-semibold">Category</label>
                            <input type="text" class="form-control" name="category" id="edit-category" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Myth (Misconception Text)</label>
                            <textarea class="form-control" name="myth_text" id="edit-myth-text" rows="3" required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Fact (Truth / Scientific Backing)</label>
                            <textarea class="form-control" name="truth_text" id="edit-truth-text" rows="4" required></textarea>
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
                            <textarea class="form-control" name="truth_text" rows="4" required placeholder="e.g., Many plant foods like kale, broccoli, and fortified plant milks have high absorption rates for calcium..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">[ Batal ]</button>
                    <button type="submit" class="btn btn-custom">[ Buat Mitos ]</button>
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
    fetch(`myths.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('myth-table-body').innerHTML = res.html;
                document.getElementById('myth-pagination').innerHTML = res.pagination;
                document.getElementById('myth-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('myth-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1;
    debounceTimer = setTimeout(fetchData, 300);
});

// Dynamic edit modal data hydration
document.addEventListener('click', function(e) {
    const editBtn = e.target.closest('.btn-edit-myth');
    if (editBtn) {
        e.preventDefault();
        try {
            const item = JSON.parse(editBtn.getAttribute('data-myth'));
            
            // Populate fields
            document.getElementById('edit-id').value = item.id;
            document.getElementById('edit-category').value = item.category;
            document.getElementById('edit-myth-text').value = item.myth_text;
            document.getElementById('edit-truth-text').value = item.truth_text;

            // Trigger Bootstrap modal open
            const editModal = new bootstrap.Modal(document.getElementById('editMythModal'));
            editModal.show();
        } catch (err) {
            console.error('Error parsing myth JSON:', err);
        }
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
