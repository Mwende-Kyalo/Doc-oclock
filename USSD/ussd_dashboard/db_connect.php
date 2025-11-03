<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "telemedicine_ussd";

try {
    $conn = new mysqli($host, $user, $pass);
    
    // Create database if it doesn't exist
    if (!$conn->select_db($db)) {
        $sql = "CREATE DATABASE IF NOT EXISTS $db";
        $conn->query($sql);
        $conn->select_db($db);
    }

    // Set charset to ensure proper character handling
    $conn->set_charset("utf8mb4");

    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }
} catch (Exception $e) {
    die("Database connection failed: " . $e->getMessage());
}
?>
