<?php
header("Content-Type: application/json");
require_once("dbconfig.php"); // Make sure this file connects to your DB

$response = array();

if (
    isset($_POST['user_name']) &&
    isset($_POST['user_email']) &&
    isset($_POST['user_password']) &&
    isset($_POST['pet_name'])
) {
    $user_name = $_POST['user_name'];
    $user_email = $_POST['user_email'];
    $user_password = $_POST['user_password'];
    $pet_name = $_POST['pet_name'];

    // Check if email already exists
    $check = $conn->prepare("SELECT * FROM user WHERE user_email = ?");
    $check->bind_param("s", $user_email);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {
        $response['success'] = false;
        $response['message'] = "Email already registered!";
    } else {
        $stmt = $conn->prepare("INSERT INTO user (user_name, user_email, user_password, pet_name) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $user_name, $user_email, $user_password, $pet_name);

        if ($stmt->execute()) {
            $response['success'] = true;
            $response['message'] = "User registered successfully!";
        } else {
            $response['success'] = false;
            $response['message'] = "Registration failed!";
        }
        $stmt->close();
    }
    $check->close();
} else {
    $response['success'] = false;
    $response['message'] = "Missing required fields!";
}

echo json_encode($response);
$conn->close();
?>