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

  $login = $_POST['login'];
  $password = $_POST['password'];

  $query = "SELECT * FROM users WHERE (email = ? OR nickname = ?) AND password = ?";
  $stmt = $conn->prepare($query);
  $stmt->execute([$login, $login, $password]);

  $user = $stmt->fetch(PDO::FETCH_ASSOC);

  if ($user) {
    echo json_encode([
      "success" => true,
      "nickname" => $user['nickname']
    ]);
  } else {
    echo json_encode(["success" => false, "message" => "Credenziali errate"]);
  }

} catch (PDOException $e) {
  echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>