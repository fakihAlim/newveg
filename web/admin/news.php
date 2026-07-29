<?php
/**
 * News Articles CRUD Manager
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - News";
$headerTitle = "News & Articles Editor";
$headerSubtitle = "Publish and edit nutritional research and plant-based articles";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

$targetDir = __DIR__ . '/../uploads/news/';
if (!file_exists($targetDir)) {
    mkdir($targetDir, 0755, true);
}

// Handle CRUD actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action']) && $_POST['action'] === 'add') {
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $category = trim($_POST['category'] ?? 'Nutrition');
        $imageUrl = 'uploads/news/default.jpg';

        if (!empty($_FILES['image']['name'])) {
            $fileName = time() . '_' . preg_replace("/[^a-zA-Z0-9\._-]/", "", $_FILES['image']['name']);
            $targetFilePath = $targetDir . $fileName;
            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                $imageUrl = 'uploads/news/' . $fileName;
            } else {
                $error = 'Failed to upload image file.';
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
                if (!empty($_FILES['image']['name'])) {
                    $fileName = time() . '_' . preg_replace("/[^a-zA-Z0-9\._-]/", "", $_FILES['image']['name']);
                    $targetFilePath = $targetDir . $fileName;
                    if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                        $imageUrl = 'uploads/news/' . $fileName;
                        $stmt = $db->prepare("UPDATE news SET title = ?, content = ?, category = ?, image_url = ? WHERE id = ?");
                        $stmt->execute([$title, $content, $category, $imageUrl, $id]);
                    } else {
                        $error = 'Failed to upload new image.';
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

// Fetch all news
try {
    $newsList = $db->query("SELECT * FROM news ORDER BY published_at DESC")->fetchAll();
} catch (PDOException $e) {
    $newsList = [];
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
        <h4 class="fw-bold m-0">Article Archive</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addNewsModal">
            <i class="bi bi-plus-lg me-2"></i>Publish Article
        </button>
    </div>

    <!-- News List -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 80px;">Image</th>
                        <th>Article Details</th>
                        <th>Category</th>
                        <th>Published Date</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($newsList)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No articles found. Click "Publish Article" to create one.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($newsList as $item): ?>
                            <tr>
                                <td>
                                    <img src="../<?= htmlspecialchars($item['image_url'] ?? 'uploads/news/default.jpg') ?>" class="rounded-3 object-fit-cover" style="width: 60px; height: 60px; border: 1px solid var(--border-color);" alt="News">
                                </td>
                                <td>
                                    <div class="fw-semibold text-white fs-5"><?= htmlspecialchars($item['title']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 300px;"><?= htmlspecialchars(strip_tags($item['content'])) ?></div>
                                </td>
                                <td>
                                    <span class="badge bg-purple-glow badge-glow px-2.5 py-1.5"><?= htmlspecialchars($item['category']) ?></span>
                                </td>
                                <td class="text-secondary"><?= date('M d, Y H:i', strtotime($item['published_at'])) ?></td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-secondary-custom me-2" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#editNewsModal<?= $item['id'] ?>">
                                        <i class="bi bi-pencil-square"></i>
                                    </button>
                                    <a href="news.php?action=delete&id=<?= $item['id'] ?>" 
                                       class="btn btn-sm btn-outline-danger border-0" 
                                       onclick="return confirm('Are you sure you want to delete this article?');">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>

                            <!-- Edit Modal for each news item -->
                            <div class="modal fade" id="editNewsModal<?= $item['id'] ?>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
                                        <div class="modal-header border-0 pb-0">
                                            <h5 class="modal-title fw-bold">Edit Article</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form method="POST" enctype="multipart/form-data">
                                            <div class="modal-body py-4">
                                                <input type="hidden" name="action" value="edit">
                                                <input type="hidden" name="id" value="<?= $item['id'] ?>">
                                                
                                                <div class="row g-3">
                                                    <div class="col-12 col-md-8">
                                                        <label class="form-label text-secondary fw-semibold">Article Title</label>
                                                        <input type="text" class="form-control" name="title" value="<?= htmlspecialchars($item['title']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-4">
                                                        <label class="form-label text-secondary fw-semibold">Category</label>
                                                        <input type="text" class="form-control" name="category" value="<?= htmlspecialchars($item['category']) ?>" required>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Content Body (HTML supported)</label>
                                                        <textarea class="form-control" name="content" rows="8" required><?= htmlspecialchars($item['content']) ?></textarea>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Update Image (optional)</label>
                                                        <input type="file" class="form-control" name="image" accept="image/*">
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
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-custom">Publish Now</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
