<?php
/**
 * Community Posts Manager
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Community Feed";
$headerTitle = "Community Feed Moderator";
$headerSubtitle = "Review, search, and manage user shared food logs and community posts";

require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// AJAX Live Search & Pagination Handler
if (isset($_GET['ajax']) && $_GET['ajax'] == '1') {
    header('Content-Type: application/json');
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = 10;
    $offset = ($page - 1) * $limit;

    try {
        $countQuery = "
            SELECT COUNT(*) 
            FROM community_posts cp
            LEFT JOIN users u ON cp.user_id = u.id
        ";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE cp.caption LIKE ? OR u.full_name LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "
            SELECT cp.*, u.full_name as user_name, u.email as user_email, fl.food_name, fl.image_path as food_image 
            FROM community_posts cp
            LEFT JOIN users u ON cp.user_id = u.id
            LEFT JOIN food_logs fl ON cp.food_log_id = fl.id
        ";
        if (!empty($search)) {
            $dataQuery .= " WHERE cp.caption LIKE ? OR u.full_name LIKE ?";
        }
        $dataQuery .= " ORDER BY cp.created_at DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $posts = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($posts)) {
            $html = '<tr><td colspan="6" class="text-center text-secondary py-4">No community posts found.</td></tr>';
        } else {
            foreach ($posts as $post) {
                // Determine photo path
                $imageSource = '../uploads/recipes/default.jpg';
                if (!empty($post['food_image'])) {
                    // Check if it's a relative/absolute path on disk
                    if (file_exists(__DIR__ . '/../../' . $post['food_image'])) {
                        $imageSource = '../' . htmlspecialchars($post['food_image']);
                    }
                }
                
                $html .= '<tr>
                    <td>' . intval($post['id']) . '</td>
                    <td>
                        <img src="' . $imageSource . '" class="rounded" style="width: 50px; height: 50px; object-fit: cover; border: 1px solid var(--border-color);" alt="Post Food Image">
                    </td>
                    <td>
                        <div class="fw-semibold text-white">' . htmlspecialchars($post['user_name']) . '</div>
                        <div class="text-secondary fs-12">' . htmlspecialchars($post['user_email']) . '</div>
                    </td>
                    <td>
                        <div class="text-white">' . htmlspecialchars($post['caption'] ?? '') . '</div>
                        <div class="text-secondary fs-11 mt-1">Logged Item: ' . htmlspecialchars($post['food_name'] ?? 'Unknown Meal') . '</div>
                    </td>
                    <td class="text-white fw-bold">' . intval($post['likes_count']) . ' likes</td>
                    <td class="text-secondary fs-12">' . date('M d, Y H:i', strtotime($post['created_at'])) . '</td>
                    <td class="text-end">
                        <a href="community.php?action=delete&id=' . $post['id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Are you sure you want to remove this community post?\');">[ Hapus ]</a>
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

// Handle delete
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $id = intval($_GET['id']);
    try {
        $stmt = $db->prepare("DELETE FROM community_posts WHERE id = ?");
        $stmt->execute([$id]);
        $message = 'Community post removed successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete post: ' . $e->getMessage();
    }
}

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM community_posts");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("
        SELECT cp.*, u.full_name as user_name, u.email as user_email, fl.food_name, fl.image_path as food_image 
        FROM community_posts cp
        LEFT JOIN users u ON cp.user_id = u.id
        LEFT JOIN food_logs fl ON cp.food_log_id = fl.id
        ORDER BY cp.created_at DESC 
        LIMIT :limit OFFSET :offset
    ");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $posts = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $posts = [];
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
        <h4 class="fw-bold m-0">Community Feed Moderator</h4>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="post-search" class="form-control" placeholder="Cari postingan berdasarkan user/caption...">
        </div>
        <div>
            <span id="post-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
    </div>

    <!-- Post list table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="width: 80px;">Food Pic</th>
                        <th>User Profile</th>
                        <th>Post Caption</th>
                        <th>Engagement</th>
                        <th>Published</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="post-table-body">
                    <?php if (empty($posts)): ?>
                        <tr>
                            <td colspan="7" class="text-center text-secondary py-5">No community posts found.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($posts as $post): 
                            $imageSource = '../uploads/recipes/default.jpg';
                            if (!empty($post['food_image'])) {
                                if (file_exists(__DIR__ . '/../../' . $post['food_image'])) {
                                    $imageSource = '../' . htmlspecialchars($post['food_image']);
                                }
                            }
                        ?>
                            <tr>
                                <td><?= intval($post['id']) ?></td>
                                <td>
                                    <img src="<?= $imageSource ?>" class="rounded object-fit-cover" style="width: 50px; height: 50px; border: 1px solid var(--border-color);" alt="Post Food Image">
                                </td>
                                <td>
                                    <div class="fw-semibold text-white"><?= htmlspecialchars($post['user_name']) ?></div>
                                    <div class="text-secondary fs-13"><?= htmlspecialchars($post['user_email']) ?></div>
                                </td>
                                <td>
                                    <div class="text-white"><?= htmlspecialchars($post['caption'] ?? '') ?></div>
                                    <div class="text-secondary fs-11 mt-1">Logged Item: <?= htmlspecialchars($post['food_name'] ?? 'Unknown Meal') ?></div>
                                </td>
                                <td class="text-white fw-bold"><?= intval($post['likes_count']) ?> likes</td>
                                <td class="text-secondary fs-12"><?= date('M d, Y H:i', strtotime($post['created_at'])) ?></td>
                                <td class="text-end">
                                    <a href="community.php?action=delete&id=<?= $post['id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Are you sure you want to remove this community post?');">
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
        <div class="d-flex justify-content-center mt-3" id="post-pagination">
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

<script>
let currentSearch = '';
let currentPage = 1;
let debounceTimer = null;

function changePage(page) {
    currentPage = page;
    fetchData();
}

function fetchData() {
    fetch(`community.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('post-table-body').innerHTML = res.html;
                document.getElementById('post-pagination').innerHTML = res.pagination;
                document.getElementById('post-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('post-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1;
    debounceTimer = setTimeout(fetchData, 300);
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
