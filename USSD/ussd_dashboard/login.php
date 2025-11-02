<?php
session_start();
include('db_connect.php');

$error = ""; // Initialize empty error message

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    // Prepare statement to fetch hashed password for this user
    $stmt = $conn->prepare("SELECT id, password FROM administrators WHERE email = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();
    $admin = $result->fetch_assoc();
    $stmt->close();

    // Verify the password
    if ($admin && password_verify($password, $admin['password'])) {
        $_SESSION['admin_logged_in'] = true;
        $_SESSION['admin_id'] = $admin['id'];
        $_SESSION['admin_email'] = $username;
        header("Location: dashboard.php");
        exit();
    } else {
        $error = "Invalid email or password!";
    }

    if (isset($_SESSION['signup_success'])) {
        $success = "Registration successful! Please login.";
        unset($_SESSION['signup_success']);
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login | USSD Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-body">
    <div class="login-container">
        <div class="login-card">
            <img src="assets/logo.png" alt="Logo" class="login-logo">
            <h2>Admin Login</h2>

            <?php if (!empty($error)) : ?>
                <div class="error"><?php echo $error; ?></div>
            <?php endif; ?>

            <form method="POST" action="">
                <div class="login-form">
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="username" placeholder="Enter your email" required>
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" placeholder="Enter password" required>
                    </div>
                    <button type="submit" class="login-btn">Login</button>
                </div>
            </form>
            <p style="margin-top: 20px; color: #b8c6db;">Don't have an account? <a href="signup.php" style="color: #00e6ff; text-decoration: none;">Sign up here</a></p>
        </div>
    </div>
</body>
</html>
