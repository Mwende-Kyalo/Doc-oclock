<?php
include 'db_connect.php';

$period = $_GET['period'] ?? 'day';
$data = [];

if ($period == 'day') {
    $query = "SELECT DATE(created_at) as label, COUNT(*) as total FROM appointments 
              WHERE DATE(created_at) = CURDATE() GROUP BY label";
} elseif ($period == 'month') {
    $query = "SELECT DATE(created_at) as label, COUNT(*) as total FROM appointments 
              WHERE MONTH(created_at) = MONTH(CURDATE()) GROUP BY label";
} else {
    $query = "SELECT MONTH(created_at) as label, COUNT(*) as total FROM appointments 
              WHERE YEAR(created_at) = YEAR(CURDATE()) GROUP BY label";
}

$result = $conn->query($query);
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
