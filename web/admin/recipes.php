<?php
/**
 * Recipes CRUD Manager
 * PHP 8.3 Optimized
 */
$pageTitle = "NewVeg Admin - Recipes";
$headerTitle = "Recipe Book Manager";
$headerSubtitle = "Create, edit, and categorize plant-based nutritional recipes";

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/database.php';

$db = getDatabaseConnection();
$message = '';
$error = '';

// Create uploads directory if it does not exist
$targetDir = __DIR__ . '/../uploads/recipes/';
if (!file_exists($targetDir)) {
    mkdir($targetDir, 0755, true);
}

// Handle CRUD Actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action']) && $_POST['action'] === 'add') {
        $title = trim($_POST['title'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $calories = floatval($_POST['calories'] ?? 0);
        $prepTime = intval($_POST['prep_time_mins'] ?? 0);
        $difficulty = trim($_POST['difficulty'] ?? 'Easy');
        
        // Convert multiline textareas to JSON arrays
        $ingredientsInput = trim($_POST['ingredients'] ?? '');
        $ingredientsArr = array_filter(array_map('trim', explode("\n", $ingredientsInput)));
        $ingredientsJson = json_encode(array_values($ingredientsArr));

        $instructionsInput = trim($_POST['instructions'] ?? '');
        $instructionsArr = array_filter(array_map('trim', explode("\n", $instructionsInput)));
        $instructionsJson = json_encode(array_values($instructionsArr));

        $imageUrl = 'uploads/recipes/default.jpg';

        // Handle Image Upload
        if (!empty($_FILES['image']['name'])) {
            $fileName = time() . '_' . preg_replace("/[^a-zA-Z0-9\._-]/", "", $_FILES['image']['name']);
            $targetFilePath = $targetDir . $fileName;
            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
                $imageUrl = 'uploads/recipes/' . $fileName;
            } else {
                $error = 'Failed to upload image file.';
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
                // If a new image is uploaded, process it
                if (!empty($_FILES['image']['name'])) {
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
                        $error = 'Failed to upload new image.';
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
        // Option to delete physical file if needed
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

// Fetch all recipes
try {
    $recipes = $db->query("SELECT * FROM recipes ORDER BY id DESC")->fetchAll();
} catch (PDOException $e) {
    $recipes = [];
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
        <h4 class="fw-bold m-0">Recipe Directory</h4>
        <button class="btn btn-custom" data-bs-toggle="modal" data-bs-target="#addRecipeModal">
            <i class="bi bi-plus-lg me-2"></i>Add New Recipe
        </button>
    </div>

    <!-- Recipes List Table -->
    <div class="glass-card p-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th style="width: 80px;">Preview</th>
                        <th>Recipe Details</th>
                        <th>Calories</th>
                        <th>Prep Time</th>
                        <th>Difficulty</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($recipes)): ?>
                        <tr>
                            <td colspan="6" class="text-center text-secondary py-5">No recipes found. Click "Add New Recipe" to start.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($recipes as $recipe): 
                            $ingArray = json_decode($recipe['ingredients_json'] ?? '[]', true) ?: [];
                            $insArray = json_decode($recipe['instructions_json'] ?? '[]', true) ?: [];
                            $ingText = implode("\n", $ingArray);
                            $insText = implode("\n", $insArray);
                        ?>
                            <tr>
                                <td>
                                    <img src="../<?= htmlspecialchars($recipe['image_url'] ?? 'uploads/recipes/default.jpg') ?>" class="rounded-3 object-fit-cover" style="width: 60px; height: 60px; border: 1px solid var(--border-color);" alt="Recipe">
                                </td>
                                <td>
                                    <div class="fw-semibold text-white fs-5"><?= htmlspecialchars($recipe['title']) ?></div>
                                    <div class="text-secondary fs-12 text-truncate" style="max-width: 250px;"><?= htmlspecialchars($recipe['description']) ?></div>
                                </td>
                                <td class="text-white"><?= number_format($recipe['calories'], 0) ?> kcal</td>
                                <td class="text-secondary"><?= intval($recipe['prep_time_mins']) ?> mins</td>
                                <td>
                                    <?php if (strtolower($recipe['difficulty']) === 'easy'): ?>
                                        <span class="badge bg-success bg-opacity-15 text-success border border-success border-opacity-20">Easy</span>
                                    <?php elseif (strtolower($recipe['difficulty']) === 'medium'): ?>
                                        <span class="badge bg-warning bg-opacity-15 text-warning border border-warning border-opacity-20">Medium</span>
                                    <?php else: ?>
                                        <span class="badge bg-danger bg-opacity-15 text-danger border border-danger border-opacity-20">Hard</span>
                                    <?php endif; ?>
                                </td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-secondary-custom me-2" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#editRecipeModal<?= $recipe['id'] ?>">
                                        <i class="bi bi-pencil-square"></i>
                                    </button>
                                    <a href="recipes.php?action=delete&id=<?= $recipe['id'] ?>" 
                                       class="btn btn-sm btn-outline-danger border-0" 
                                       onclick="return confirm('Are you sure you want to delete this recipe?');">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>

                            <!-- Edit Modal for each recipe -->
                            <div class="modal fade" id="editRecipeModal<?= $recipe['id'] ?>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content glass-card p-4 border-secondary border-opacity-10 text-white" style="background-color: var(--sidebar-bg);">
                                        <div class="modal-header border-0 pb-0">
                                            <h5 class="modal-title fw-bold">Edit Recipe</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form method="POST" enctype="multipart/form-data">
                                            <div class="modal-body py-4">
                                                <input type="hidden" name="action" value="edit">
                                                <input type="hidden" name="id" value="<?= $recipe['id'] ?>">
                                                
                                                <div class="row g-3">
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Recipe Title</label>
                                                        <input type="text" class="form-control" name="title" value="<?= htmlspecialchars($recipe['title']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Difficulty</label>
                                                        <select class="form-select" name="difficulty">
                                                            <option value="Easy" <?= $recipe['difficulty'] === 'Easy' ? 'selected' : '' ?>>Easy</option>
                                                            <option value="Medium" <?= $recipe['difficulty'] === 'Medium' ? 'selected' : '' ?>>Medium</option>
                                                            <option value="Hard" <?= $recipe['difficulty'] === 'Hard' ? 'selected' : '' ?>>Hard</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Calories (kcal)</label>
                                                        <input type="number" step="0.1" class="form-control" name="calories" value="<?= floatval($recipe['calories']) ?>" required>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Prep Time (mins)</label>
                                                        <input type="number" class="form-control" name="prep_time_mins" value="<?= intval($recipe['prep_time_mins']) ?>" required>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Short Description</label>
                                                        <textarea class="form-control" name="description" rows="2" required><?= htmlspecialchars($recipe['description']) ?></textarea>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Ingredients (one per line)</label>
                                                        <textarea class="form-control" name="ingredients" rows="5" required placeholder="1 cup oats&#10;2 tbsp almond milk"><?= htmlspecialchars($ingText) ?></textarea>
                                                    </div>
                                                    <div class="col-12 col-md-6">
                                                        <label class="form-label text-secondary fw-semibold">Instructions (one per line)</label>
                                                        <textarea class="form-control" name="instructions" rows="5" required placeholder="Mix oats and milk.&#10;Microwave for 2 minutes."><?= htmlspecialchars($insText) ?></textarea>
                                                    </div>
                                                    <div class="col-12">
                                                        <label class="form-label text-secondary fw-semibold">Upload New Image (optional)</label>
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
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-custom">Create Recipe</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
