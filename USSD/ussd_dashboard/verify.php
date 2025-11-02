<?php
// Verification flow has been removed as part of 2FA/verification rollback.
// Keep a simple informative page in case old links are followed.
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification Disabled</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .verify-card { max-width: 560px; margin: 60px auto; padding: 30px; background: rgba(255,255,255,0.04); border-radius: 12px; text-align:center; color:#fff; }
        .verify-card h2 { margin-bottom: 10px; }
        .verify-card p { color: #b8c6db; }
        .login-link { display:inline-block; margin-top:16px; color:#00e6ff; text-decoration:none; padding:8px 16px; border-radius:8px; border:1px solid rgba(0,230,255,0.15); }
    </style>
</head>
<body class="login-body">
    <div class="login-container">
        <div class="verify-card">
            <img src="assets/logo.png" alt="Logo" class="login-logo" style="width:90px;">
            <h2>Email verification disabled</h2>
            <p>We've removed the email verification (2FA) flow. Accounts created via the signup page are active immediately.</p>
            <a href="login.php" class="login-link">Go to Login</a>
        </div>
    </div>
</body>
</html>
