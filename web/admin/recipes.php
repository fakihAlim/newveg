<?php
/**
 * Recipes CRUD Manager
 * PHP 8.3 Optimized with server-side pagination & live search
 */
$pageTitle = "NewVeg Admin - Recipes";
$headerTitle = "Recipe Book Manager";
$headerSubtitle = "Create, edit, and categorize plant-based nutritional recipes";

require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

$targetDir = __DIR__ . '/../uploads/recipes/';
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
        $countQuery = "SELECT COUNT(*) FROM recipes";
        $params = [];
        if (!empty($search)) {
            $countQuery .= " WHERE title LIKE ? OR description LIKE ?";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $totalItems = $countStmt->fetchColumn();
        $totalPages = max(1, ceil($totalItems / $limit));

        $dataQuery = "SELECT * FROM recipes";
        if (!empty($search)) {
            $dataQuery .= " WHERE title LIKE ? OR description LIKE ?";
        }
        $dataQuery .= " ORDER BY id DESC LIMIT $limit OFFSET $offset";
        
        $dataStmt = $db->prepare($dataQuery);
        $dataStmt->execute($params);
        $recipes = $dataStmt->fetchAll();

        // Render HTML rows
        $html = '';
        if (empty($recipes)) {
            $html = '<tr><td colspan="7" class="text-center text-secondary py-4">No recipes found.</td></tr>';
        } else {
            foreach ($recipes as $recipe) {
                $ingText = '';
                if (!empty($recipe['ingredients_json'])) {
                    $ingArr = json_decode($recipe['ingredients_json'], true);
                    if (is_array($ingArr)) {
                        $ingText = implode("\n", $ingArr);
                    }
                }
                $insText = '';
                if (!empty($recipe['instructions_json'])) {
                    $insArr = json_decode($recipe['instructions_json'], true);
                    if (is_array($insArr)) {
                        $insText = implode("\n", $insArr);
                    }
                }
                
                $recipeJson = htmlspecialchars(json_encode([
                    'id' => $recipe['id'],
                    'title' => $recipe['title'],
                    'description' => $recipe['description'],
                    'calories' => $recipe['calories'],
                    'prep_time_mins' => $recipe['prep_time_mins'],
                    'difficulty' => $recipe['difficulty'],
                    'ingredients' => $ingText,
                    'instructions' => $insText
                ]), ENT_QUOTES, 'UTF-8');

                $diffClass = 'bg-teal-glow';
                if (strtolower($recipe['difficulty']) === 'medium') {
                    $diffClass = 'bg-orange-glow';
                } elseif (strtolower($recipe['difficulty']) === 'hard') {
                    $diffClass = 'bg-purple-glow';
                }

                $html .= '<tr>
                    <td>' . intval($recipe['id']) . '</td>
                    <td>
                        <img src="../' . htmlspecialchars($recipe['image_url'] ?? 'uploads/recipes/default.jpg') . '" class="rounded" style="width: 50px; height: 50px; object-fit: cover; border: 1px solid var(--border-color);" alt="Recipe">
                    </td>
                    <td>
                        <div class="fw-semibold text-white">' . htmlspecialchars($recipe['title']) . '</div>
                        <div class="text-secondary fs-12 text-truncate" style="max-width: 250px;">' . htmlspecialchars($recipe['description']) . '</div>
                    </td>
                    <td class="text-white">' . number_format($recipe['calories'], 0) . ' kcal</td>
                    <td class="text-secondary">' . intval($recipe['prep_time_mins']) . ' mins</td>
                    <td><span class="badge ' . $diffClass . '">' . htmlspecialchars($recipe['difficulty']) . '</span></td>
                    <td class="text-end">
                        <a href="#" class="action-link btn-edit-recipe" data-recipe="' . $recipeJson . '">[ Edit ]</a>
                        <a href="recipes.php?action=delete&id=' . $recipe['id'] . '" class="action-link action-link-danger" onclick="return confirm(\'Are you sure you want to delete this recipe?\');">[ Hapus ]</a>
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
        $description = trim($_POST['description'] ?? '');
        $calories = floatval($_POST['calories'] ?? 0);
        $prepTime = intval($_POST['prep_time_mins'] ?? 0);
        $difficulty = trim($_POST['difficulty'] ?? 'Easy');
        
        $ingredientsInput = trim($_POST['ingredients'] ?? '');
        $ingredientsArr = array_filter(array_map('trim', explode("\n", $ingredientsInput)));
        $ingredientsJson = json_encode(array_values($ingredientsArr));

        $instructionsInput = trim($_POST['instructions'] ?? '');
        $instructionsArr = array_filter(array_map('trim', explode("\n", $instructionsInput)));
        $instructionsJson = json_encode(array_values($instructionsArr));

        $imageUrl = 'uploads/recipes/default.jpg';

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
                        $imageUrl = 'uploads/recipes/' . $fileName;
                    } else {
                        $error = 'Failed to upload image: Unable to move file to the target directory.';
                    }
                }
            }
        }

        if (empty($title)) {
            $error = 'Recipe title is required.';
        }

        if (empty($error)) {
            try {
                $stmt = $db->prepare("
                    INSERT INTO recipes (title, description, image_url, calories, prep_time_mins, difficulty, ingredients_json, instructions_json)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ");
                $stmt->execute([$title, $description, $imageUrl, $calories, $prepTime, $difficulty, $ingredientsJson, $instructionsJson]);
                $message = 'Recipe added successfully!';
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }

    if (isset($_POST['action']) && $_POST['action'] === 'edit') {
        $id = intval($_POST['id']);
        $title = trim($_POST['title'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $calories = floatval($_POST['calories'] ?? 0);
        $prepTime = intval($_POST['prep_time_mins'] ?? 0);
        $difficulty = trim($_POST['difficulty'] ?? 'Easy');

        $ingredientsInput = trim($_POST['ingredients'] ?? '');
        $ingredientsArr = array_filter(array_map('trim', explode("\n", $ingredientsInput)));
        $ingredientsJson = json_encode(array_values($ingredientsArr));

        $instructionsInput = trim($_POST['instructions'] ?? '');
        $instructionsArr = array_filter(array_map('trim', explode("\n", $instructionsInput)));
        $instructionsJson = json_encode(array_values($instructionsArr));

        if (empty($title)) {
            $error = 'Recipe title is required.';
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
                                $imageUrl = 'uploads/recipes/' . $fileName;
                                
                                $stmt = $db->prepare("
                                    UPDATE recipes 
                                    SET title = ?, description = ?, image_url = ?, calories = ?, prep_time_mins = ?, difficulty = ?, ingredients_json = ?, instructions_json = ?
                                    WHERE id = ?
                                ");
                                $stmt->execute([$title, $description, $imageUrl, $calories, $prepTime, $difficulty, $ingredientsJson, $instructionsJson, $id]);
                            } else {
                                $error = 'Failed to upload image: Unable to move file to the target directory.';
                            }
                        }
                    }
                } else {
                    $stmt = $db->prepare("
                        UPDATE recipes 
                        SET title = ?, description = ?, calories = ?, prep_time_mins = ?, difficulty = ?, ingredients_json = ?, instructions_json = ?
                        WHERE id = ?
                    ");
                    $stmt->execute([$title, $description, $calories, $prepTime, $difficulty, $ingredientsJson, $instructionsJson, $id]);
                }
                
                if (empty($error)) {
                    $message = 'Recipe updated successfully!';
                }
            } catch (PDOException $e) {
                $error = 'Database error: ' . $e->getMessage();
            }
        }
    }
}

