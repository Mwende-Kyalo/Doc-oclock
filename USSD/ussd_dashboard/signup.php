<?php
session_start();
require_once 'db_connect.php';

if (!isset($conn)) {
    die("Database connection failed");
}

$errors = [];
$success = false;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $fullname = trim($_POST['fullname']);
    $email = trim($_POST['email']);
    $contact = trim($_POST['contact']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];

    // Validate Full Name
    if (empty($fullname)) {
        $errors[] = "Full name is required";
    } elseif (strlen($fullname) < 3) {
        $errors[] = "Full name must be at least 3 characters long";
    }

    // Validate Email
    if (empty($email)) {
        $errors[] = "Email is required";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Please enter a valid email address";
    } else {
        // Create administrators table if it doesn't exist (simple schema without verification fields)
        $create_table = "CREATE TABLE IF NOT EXISTS administrators (
            id INT AUTO_INCREMENT PRIMARY KEY,
            fullname VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            contact VARCHAR(15) NOT NULL,
            password VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";

        if (!$conn->query($create_table)) {
            $errors[] = "Database error: " . $conn->error;
        } else {
            // Check if email already exists
            $stmt = $conn->prepare("SELECT id FROM administrators WHERE email = ?");
            if ($stmt === false) {
                $errors[] = "Database error: " . $conn->error;
            } else {
                $stmt->bind_param("s", $email);
                $stmt->execute();
                $result = $stmt->get_result();
                if ($result->num_rows > 0) {
                    $errors[] = "This email is already registered";
                }
                $stmt->close();
            }
        }
    }

    // Validate Contact
    if (empty($contact)) {
        $errors[] = "Contact number is required";
    } elseif (!preg_match("/^[0-9]{10}$/", $contact)) {
        $errors[] = "Please enter a valid 10-digit contact number";
    }

    // Validate Password
    if (empty($password)) {
        $errors[] = "Password is required";
    } elseif (strlen($password) < 8) {
        $errors[] = "Password must be at least 8 characters long";
    } elseif (!preg_match("/[A-Z]/", $password)) {
        $errors[] = "Password must contain at least one uppercase letter";
    } elseif (!preg_match("/[a-z]/", $password)) {
        $errors[] = "Password must contain at least one lowercase letter";
    } elseif (!preg_match("/[0-9]/", $password)) {
        $errors[] = "Password must contain at least one number";
    } elseif (!preg_match("/[!@#$%^&*()\\-_=+{};:,<.>]/", $password)) {
        $errors[] = "Password must contain at least one special character";
    }

    // Validate Confirm Password
    if ($password !== $confirm_password) {
        $errors[] = "Passwords do not match";
    }

    if (empty($errors)) {
        // Hash the password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Insert the new administrator (no verification token/is_verified)
        $stmt = $conn->prepare("INSERT INTO administrators (fullname, email, contact, password) VALUES (?, ?, ?, ?)");
        if ($stmt === false) {
            $errors[] = "Database error: " . $conn->error;
        } else {
            $stmt->bind_param("ssss", $fullname, $email, $contact, $hashed_password);

            if ($stmt->execute()) {
                $success = true;
                // show success on this page and prompt to login
            } else {
                $errors[] = "Registration failed. Please try again.";
            }
            $stmt->close();
        }
    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Sign Up | Telemedicine</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .password-rules {
            color: #b8c6db;
            font-size: 12px;
            margin-top: 5px;
            text-align: left;
        }
        .password-rules ul {
            list-style: none;
            padding-left: 0;
        }
        .password-rules li {
            margin: 3px 0;
            display: flex;
            align-items: center;
        }
        .password-rules li:before {
            content: "•";
            color: #00e6ff;
            margin-right: 5px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .success-message {
            background: rgba(0, 230, 255, 0.1);
            color: #00e6ff;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 10px;
            text-align: center;
        }
    </style>
</head>
<body class="login-body">
    <div class="login-container">
        <div class="login-card">
            <img src="assets/logo.png" alt="Logo" class="login-logo">
            <h2>Administrator Sign Up</h2>
            
            <?php if (!empty($errors)): ?>
                <div class="error">
                    <?php foreach ($errors as $error): ?>
                        <p><?php echo htmlspecialchars($error); ?></p>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>

            <?php if ($success): ?>
                <div class="success-message">
                    <p>Registration successful! You can now <a href="login.php" style="color:#00e6ff;">log in</a>.</p>
                </div>
            <?php endif; ?>

            <form class="login-form" method="POST" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>">
                <div class="form-group">
                    <label for="fullname">Full Name</label>
                    <input type="text" id="fullname" name="fullname" value="<?php echo isset($_POST['fullname']) ? htmlspecialchars($_POST['fullname']) : ''; ?>" required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" value="<?php echo isset($_POST['email']) ? htmlspecialchars($_POST['email']) : ''; ?>" required>
                </div>

                <div class="form-group">
                    <label for="contact">Contact Number</label>
                    <input type="tel" id="contact" name="contact" value="<?php echo isset($_POST['contact']) ? htmlspecialchars($_POST['contact']) : ''; ?>" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                    <div class="password-rules">
                        <ul>
                            <li>At least 8 characters long</li>
                            <li>Include at least one uppercase letter</li>
                            <li>Include at least one lowercase letter</li>
                            <li>Include at least one number</li>
                            <li>Include at least one special character</li>
                        </ul>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirm_password">Confirm Password</label>
                    <input type="password" id="confirm_password" name="confirm_password" required>
                </div>

                <button type="submit" class="login-btn">Sign Up</button>
            </form>
            <p style="margin-top: 20px; color: #b8c6db;">Already have an account? <a href="login.php" style="color: #00e6ff; text-decoration: none;">Login here</a></p>
        </div>
    </div>

    <script>
        // Real-time password validation
        document.getElementById('password').addEventListener('input', function() {
            const password = this.value;
            const rules = {
                length: password.length >= 8,
                uppercase: /[A-Z]/.test(password),
                lowercase: /[a-z]/.test(password),
                number: /[0-9]/.test(password),
                special: /[!@#$%^&*()\-_=+{};:,<.>]/.test(password)
            };

            const ruleElements = document.querySelectorAll('.password-rules li');
            ruleElements.forEach((element, index) => {
                const rule = Object.values(rules)[index];
                element.style.color = rule ? '#00e6ff' : '#b8c6db';
            });
        });

        // Confirm password validation
        document.getElementById('confirm_password').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            this.style.borderColor = password === confirmPassword ? '#00e6ff' : '#ff4f4f';
        });
    </script>
</body>
</html> 
