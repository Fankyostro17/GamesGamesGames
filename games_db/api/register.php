<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  exit(0);
}

$hostname = "localhost";
$dbname = "games_db";
$user = "root";
$pass = "";

try {
  $conn = new PDO("mysql:host=$hostname;dbname=$dbname", $user, $pass);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Richiesta non valida']);
    exit;
  }

  $email = $_POST['email'] ?? '';
  $nickname = $_POST['nickname'] ?? '';
  $password = $_POST['password'] ?? '';
  $birthdate = $_POST['birthdate'] ?? '';

  if (empty($email) || empty($nickname) || empty($password) || empty($birthdate)) {
    echo json_encode(['success' => false, 'message' => 'Dati incompleti']);
    exit;
  }

  // Controlla se email o nickname esistono già
  $checkQuery = "SELECT COUNT(*) FROM users WHERE email = ? OR nickname = ?";
  $checkStmt = $conn->prepare($checkQuery);
  $checkStmt->execute([$email, $nickname]);

  if ($checkStmt->fetchColumn() > 0) {
    echo json_encode(["success" => false, "message" => "Email o nickname già esistenti"]);
    exit;
  }

  $query = "INSERT INTO users (email, nickname, password, birthdate) VALUES (?, ?, ?, ?)";
  $stmt = $conn->prepare($query);

  if ($stmt->execute([$email, $nickname, $password, $birthdate])) {
    echo json_encode(["success" => true]);
  } else {
    echo json_encode(["success" => false, "message" => "Errore registrazione"]);
  }

} catch (PDOException $e) {
  echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>