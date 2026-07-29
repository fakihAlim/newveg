<?php
/**
 * Admin Portal Login
 * PHP 8.3 Optimized
 */
session_start();

require_once __DIR__ . '/../config/database.php';

// Redirect if already logged in
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header('Location: index.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if (empty($email) || empty($password)) {
        $error = 'Please fill in all fields.';
    } else {
        $db = getDatabaseConnection();
        try {
            $stmt = $db->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
            $stmt->execute([$email]);
            $user = $stmt->fetch();

            if ($user && password_verify($password, $user['password'])) {
                if ($user['is_admin'] == 1) {
                    $_SESSION['admin_logged_in'] = true;
                    $_SESSION['admin_user_id'] = $user['id'];
                    $_SESSION['admin_name'] = $user['full_name'];
                    $_SESSION['admin_email'] = $user['email'];
                    
                    header('Location: index.php');
                    exit;
                } else {
                    $error = 'Access denied. Administrator privileges required.';
                }
            } else {
                $error = 'Invalid email address or password.';
            }
        } catch (PDOException $e) {
            $error = 'Database connection error: ' . $e->getMessage();
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NewVeg CMS - Sign In</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="assets/css/admin.css" rel="stylesheet">
    <style>
        body {
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8fafc;
        }
        .login-card {
            width: 100%;
            max-width: 420px;
            padding: 30px;
            border-radius: 12px;
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -4px rgba(0, 0, 0, 0.05);
        }
    </style>
</head>
<body>

<div class="login-card animated-fade">
    <div class="text-center mb-4">
        <div class="rounded-circle bg-teal-glow d-inline-flex align-items-center justify-content-center mb-3" style="width: 54px; height: 54px;">
            <i class="bi bi-egg-fried fs-2 text-teal" style="color: #0d9488;"></i>
        </div>
        <h4 class="fw-bold mb-1">Welcome Back</h4>
        <p class="text-secondary fs-14">NewVeg Plant-Based CMS Portal</p>
    </div>

    <?php if (!empty($error)): ?>
        <div class="alert alert-danger d-flex align-items-center mb-4 py-2 border-0 bg-danger bg-opacity-10 text-danger" role="alert" style="border-radius: 8px; font-size: 14px;">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-6"></i>
            <div><?= htmlspecialchars($error) ?></div>
        </div>
    <?php endif; ?>

    <form method="POST" action="login.php">
        <div class="mb-3">
            <label for="email" class="form-label text-secondary fw-semibold fs-14">Email Address</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-light-subtle text-secondary"><i class="bi bi-envelope"></i></span>
                <input type="email" class="form-control" id="email" name="email" required placeholder="admin@aa.com" value="<?= htmlspecialchars($email ?? '') ?>">
            </div>
        </div>

        <div class="mb-4">
            <label for="password" class="form-label text-secondary fw-semibold fs-14">Password</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-light-subtle text-secondary"><i class="bi bi-lock"></i></span>
                <input type="password" class="form-control" id="password" name="password" required placeholder="••••••••">
            </div>
        </div>

        <button type="submit" class="btn btn-custom w-100 py-2">Sign In to Dashboard</button>
    </form>

    <div class="text-center mt-4">
        <p class="text-secondary fs-12 mb-0">&copy; 2026 NewVeg. Optimized for low-memory VPS.</p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
