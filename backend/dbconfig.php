<?php
$servername = "localhost";
$username = "username";
$password = "pass";
$dbname = "dbname";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>