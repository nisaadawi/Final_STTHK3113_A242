<?php
header("Content-Type: application/json");
require_once("dbconfig.php"); // Your DB connection file

$response = array();

if (isset($_POST['user_email']) && isset($_POST['user_password'])) {
    $user_email = $_POST['user_email'];
    $user_password = $_POST['user_password'];

    // Use prepared statements to prevent SQL injection
    $stmt = $conn->prepare("SELECT * FROM user WHERE user_email = ? AND user_password = ?");
    $stmt->bind_param("ss", $user_email, $user_password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        $response['success'] = true;
        $response['user'] = $row;
    } else {
        $response['success'] = false;
        $response['message'] = "Invalid email or password!";
    }
    $stmt->close();
} else {
    $response['success'] = false;
    $response['message'] = "Missing required fields!";
}

echo json_encode($response);
$conn->close();
?>