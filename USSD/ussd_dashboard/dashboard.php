<?php
session_start();
if (!isset($_SESSION['admin_logged_in'])) {
    header("Location: login.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>USSD Dashboard | Telemedicine</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="js/jspdf.umd.min.js"></script>
    <script src="js/data_fetcher.js"></script>
    <script src="js/dashboard.js" defer></script>
</head>
<body class="dashboard-body">
    <div class="sidebar">
        <div class="sidebar-logo">
            <img src="assets/logo.png" alt="Logo">
            <h2>Doc O'clock Admin</h2>
        </div>
        <ul class="sidebar-menu">
            <li class="active"><a href="dashboard.php">USSD</a></li>
            <li><a href="mobile_dashboard.php">Mobile Application</a></li>
            <li><a href="logout.php">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <nav class="top-nav">
            <ul>
                <li><a href="#">View Insights</a></li>
                <li><a href="export_pdf.php" target="_blank">Export PDF</a></li>
            </ul>
        </nav>

        <div class="content-header">
            <h1>USSD Dashboard Overview</h1>
            <p>Track transactions, users, and performance metrics.</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Today’s Transactions</h3>
                <p id="today-count">254</p>
            </div>
            <div class="stat-card">
                <h3>Last Month</h3>
                <p id="month-count">4,312</p>
            </div>
            <div class="stat-card">
                <h3>This Year</h3>
                <p id="year-count">38,790</p>
            </div>
        </div>

        <div class="chart-container">
            <div class="chart-header">
                <h2>Transaction Trends</h2>
                <div class="period-filter">
                    <button class="filter-btn active" data-period="day">Day</button>
                    <button class="filter-btn" data-period="month">Month</button>
                    <button class="filter-btn" data-period="year">Year</button>
                </div>
            </div>
            <canvas id="transactionChart"></canvas>
        </div>
    </div>
</body>
</html>
