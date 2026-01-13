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
  $difficulty = $_POST['difficulty'];
  $category = $_POST['category'];
  $time = $_POST['time'];
  $correctAnswers = $_POST['correctAnswers'];
  $totalQuestions = $_POST['totalQuestions'];

  $query = "SELECT id FROM users WHERE nickname = ?";
  $stmt = $conn->prepare($query);
  $stmt->execute([$nickname]);
  $user = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$user) {
    echo json_encode(["success" => false, "message" => "Utente non trovato"]);
    exit;
  }

  $userId = $user['id'];

  $query = "INSERT INTO TriviaScore (userId, difficulty, category, time, correct_answers, total_questions) VALUES (?, ?, ?, ?, ?, ?)";
  $stmt = $conn->prepare($query);

  if ($stmt->execute([$userId, $difficulty, $category, $time, $correctAnswers, $totalQuestions])) {
    echo json_encode(["success" => true]);
  } else {
    echo json_encode(["success" => false, "message" => "Errore salvataggio punteggio"]);
  }

} catch (PDOException $e) {
  echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>