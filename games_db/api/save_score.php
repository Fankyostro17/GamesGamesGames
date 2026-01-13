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

  $nickname = $_POST['nickname'];
  $game = $_POST['game'];
  $difficulty = $_POST['difficulty'];
  $time = $_POST['time'];

  $query = "SELECT id FROM users WHERE nickname = ?";
  $stmt = $conn->prepare($query);
  $stmt->execute([$nickname]);
  $user = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$user) {
    echo json_encode(["success" => false, "message" => "Utente non trovato"]);
    exit;
  }

  $userId = $user['id'];

  $query = "INSERT INTO scores (userId, game, difficulty, time) VALUES (?, ?, ?, ?)";
  $stmt = $conn->prepare($query);

  if ($stmt->execute([$userId, $game, $difficulty, $time])) {
    echo json_encode(["success" => true]);
  } else {
    echo json_encode(["success" => false, "message" => "Errore salvataggio punteggio"]);
  }

} catch (PDOException $e) {
  echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>