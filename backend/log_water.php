<?php
include "dbconfig.php"; 

$water_level = $_GET['water_level'];
$water_percentage = $_GET['water_percentage'];
$water_status = $_GET['water_status'];

$sql = "INSERT INTO water_log (water_level, water_percentage, water_status) VALUES ('$water_level', '$water_percentage', '$water_status')";
mysqli_query($conn, $sql);

echo json_encode(["status" => "success", "message" => "Water status recorded"]);
?>
