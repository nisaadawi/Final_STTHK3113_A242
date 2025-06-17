<?php
include "dbconfig.php"; 

$pet_status = $_GET['pet_status'];
$led_status = $_GET['led_status'];

$sql = "INSERT INTO pet_log (pet_status, led_status) VALUES ('$pet_status', '$led_status')";
mysqli_query($conn, $sql);

echo json_encode(["status" => "success", "message" => "Pet log recorded"]);
?>
