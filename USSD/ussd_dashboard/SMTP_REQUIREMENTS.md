SMTP Delivery Requirements and Setup

This document explains how to configure proper SMTP delivery for the Telemedicine USSD dashboard. Use these steps for development or production environments.

1) Recommendation

- Use a proper SMTP library such as PHPMailer (recommended) or SwiftMailer.
- PHPMailer gives reliable SMTP with authentication, TLS/SSL and better error messages than PHP mail().
- Do NOT rely on the default mail() function for production on Windows/XAMPP.

2) Quick checklist (high level)

- PHP has the openssl extension enabled (required for TLS/SSL): uncomment `extension=openssl` in php.ini.
- Composer is available for installing PHPMailer (recommended): https://getcomposer.org
- SMTP provider credentials (host, port, username, password).
- Firewall allows outbound connections on SMTP port (587 or 465 as required).
- Store SMTP credentials out of the repository (environment variables, outside-webroot config file).

3) Install PHPMailer (recommended)

From your project root (where composer.json lives), run:

```bash
composer require phpmailer/phpmailer
```

This creates `vendor/` and autoloaders. Your code can then use PHPMailer via Composer's autoload.

4) PHP configuration notes (XAMPP/Windows)

- Enable OpenSSL in `php.ini` (important for TLS):
  - Open `php.ini` (for XAMPP typically `C:\xampp\php\php.ini`).
  - Make sure the line `extension=openssl` is present and not commented.
  - Restart Apache.

- XAMPP includes a sendmail utility (sendmail.exe) you can configure to forward mail through an SMTP server. This is more of a fallback; PHPMailer is preferred.
  - Configure `sendmail\sendmail.ini`:
    - smtp_server=smtp.example.com
    - smtp_port=587
    - auth_username=your@domain.com
    - auth_password=your_app_password
    - force_ssl=auto
  - Then in php.ini set: `sendmail_path = "C:\\xampp\\sendmail\\sendmail.exe -t"` (Windows)
  - Restart Apache.

5) Gmail specifics (if you plan to use Gmail / Google Workspace)

- Gmail requires either:
  - Use an App Password (recommended) — enable 2-Step Verification for the account and create an App Password, then use that as SMTP password.
  - Or use a domain provider's SMTP relay / transactional provider.
- Gmail SMTP settings:
  - Host: `smtp.gmail.com`
  - Port: 587 (TLS) or 465 (SSL)
  - Encryption: TLS (STARTTLS) on 587 or SSL on 465
  - Authentication: yes (username/password or app password)
- Note: Google no longer supports enabling "less secure apps" for regular passwords — use an app password.

6) Office365 / Outlook

- Host: `smtp.office365.com`
- Port: 587
- Encryption: STARTTLS (TLS)
- Use credentials for a service/service account with SMTP AUTH enabled.

7) Example: PHPMailer usage (recommended approach)

Create a small SMTP config file outside webroot or use environment variables. Example snippet to send email (adapt to your signup flow):

```php
// require Composer autoload at top of script
require __DIR__ . '/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function sendVerificationMail($toEmail, $toName, $verifyLink) {
    $mail = new PHPMailer(true);
    try {
        // SMTP configuration - put these in env or external config
        $mail->isSMTP();
        $mail->Host = getenv('SMTP_HOST') ?: 'smtp.example.com';
        $mail->SMTPAuth = true;
        $mail->Username = getenv('SMTP_USER') ?: 'username@example.com';
        $mail->Password = getenv('SMTP_PASS') ?: 'super_secret_password';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS; // or PHPMailer::ENCRYPTION_SMTPS for SSL
        $mail->Port = getenv('SMTP_PORT') ?: 587;

        $mail->setFrom('no-reply@yourdomain.com', 'Telemedicine Admin');
        $mail->addAddress($toEmail, $toName);

        $mail->isHTML(false);
        $mail->Subject = 'Verify your Telemedicine Admin account';
        $mail->Body    = "Hi $toName\n\nPlease verify your account by visiting: $verifyLink\n\nThank you.";

        $mail->send();
        return true;
    } catch (Exception $e) {
        error_log('Mail error: ' . $mail->ErrorInfo);
        return false;
    }
}
```

Usage:
```php
$ok = sendVerificationMail($email, $fullname, $verifyLink);
if ($ok) { /* proceed */ } else { /* fallback */ }
```

8) How to store credentials safely

- Preferred: use environment variables (set in Apache virtual host, Docker, or system env) and read via `getenv('SMTP_PASS')`.
- Less ideal: a PHP config file outside webroot (e.g., `/var/www/private_config.php`) with restrictive filesystem permissions (600).
- Never commit credentials to git.

9) Testing connectivity & troubleshooting

- Check OpenSSL enabled in phpinfo(); if not, enable `extension=openssl` in php.ini and restart Apache.
- From Windows PowerShell test SMTP TCP connectivity:

```powershell
Test-NetConnection -ComputerName smtp.gmail.com -Port 587
```

- Or use telnet (if enabled) or openssl (on Linux/mac):

```bash
openssl s_client -starttls smtp -connect smtp.gmail.com:587 -crlf
```

- Check firewall rules blocking outbound 587/465.
- Check mail error logs and PHPMailer errorInfo when using PHPMailer.

10) Common causes of mail failures on XAMPP/Windows

- `mail()` issues due to no local SMTP server or sendmail not configured.
- `openssl` extension not enabled — TLS fails.
- Wrong SMTP host/port/encryption combination.
- Credentials incorrect or service blocking login (Gmail requiring app password).

11) Example minimal SMTP settings for common providers

- Gmail (with app password):
  - Host: smtp.gmail.com
  - Port: 587
  - TLS/STARTTLS
  - Username: your@gmail.com
  - Password: app password (16-char)

- Office365:
  - Host: smtp.office365.com
  - Port: 587
  - TLS

- SendGrid (API or SMTP): use SendGrid SMTP credentials and host `smtp.sendgrid.net`, port 587.

12) Next steps I can help with

- Add PHPMailer to the project and replace `mail()` usage in `signup.php` with the example above.
- Add an environment-based config (`config/smtp.php`) that reads env vars and returns config.
- Walk you through configuring XAMPP sendmail or obtaining a SendGrid/Gmail SMTP account for sending.

If you want, I can now:
- Implement PHPMailer in `signup.php` and a `config/smtp.example.php` (non-credential version), or
- Walk you through manual XAMPP/sendmail setup step-by-step on your Windows machine.

Which would you prefer?