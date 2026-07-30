<?php
/**
 * Shared Header Layout Component
 * PHP 8.3 Optimized
 */
require_once __DIR__ . '/auth_check.php';

$currentPage = basename($_SERVER['PHP_SELF']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $pageTitle ?? 'NewVeg Admin CMS' ?></title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom Dark Premium Styles -->
    <link href="assets/css/admin.css" rel="stylesheet">
</head>
<body>

<div class="wrapper">
    <!-- Sidebar -->
    <nav id="sidebar">
        <div class="sidebar-header d-flex align-items-center">
            <h4 class="m-0 gradient-text">NewVeg CMS</h4>
        </div>

        <ul class="list-unstyled components">
            <li class="<?= $currentPage === 'index.php' ? 'active' : '' ?>">
                <a href="index.php">Dashboard</a>
            </li>
            <li class="<?= $currentPage === 'recipes.php' ? 'active' : '' ?>">
                <a href="recipes.php">Recipes</a>
            </li>
            <li class="<?= $currentPage === 'news.php' ? 'active' : '' ?>">
                <a href="news.php">News & Articles</a>
            </li>
            <li class="<?= $currentPage === 'myths.php' ? 'active' : '' ?>">
                <a href="myths.php">Myths & Facts</a>
            </li>
            <li class="<?= $currentPage === 'quizzes.php' ? 'active' : '' ?>">
                <a href="quizzes.php">Daily Quizzes</a>
            </li>
            <li class="<?= $currentPage === 'users.php' ? 'active' : '' ?>">
                <a href="users.php">Users & TTM</a>
            </li>
            <li class="<?= $currentPage === 'community.php' ? 'active' : '' ?>">
                <a href="community.php">Community Feed</a>
            </li>
            <li class="<?= $currentPage === 'settings.php' ? 'active' : '' ?>">
                <a href="settings.php">System Config</a>
            </li>
            <li class="mt-4">
                <a href="logout.php" class="text-danger">Sign Out</a>
            </li>
        </ul>
    </nav>

    <!-- Main Content Area -->
    <div id="content">
        <!-- Top Navbar -->
        <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom border-secondary border-opacity-10">
            <div>
                <h2 class="fw-bold m-0"><?= $headerTitle ?? 'Dashboard' ?></h2>
                <p class="text-secondary m-0 fs-14"><?= $headerSubtitle ?? 'Overview & Core Statistics' ?></p>
            </div>
            <div class="d-flex align-items-center">
                <div class="text-end me-3">
                    <span class="d-block fw-semibold"><?= htmlspecialchars($_SESSION['admin_name'] ?? 'Admin') ?></span>
                    <span class="badge bg-teal-glow badge-glow" style="font-size: 10px;">SUPER ADMIN</span>
                </div>
                <div class="rounded bg-teal-glow d-flex align-items-center justify-content-center fw-bold text-white" style="width: 42px; height: 42px; font-size: 14px;">
                    AV
                </div>
            </div>
        </div>