// Handle Delete Action
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $id = intval($_GET['id']);
    try {
        $fileStmt = $db->prepare("SELECT image_url FROM recipes WHERE id = ?");
        $fileStmt->execute([$id]);
        $oldImage = $fileStmt->fetchColumn();
        if ($oldImage && $oldImage !== 'uploads/recipes/default.jpg' && file_exists(__DIR__ . '/../' . $oldImage)) {
            @unlink(__DIR__ . '/../' . $oldImage);
        }

        $stmt = $db->prepare("DELETE FROM recipes WHERE id = ?");
        $stmt->execute([$id]);
        $message = 'Recipe deleted successfully!';
    } catch (PDOException $e) {
        $error = 'Failed to delete recipe: ' . $e->getMessage();
    }
}

// Initial Page Load Data (Page 1, Empty Search)
$limit = 10;
$page = 1;
$offset = 0;
try {
    $countStmt = $db->query("SELECT COUNT(*) FROM recipes");
    $totalItems = $countStmt->fetchColumn();
    $totalPages = max(1, ceil($totalItems / $limit));

    $dataStmt = $db->prepare("SELECT * FROM recipes ORDER BY id DESC LIMIT :limit OFFSET :offset");
    $dataStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $dataStmt->execute();
    $recipes = $dataStmt->fetchAll();
} catch (PDOException $e) {
    $recipes = [];
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
        <h4 class="fw-bold m-0">Recipe Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addRecipeModal">
            [ Tambah Resep Baru ]
        </button>
    </div>

    <!-- Search input and count badge -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="max-width: 320px; width: 100%;">
            <input type="text" id="recipe-search" class="form-control" placeholder="Cari resep berdasarkan judul/deskripsi...">
        </div>
        <div>
            <span id="recipe-info" class="text-secondary fw-semibold fs-13">
                Halaman <?= $page ?> dari <?= $totalPages ?> (Total: <?= $totalItems ?> data)
            </span>
        </div>
    </div>

    <!-- Recipes List Table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="width: 80px;">Preview</th>
                        <th>Recipe Details</th>
                        <th>Calories</th>
                        <th>Prep Time</th>
                        <th>Difficulty</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="recipe-table-body">
                    <?php if (empty($recipes)): ?>
                        <tr>
                            <td colspan="7" class="text-center text-secondary py-5">No recipes found. Click "[ Tambah Resep Baru ]" to start.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($recipes as $recipe): 
                            $ingArray = json_decode($recipe['ingredients_json'] ?? '[]', true) ?: [];
                            $insArray = json_decode($recipe['instructions_json'] ?? '[]', true) ?: [];
                            $ingText = implode("\n", $ingArray);
                            $insText = implode("\n", $insArray);
                            
                            $recipeJson = htmlspecialchars(json_encode([
                                'id' => $recipe['id'],
                                'title' => $recipe['title'],
                                'description' => $recipe['description'],
                                'calories' => $recipe['calories'],
                                'prep_time_mins' => $recipe['prep_time_mins'],
                                'difficulty' => $recipe['difficulty'],
                                'ingredients' => $ingText,
                                'instructions' => $insText
                            ]), ENT_QUOTES, 'UTF-8');
                        ?>
                            <tr>
                                <td><?= intval($recipe['id']) ?></td>
                                <td>
                                    <img src="../<?= htmlspecialchars($recipe['image_url'] ?? 'uploads/recipes/default.jpg') ?>" class="rounded object-fit-cover" style="width: 50px; height: 50px; border: 1px solid var(--border-color);" alt="Recipe">
                                </td>
                                <td>
                                    <div class="fw-semibold text-white"><?= htmlspecialchars($recipe['title']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 250px;"><?= htmlspecialchars($recipe['description']) ?></div>
                                </td>
                                <td class="text-white"><?= number_format($recipe['calories'], 0) ?> kcal</td>
                                <td class="text-secondary"><?= intval($recipe['prep_time_mins']) ?> mins</td>
                                <td>
                                    <?php 
                                    $diffClass = 'bg-teal-glow';
                                    if (strtolower($recipe['difficulty']) === 'medium') {
                                        $diffClass = 'bg-orange-glow';
                                    } elseif (strtolower($recipe['difficulty']) === 'hard') {
                                        $diffClass = 'bg-purple-glow';
                                    }
                                    ?>
                                    <span class="badge <?= $diffClass ?>"><?= htmlspecialchars($recipe['difficulty']) ?></span>
                                </td>
                                <td class="text-end">
                                    <a href="#" class="action-link btn-edit-recipe" data-recipe="<?= $recipeJson ?>">[ Edit ]</a>
                                    <a href="recipes.php?action=delete&id=<?= $recipe['id'] ?>" 
                                       class="action-link action-link-danger" 
                                       onclick="return confirm('Are you sure you want to delete this recipe?');">
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
        <div class="d-flex justify-content-center mt-3" id="recipe-pagination">
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
<div class="modal fade" id="editRecipeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Edit Recipe</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="edit-id">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Recipe Title</label>
                            <input type="text" class="form-control" name="title" id="edit-title" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Difficulty</label>
                            <select class="form-select" name="difficulty" id="edit-difficulty">
                                <option value="Easy">Easy</option>
                                <option value="Medium">Medium</option>
                                <option value="Hard">Hard</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Calories (kcal)</label>
                            <input type="number" step="0.1" class="form-control" name="calories" id="edit-calories" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Prep Time (mins)</label>
                            <input type="number" class="form-control" name="prep_time_mins" id="edit-prep-time" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Short Description</label>
                            <textarea class="form-control" name="description" id="edit-description" rows="2" required></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Ingredients (one per line)</label>
                            <textarea class="form-control" name="ingredients" id="edit-ingredients" rows="5" required></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Instructions (one per line)</label>
                            <textarea class="form-control" name="instructions" id="edit-instructions" rows="5" required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Upload New Image (optional)</label>
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
<div class="modal fade" id="addRecipeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Add New Recipe</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body py-4">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Recipe Title</label>
                            <input type="text" class="form-control" name="title" required placeholder="e.g., Creamy Vegan Tofu Salad">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Difficulty</label>
                            <select class="form-select" name="difficulty">
                                <option value="Easy" selected>Easy</option>
                                <option value="Medium">Medium</option>
                                <option value="Hard">Hard</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Calories (kcal)</label>
                            <input type="number" step="0.1" class="form-control" name="calories" required placeholder="e.g., 350.00">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Prep Time (mins)</label>
                            <input type="number" class="form-control" name="prep_time_mins" required placeholder="e.g., 15">
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Short Description</label>
                            <textarea class="form-control" name="description" rows="2" required placeholder="Brief summary of the recipe steps or highlight..."></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Ingredients (one per line)</label>
                            <textarea class="form-control" name="ingredients" rows="5" required placeholder="1 cup rolled oats&#10;1 ripe banana&#10;2 tbsp chia seeds"></textarea>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-secondary fw-semibold">Instructions (one per line)</label>
                            <textarea class="form-control" name="instructions" rows="5" required placeholder="Mash the banana in a bowl.&#10;Stir in the oats and chia seeds.&#10;Bake at 180C for 12 minutes."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-secondary fw-semibold">Upload Recipe Image</label>
                            <input type="file" class="form-control" name="image" accept="image/*">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">[ Batal ]</button>
                    <button type="submit" class="btn btn-custom">[ Buat Resep ]</button>
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
    fetch(`recipes.php?ajax=1&search=${encodeURIComponent(currentSearch)}&page=${currentPage}`)
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                document.getElementById('recipe-table-body').innerHTML = res.html;
                document.getElementById('recipe-pagination').innerHTML = res.pagination;
                document.getElementById('recipe-info').innerText = res.info;
            }
        })
        .catch(err => console.error('Fetch error:', err));
}

document.getElementById('recipe-search').addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    currentSearch = e.target.value;
    currentPage = 1; // reset to first page on search
    debounceTimer = setTimeout(fetchData, 300);
});

// Dynamic edit modal data hydration
document.addEventListener('click', function(e) {
    const editBtn = e.target.closest('.btn-edit-recipe');
    if (editBtn) {
        e.preventDefault();
        try {
            const recipe = JSON.parse(editBtn.getAttribute('data-recipe'));
            
            // Populate fields
            document.getElementById('edit-id').value = recipe.id;
            document.getElementById('edit-title').value = recipe.title;
            document.getElementById('edit-difficulty').value = recipe.difficulty;
            document.getElementById('edit-calories').value = recipe.calories;
            document.getElementById('edit-prep-time').value = recipe.prep_time_mins;
            document.getElementById('edit-description').value = recipe.description;
            document.getElementById('edit-ingredients').value = recipe.ingredients;
            document.getElementById('edit-instructions').value = recipe.instructions;

            // Trigger Bootstrap modal open
            const editModal = new bootstrap.Modal(document.getElementById('editRecipeModal'));
            editModal.show();
        } catch (err) {
            console.error('Error parsing recipe JSON:', err);
        }
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
