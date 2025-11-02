<?php
// Copy this file to config/smtp.php and fill in your SMTP credentials.
// Keep config/smtp.php out of version control (add to .gitignore).
return [
    // SMTP host, e.g. smtp.gmail.com or smtp.office365.com
    'host' => 'smtp.example.com',

    // SMTP username (email address usually)
    'username' => 'your_smtp_username@example.com',

    // SMTP password (use app password where required)
    'password' => 'your_smtp_password',

    // SMTP port: 587 for STARTTLS, 465 for SSL
    'port' => 587,

    // Encryption: use PHPMailer::ENCRYPTION_STARTTLS or PHPMailer::ENCRYPTION_SMTPS
    'encryption' => \PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS,

    // From email and name used when sending verification emails
    'from_email' => 'no-reply@yourdomain.com',
    'from_name' => 'Telemedicine Admin',
];
