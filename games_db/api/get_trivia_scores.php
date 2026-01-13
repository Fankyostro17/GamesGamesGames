<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
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

  $query = "
    SELECT u.nickname, t.difficulty, t.category, t.time, t.correct_answers, t.total_questions, t.timestamp
    FROM (
      SELECT *,
             ROW_NUMBER() OVER (
               ORDER BY
                 time ASC,
                 (correct_answers / total_questions) DESC,
                 CASE difficulty
                   WHEN 'hard' THEN 1
                   WHEN 'medium' THEN 2
                   WHEN 'easy' THEN 3
                 END ASC
             ) AS rn
      FROM TriviaScore
    ) t
    JOIN users u ON t.userId = u.id
    WHERE t.rn <= 20
    ORDER BY
      t.time ASC,
      (t.correct_answers / t.total_questions) DESC,
      CASE t.difficulty
        WHEN 'hard' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'easy' THEN 3
      END ASC
  ";

  $stmt = $conn->prepare($query);
  $stmt->execute();
  $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

  echo json_encode(['success' => true, 'scores' => $results]);

} catch (PDOException $e) {
  echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>