<?php
/**
 * User Directory & TTM Stage Viewer
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Users Directory";
$headerTitle = "Registered Users Directory";
$headerSubtitle = "Track user progress, rewards points, and Transtheoretical Model (TTM) stages";

require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Handle actions (Toggle Premium or Admin)
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = intval($_GET['id']);
    $action = $_GET['action'];
    
    // Prevent self-demotion
    if ($id === intval($_SESSION['admin_user_id']) && $action === 'toggle_admin') {
        $error = 'You cannot revoke your own administrator privileges.';
    } else {
        try {
            if ($action === 'toggle_premium') {
                $stmt = $db->prepare("UPDATE users SET is_premium = 1 - is_premium WHERE id = ?");
                $stmt->execute([$id]);
                $message = 'User premium status updated successfully!';
            } elseif ($action === 'toggle_admin') {
                $stmt = $db->prepare("UPDATE users SET is_admin = 1 - is_admin WHERE id = ?");
                $stmt->execute([$id]);
                $message = 'User administrator privileges toggled successfully!';
            }
        } catch (PDOException $e) {
            $error = 'Action failed: ' . $e->getMessage();
        }
    }
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
        $countQuery = "SELECT COUNT(*) FROM users";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE full_name LIKE ? OR email LIKE ? OR ttm_stage LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "SELECT * FROM users";
        if (!empty($search)) {
            $dataQuery .= " WHERE full_name LIKE ? OR email LIKE ? OR ttm_stage LIKE ?";
        }
        $dataQuery .= " ORDER BY id DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $users = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($users)) {
            $html = '<tr><td colspan="7" class="text-center text-secondary py-4">No users found.</td></tr>';
        } else {
            foreach ($users as $user) {
                $stage = $user['ttm_stage'];
                $badgeClass = 'bg-teal-glow';
                if ($stage === 'Maintenance') $badgeClass = 'bg-emerald-glow';
                elseif ($stage === 'Action') $badgeClass = 'bg-purple-glow';
                elseif ($stage === 'Preparation') $badgeClass = 'bg-teal-glow';
                elseif ($stage === 'Contemplation') $badgeClass = 'bg-orange-glow';

                $premiumText = ($user['is_premium'] == 1) ? 'Downgrade to Free' : 'Grant Premium PRO';
                $adminText = ($user['is_admin'] == 1) ? 'Revoke Admin' : 'Make Admin';

                $html .= '<tr>
                    <td>
                        <div class="fw-semibold text-white">' . htmlspecialchars($user['full_name']) . '</div>
                        <div class="text-secondary fs-12">' . htmlspecialchars($user['email']) . '</div>
                        <div class="text-secondary fs-11 mt-0.5">Joined: ' . date('M d, Y', strtotime($user['created_at'])) . '</div>
                    </td>
                    <td>
                        <div class="text-white fs-12">
                            Gender: <strong class="text-secondary">' . htmlspecialchars($user['gender'] ?? 'N/A') . '</strong><br>
                            Age: <strong class="text-secondary">' . ($user['age'] ? intval($user['age']) . ' yrs' : 'N/A') . '</strong><br>
                            Ht/Wt: <strong class="text-secondary">' . ($user['height'] ? floatval($user['height']) . 'cm' : 'N/A') . '</strong> / 
                            <strong class="text-secondary">' . ($user['weight'] ? floatval($user['weight']) . 'kg' : 'N/A') . '</strong>
                        </div>
                    </td>
                    <td>
                        <span class="badge bg-teal-glow">' . htmlspecialchars($user['diet_preference'] ?? 'Vegan') . '</span>
                    </td>
                    <td>
                        <span class="badge ' . $badgeClass . '">' . htmlspecialchars($stage) . '</span>
                    </td>
                    <td class="text-white fw-bold">' . number_format($user['total_points']) . ' pts</td>
                    <td>
                        <div class="d-flex flex-column gap-1">
                            ' . ($user['is_premium'] == 1 ? '<span class="badge bg-emerald-glow text-center py-1">Premium PRO</span>' : '<span class="badge bg-opacity-10 text-secondary text-center py-1">Free Tier</span>') . '
                            ' . ($user['is_admin'] == 1 ? '<span class="badge bg-purple-glow text-center py-1">Administrator</span>' : '') . '
                        </div>
                    </td>
                    <td class="text-end">
                        <a href="user_profile.php?id=' . $user['id'] . '" class="action-link">[ View ]</a>
                        <a href="users.php?action=toggle_premium&id=' . $user['id'] . '" class="action-link">[ ' . $premiumText . ' ]</a>
                        <a href="users.php?action=toggle_admin&id=' . $user['id'] . '" class="action-link">[ ' . $adminText . ' ]</a>
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

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM users");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("SELECT * FROM users ORDER BY id DESC LIMIT :limit OFFSET :offset");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $users = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $users = [];
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

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="user-search" class="form-control" placeholder="Cari user berdasarkan nama/email/kategori...">
        </div>
        <div>
            <span id="user-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
    </div>

    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>User Profile</th>
                        <th>Metrics (Age/Ht/Wt)</th>
                        <th>Diet Pref</th>
                        <th>TTM Stage</th>
                        <th>Points</th>
                        <th>Access Level</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="user-table-body">
                    <?php if (empty($users)): ?>
                        <tr>
                            <td colspan="7" class="text-center text-secondary py-5">No registered users found.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($users as $user): ?>
                            <tr>
                                <td>
                                    <div class="fw-semibold text-white fs-5"><?= htmlspecialchars($user['full_name']) ?></div>
                                    <div class="text-secondary fs-13"><?= htmlspecialchars($user['email']) ?></div>
                                    <div class="text-secondary fs-11 mt-0.5">Registered: <?= date('M d, Y', strtotime($user['created_at'])) ?></div>
                                </td>
                                <td>
                                    <div class="text-white fs-12">
                                        Gender: <strong class="text-secondary"><?= htmlspecialchars($user['gender'] ?? 'N/A') ?></strong><br>
                                        Age: <strong class="text-secondary"><?= $user['age'] ? intval($user['age']) . ' yrs' : 'N/A' ?></strong><br>
                                        Ht/Wt: <strong class="text-secondary"><?= $user['height'] ? floatval($user['height']) . 'cm' : 'N/A' ?></strong> / 
                                        <strong class="text-secondary"><?= $user['weight'] ? floatval($user['weight']) . 'kg' : 'N/A' ?></strong>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-teal-glow">
                                        <?= htmlspecialchars($user['diet_preference'] ?? 'Vegan') ?>
                                    </span>
                                </td>
                                <td>
                                    <?php 
                                    $stage = $user['ttm_stage'];
                                    $badgeClass = 'bg-teal-glow';
                                    if ($stage === 'Maintenance') $badgeClass = 'bg-emerald-glow';
                                    elseif ($stage === 'Action') $badgeClass = 'bg-purple-glow';
                                    elseif ($stage === 'Preparation') $badgeClass = 'bg-teal-glow';
                                    elseif ($stage === 'Contemplation') $badgeClass = 'bg-orange-glow';
                                    ?>
                                    <span class="badge <?= $badgeClass ?>"><?= htmlspecialchars($stage) ?></span>
                                </td>
                                <td class="text-white fw-bold"><?= number_format($user['total_points']) ?> pts</td>
                                <td>
                                    <div class="d-flex flex-column gap-1">
                                        <?php if ($user['is_premium'] == 1): ?>
                                            <span class="badge bg-emerald-glow text-center py-1">Premium PRO</span>
                                        <?php else: ?>
                                            <span class="badge bg-opacity-10 text-secondary text-center py-1">Free Tier</span>
                                        <?php endif; ?>
                                        
                                        <?php if ($user['is_admin'] == 1): ?>
                                            <span class="badge bg-purple-glow text-center py-1">Administrator</span>
                                        <?php endif; ?>
                                    </div>
                                </td>
                                <td class="text-end">
                                    <a href="user_profile.php?id=<?= $user['id'] ?>" class="action-link">[ View ]</a>
                                    <a href="users.php?action=toggle_premium&id=<?= $user['id'] ?>" class="action-link">
                                        [ <?= $user['is_premium'] == 1 ? 'Downgrade to Free' : 'Grant Premium PRO' ?> ]
                                    </a>
                                    <a href="users.php?action=toggle_admin&id=<?= $user['id'] ?>" class="action-link">
                                        [ <?= $user['is_admin'] == 1 ? 'Revoke Admin' : 'Make Admin' ?> ]
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Pagination controls -->
        <div class="d-flex justify-content-center mt-3" id="user-pagination">
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
    fetch(`users.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('user-table-body').innerHTML = res.html;
                document.getElementById('user-pagination').innerHTML = res.pagination;
                document.getElementById('user-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('user-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1;
    debounceTimer = setTimeout(fetchData, 300);
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
