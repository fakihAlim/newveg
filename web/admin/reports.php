<?php
/**
 * Community Reports Moderation Center
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Reported Content";
$headerTitle = "UGC Moderation Center";
$headerSubtitle = "Review reported posts and enforce community guidelines";

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
            FROM community_reports cr
            JOIN community_posts cp ON cr.post_id = cp.id
            JOIN users u ON cr.user_id = u.id
            JOIN users ua ON cp.user_id = ua.id
        ";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE cp.caption LIKE ? OR cr.reason LIKE ? OR ua.full_name LIKE ? OR u.full_name LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "
            SELECT cr.id as report_id, cr.reason, cr.created_at as reported_at, cp.id as post_id, cp.caption, u.full_name as reporter_name, ua.full_name as author_name
            FROM community_reports cr
            JOIN community_posts cp ON cr.post_id = cp.id
            JOIN users u ON cr.user_id = u.id
            JOIN users ua ON cp.user_id = ua.id
        ";
        if (!empty($search)) {
            $dataQuery .= " WHERE cp.caption LIKE ? OR cr.reason LIKE ? OR ua.full_name LIKE ? OR u.full_name LIKE ?";
        }
        $dataQuery .= " ORDER BY cr.created_at DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $reports = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($reports)) {
            $html = '<tr><td colspan="6" class="text-center text-secondary py-4">No reported content found.</td></tr>';
        } else {
            foreach ($reports as $r) {
                $html .= '<tr>
                    <td>' . intval($r['report_id']) . '</td>
                    <td>
                        <div class="fw-semibold text-white">Post #' . intval($r['post_id']) . '</div>
                        <div class="text-secondary fs-12 text-truncate" style="max-width: 250px;">' . htmlspecialchars($r['caption'] ?? '') . '</div>
                        <div class="text-secondary fs-11">Author: ' . htmlspecialchars($r['author_name']) . '</div>
                    </td>
                    <td>
                        <div class="text-white fw-bold">' . htmlspecialchars($r['reason']) . '</div>
                        <div class="text-secondary fs-12">Reported by: ' . htmlspecialchars($r['reporter_name']) . '</div>
                    </td>
                    <td class="text-secondary fs-12">' . date('M d, Y H:i', strtotime($r['reported_at'])) . '</td>
                    <td class="text-end">
                        <a href="reports.php?action=delete&id=' . $r['post_id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Delete this post permanently?\');">[ Delete Post ]</a>
                        <a href="reports.php?action=dismiss&id=' . $r['report_id'] . '" class="action-link" onclick="return confirm(\'Dismiss this report?\');">[ Dismiss Report ]</a>
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

// Handle action=delete (deletes the post, cascades and deletes the reports)
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $postId = intval($_GET['id']);
    try {
        $stmt = $db->prepare("DELETE FROM community_posts WHERE id = ?");
        $stmt->execute([$postId]);
        $message = 'Post and associated reports deleted successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete post: ' . $e->getMessage();
    }
}

// Handle action=dismiss (deletes the report entry from database)
if (isset($_GET['action']) && $_GET['action'] === 'dismiss') {
    $reportId = intval($_GET['id']);
    try {
        $stmt = $db->prepare("DELETE FROM community_reports WHERE id = ?");
        $stmt->execute([$reportId]);
        $message = 'Report dismissed successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to dismiss report: ' . $e->getMessage();
    }
}

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("
        SELECT COUNT(*) 
        FROM community_reports cr
        JOIN community_posts cp ON cr.post_id = cp.id
        JOIN users u ON cr.user_id = u.id
        JOIN users ua ON cp.user_id = ua.id
    ");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("
        SELECT cr.id as report_id, cr.reason, cr.created_at as reported_at, cp.id as post_id, cp.caption, u.full_name as reporter_name, ua.full_name as author_name
        FROM community_reports cr
        JOIN community_posts cp ON cr.post_id = cp.id
        JOIN users u ON cr.user_id = u.id
        JOIN users ua ON cp.user_id = ua.id
        ORDER BY cr.created_at DESC 
        LIMIT :limit OFFSET :offset
    ");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $reports = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $reports = [];
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
        <h4 class="fw-bold m-0">UGC Moderation Center</h4>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="report-search" class="form-control" placeholder="Cari laporan berdasarkan post/alasan/user...">
        </div>
        <div>
            <span id="report-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
    </div>

    <!-- Report List Table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Reported Content</th>
                        <th>Reason Details</th>
                        <th>Reported At</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="report-table-body">
                    <?php if (empty($reports)): ?>
                        <tr>
                            <td colspan="5" class="text-center text-secondary py-5">No reported content found.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($reports as $r): ?>
                            <tr>
                                <td><?= intval($r['report_id']) ?></td>
                                <td>
                                    <div class="fw-semibold text-white">Post #<?= intval($r['post_id']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 250px;"><?= htmlspecialchars($r['caption'] ?? '') ?></div>
                                    <div class="text-secondary fs-11">Author: <?= htmlspecialchars($r['author_name']) ?></div>
                                </td>
                                <td>
                                    <div class="text-white fw-bold"><?= htmlspecialchars($r['reason']) ?></div>
                                    <div class="text-secondary fs-12">Reported by: <?= htmlspecialchars($r['reporter_name']) ?></div>
                                </td>
                                <td class="text-secondary fs-12"><?= date('M d, Y H:i', strtotime($r['reported_at'])) ?></td>
                                <td class="text-end">
                                    <a href="reports.php?action=delete&id=<?= $r['post_id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Delete this post permanently?');">
                                        [ Delete Post ]
                                    </a>
                                    <a href="reports.php?action=dismiss&id=<?= $r['report_id'] ?>" 
                                       class="action-link" 
                                       onclick="return confirm('Dismiss this report?');">
                                        [ Dismiss Report ]
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Pagination controls -->
        <div class="d-flex justify-content-center mt-3" id="report-pagination">
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
    fetch(`reports.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('report-table-body').innerHTML = res.html;
                document.getElementById('report-pagination').innerHTML = res.pagination;
                document.getElementById('report-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('report-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1;
    debounceTimer = setTimeout(fetchData, 300);
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
