<?php
/**
 * News Articles CRUD Manager
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - News";
$headerTitle = "News & Articles Editor";
$headerSubtitle = "Publish and edit nutritional research and plant-based articles";

require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

$targetDir = __DIR__ . '/../uploads/news/';
if (!file_exists($targetDir)) {
    mkdir($targetDir, 0755, true);
}

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
        $countQuery = "SELECT COUNT(*) FROM news";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE title LIKE ? OR content LIKE ? OR category LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "SELECT * FROM news";
        if (!empty($search)) {
            $dataQuery .= " WHERE title LIKE ? OR content LIKE ? OR category LIKE ?";
        }
        $dataQuery .= " ORDER BY published_at DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $newsList = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($newsList)) {
            $html = '<tr><td colspan="6" class="text-center text-secondary py-4">No articles found.</td></tr>';
        } else {
            foreach ($newsList as $item) {
                $newsJson = htmlspecialchars(json_encode([
                    'id' => $item['id'],
                    'title' => $item['title'],
                    'content' => $item['content'],
                    'category' => $item['category']
                ]), ENT_QUOTES, 'UTF-8');

                $html .= '<tr>
                    <td>' . intval($item['id']) . '</td>
                    <td>
                        <img src="../' . htmlspecialchars($item['image_url'] ?? 'uploads/news/default.jpg') . '" class="rounded" style="width: 50px; height: 50px; object-fit: cover; border: 1px solid var(--border-color);" alt="News">
                    </td>
                    <td>
                        <div class="fw-semibold text-white">' . htmlspecialchars($item['title']) . '</div>
                        <div class="text-secondary fs-12 text-truncate" style="max-width: 300px;">' . strip_tags($item['content']) . '</div>
                    </td>
                    <td><span class="badge bg-purple-glow">' . htmlspecialchars($item['category']) . '</span></td>
                    <td class="text-secondary">' . date('M d, Y H:i', strtotime($item['published_at'])) . '</td>
                    <td class="text-end">
                        <a href="#" class="action-link btn-edit-news" data-news="' . $newsJson . '">[ Edit ]</a>
                        <a href="news.php?action=delete&id=' . $item['id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Are you sure you want to delete this article?\');">[ Hapus ]</a>
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
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $category = trim($_POST['category'] ?? 'Nutrition');
        $imageUrl = 'uploads/news/default.jpg';

        if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {
            $fileError = $_FILES['image']['error'];
            if ($fileError !== UPLOAD_ERR_OK) {
                switch ($fileError) {
                    case UPLOAD_ERR_INI_SIZE:
                        $error = 'Failed to upload image: The file exceeds the upload_max_filesize directive in php.ini.';
                        break;
                    case UPLOAD_ERR_FORM_SIZE:
                        $error = 'Failed to upload image: The file exceeds the MAX_FILE_SIZE specified in the form.';
                        break;
                    case UPLOAD_ERR_PARTIAL:
                        $error = 'Failed to upload image: The file was only partially uploaded.';
                        break;
                    case UPLOAD_ERR_NO_TMP_DIR:
                        $error = 'Failed to upload image: Missing a temporary folder on the server.';
                        break;
                    case UPLOAD_ERR_CANT_WRITE:
                        $error = 'Failed to upload image: Failed to write file to disk.';
                        break;
                    default:
                        $error = 'Failed to upload image: Unknown error (Code: ' . $fileError . ').';
                        break;
                }
            } else {
                if (!is_writable($targetDir)) {
                    $error = 'Failed to upload image: The uploads directory is not writable.';
                } else {
                    $fileName = time() . '_' . preg_replace("/[^a-zA-Z0-9\._-]/", "", $_FILES['image']['name']);
                    $targetFilePath = $targetDir . $fileName;
                    if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                        $imageUrl = 'uploads/news/' . $fileName;
                    } else {
                        $error = 'Failed to upload image: Unable to move file to the target directory.';
                    }
                }
            }
        }

        if (empty($title) || empty($content)) {
            $error = 'Title and Content are required fields.';
        }

        if (empty($error)) {
            try {
                $stmt = $db->prepare("INSERT INTO news (title, content, category, image_url) VALUES (?, ?, ?, ?)");
                $stmt->execute([$title, $content, $category, $imageUrl]);
                $message = 'Article published successfully!';
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }

    if (isset($_POST['action']) && $_POST['action'] === 'edit') {
        $id = intval($_POST['id']);
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $category = trim($_POST['category'] ?? 'Nutrition');

        if (empty($title) || empty($content)) {
            $error = 'Title and Content are required fields.';
        }

        if (empty($error)) {
            try {
                if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {
                    $fileError = $_FILES['image']['error'];
                    if ($fileError !== UPLOAD_ERR_OK) {
                        switch ($fileError) {
                            case UPLOAD_ERR_INI_SIZE:
                                $error = 'Failed to upload image: The file exceeds the upload_max_filesize directive in php.ini.';
                                break;
                            case UPLOAD_ERR_FORM_SIZE:
                                $error = 'Failed to upload image: The file exceeds the MAX_FILE_SIZE specified in the form.';
                                break;
                            case UPLOAD_ERR_PARTIAL:
                                $error = 'Failed to upload image: The file was only partially uploaded.';
                                break;
                            case UPLOAD_ERR_NO_TMP_DIR:
                                $error = 'Failed to upload image: Missing a temporary folder on the server.';
                                break;
                            case UPLOAD_ERR_CANT_WRITE:
                                $error = 'Failed to upload image: Failed to write file to disk.';
                                break;
                            default:
                                $error = 'Failed to upload image: Unknown error (Code: ' . $fileError . ').';
                                break;
                        }
                    } else {
                        if (!is_writable($targetDir)) {
                            $error = 'Failed to upload image: The uploads directory is not writable.';
                        } else {
                            $fileName = time() . '_' . preg_replace("/[^a-zA-Z0-9\._-]/", "", $_FILES['image']['name']);
                            $targetFilePath = $targetDir . $fileName;
                            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                                $imageUrl = 'uploads/news/' . $fileName;
                                $stmt = $db->prepare("UPDATE news SET title = ?, content = ?, category = ?, image_url = ? WHERE id = ?");
                                $stmt->execute([$title, $content, $category, $imageUrl, $id]);
                            } else {
                                $error = 'Failed to upload image: Unable to move file to the target directory.';
                            }
                        }
                    }
                } else {
                    $stmt = $db->prepare("UPDATE news SET title = ?, content = ?, category = ? WHERE id = ?");
                    $stmt->execute([$title, $content, $category, $id]);
                }
                
                if (empty($error)) {
                    $message = 'Article updated successfully!';
                }
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }
}

// Handle delete
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $id = intval($_GET['id']);
    try {
        $fileStmt = $db->prepare("SELECT image_url FROM news WHERE id = ?");
        $fileStmt->execute([$id]);
        $oldImage = $fileStmt->fetchColumn();
        if ($oldImage && $oldImage !== 'uploads/news/default.jpg' && file_exists(__DIR__ . '/../' . $oldImage)) {
            @unlink(__DIR__ . '/../' . $oldImage);
        }

        $stmt = $db->prepare("DELETE FROM news WHERE id = ?");
        $stmt->execute([$id]);
        $message = 'Article deleted successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete article: ' . $e->getMessage();
    }
}

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM news");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("SELECT * FROM news ORDER BY published_at DESC LIMIT :limit OFFSET :offset");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $newsList = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $newsList = [];
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
        <h4 class="fw-bold m-0">News Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addNewsModal">
            [ Publish Resep Baru ]
        </button>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="news-search" class="form-control" placeholder="Cari artikel berdasarkan judul/kategori...">
        </div>
        <div>
            <span id="news-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
    </div>

    <!-- News List Table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="width: 80px;">Preview</th>
                        <th>Article Details</th>
                        <th>Category</th>
                        <th>Published</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="news-table-body">
                    <?php if (empty($newsList)): ?>
                        <tr>
                            <td colspan="6" class="text-center text-secondary py-5">No articles found. Click "[ Publish Resep Baru ]" to start.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($newsList as $item): 
                            $newsJson = htmlspecialchars(json_encode([
                                'id' => $item['id'],
                                'title' => $item['title'],
                                'content' => $item['content'],
                                'category' => $item['category']
                            ]), ENT_QUOTES, 'UTF-8');
                        ?>
                            <tr>
                                <td><?= intval($item['id']) ?></td>
                                <td>
                                    <img src="../<?= htmlspecialchars($item['image_url'] ?? 'uploads/news/default.jpg') ?>" class="rounded object-fit-cover" style="width: 50px; height: 50px; border: 1px solid var(--border-color);" alt="News">
                                </td>
                                <td>
                                    <div class="fw-semibold text-white"><?= htmlspecialchars($item['title']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 300px;"><?= strip_tags($item['content']) ?></div>
                                </td>
                                <td><span class="badge bg-purple-glow"><?= htmlspecialchars($item['category']) ?></span></td>
                                <td class="text-secondary"><?= date('M d, Y H:i', strtotime($item['published_at'])) ?></td>
                                <td class="text-end">
                                    <a href="#" class="action-link btn-edit-news" data-news="<?= $newsJson ?>">[ Edit ]</a>
                                    <a href="news.php?action=delete&id=<?= $item['id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Are you sure you want to delete this article?');">
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
        <div class="d-flex justify-content-center mt-3" id="news-pagination">
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
<div class="modal fade" id="editNewsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Edit Article</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="edit-id">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-8">
                            <label class="form-label text-secondary fw-semibold">Article Title</label>
                            <input type="text" class="form-control" name="title" id="edit-title" required>
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label text-secondary fw-semibold">Category</label>
                            <input type="text" class="form-control" name="category" id="edit-category" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Content Body (HTML supported)</label>
                            <textarea class="form-control" name="content" id="edit-content" rows="8" required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Update Image (optional)</label>
                            <input type="file" class="form-control" name="image" accept="image/*">
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
<div class="modal fade" id="addNewsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Publish New Article</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-8">
                            <label class="form-label text-secondary fw-semibold">Article Title</label>
                            <input type="text" class="form-control" name="title" required placeholder="e.g., The Science Behind Vitamin B12 Absorption">
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label text-secondary fw-semibold">Category</label>
                            <input type="text" class="form-control" name="category" required placeholder="e.g., Vitamin / Research" value="Nutrition">
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Content Body (HTML supported)</label>
                            <textarea class="form-control" name="content" rows="8" required placeholder="Write article content here..."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Article Cover Image</label>
                            <input type="file" class="form-control" name="image" accept="image/*">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">[ Batal ]</button>
                    <button type="submit" class="btn btn-custom">[ Terbitkan Sekarang ]</button>
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
    fetch(`news.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('news-table-body').innerHTML = res.html;
                document.getElementById('news-pagination').innerHTML = res.pagination;
                document.getElementById('news-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('news-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1; // reset to first page on search
    debounceTimer = setTimeout(fetchData, 300);
});

// Dynamic edit modal data hydration
document.addEventListener('click', function(e) {
    const editBtn = e.target.closest('.btn-edit-news');
    if (editBtn) {
        e.preventDefault();
        try {
            const item = JSON.parse(editBtn.getAttribute('data-news'));
            
            // Populate fields
            document.getElementById('edit-id').value = item.id;
            document.getElementById('edit-title').value = item.title;
            document.getElementById('edit-category').value = item.category;
            document.getElementById('edit-content').value = item.content;

            // Trigger Bootstrap modal open
            const editModal = new bootstrap.Modal(document.getElementById('editNewsModal'));
            editModal.show();
        } catch (err) {
            console.error('Error parsing news JSON:', err);
        }
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
