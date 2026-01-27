import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';

class TriviaDifficulty extends StatefulWidget {
  const TriviaDifficulty({super.key, required this.title});

  final String title;

  @override
  State<TriviaDifficulty> createState() => _TriviaGames();
}

class _TriviaGames extends State<TriviaDifficulty>{
  String? _selectedDifficulty;

  void _selectCategory(String difficulty) {
    setState(() {
      _selectedDifficulty = _selectedDifficulty == difficulty ? null : difficulty;
    });

    if (_selectedDifficulty != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TriviaCategorySelection(difficulty: difficulty),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF8E44AD),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final difficulties = [
                          {'label': 'Facile', 'value': 'easy', 'icon': Icons.sentiment_satisfied_alt_outlined},
                          {'label': 'Medio', 'value': 'medium', 'icon': Icons.tag_faces_outlined},
                          {'label': 'Difficile', 'value': 'hard', 'icon': Icons.mood_bad_outlined},
                        ];
                        final item = difficulties[index];
                        bool isSelected = _selectedDifficulty == item['value'];

                        return _buildDifficultyCard(
                          label: item['label']!  as String,
                          icon: item['icon']  as IconData,
                          isSelected: isSelected,
                          onTap: () => _selectCategory(item['value']! as String),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TriviaLeaderboard(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8E44AD),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Vedi Classifica',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Color(0xFF8E44AD) : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Color(0xFF8E44AD) : Color(0xFF9B59B6),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriviaCategorySelection extends StatefulWidget {
  final String difficulty;

  const TriviaCategorySelection({super.key, required this.difficulty});

  @override
  State<TriviaCategorySelection> createState() => _TriviaCategorySelectionState();
}

class _TriviaCategorySelectionState extends State<TriviaCategorySelection> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scegli Categoria",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF27AE60),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF6F6), Color(0xFFD4ECD6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final categories = [
                          {'name': 'Geografia', 'icon': Icons.location_on_outlined},
                          {'name': 'Scienza', 'icon': Icons.science_outlined},
                          {'name': 'Storia', 'icon': Icons.history_edu_outlined},
                          {'name': 'Arte', 'icon': Icons.palette_outlined},
                          {'name': 'Generale', 'icon': Icons.school_outlined},
                        ];
                        final item = categories[index];
                        bool isSelected = _selectedCategory == item['name'];

                        return _buildCategoryCard(
                          name: item['name']! as String,
                          icon: item['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == item['name'] ? null : item['name'] as String;
                            });

                            if (_selectedCategory != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TriviaGame(difficulty: widget.difficulty, category: item['name']! as String),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Color(0xFF27AE60) : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Color(0xFF27AE60) : Color(0xFF27AE60),
            ),
            SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriviaGame extends StatefulWidget {
  final String difficulty;
  final String category;
  const TriviaGame({super.key, required this.difficulty, required this.category});

  @override
  State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  TriviaQuestion? question;
  bool loading = true;
  bool answered = false;
  int? selectedAnswer;
  int startTime = 0;
  int endTime = 0;
  int correctAnswers = 0;
  int totalQuestions = 0;
  bool gameEnded = false;

  List<String> askedQuestions = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().millisecondsSinceEpoch;
    loadRandomQuestion();
  }

  Future<void> loadRandomQuestion() async {
    setState(() {
      loading = true;
    });
    
    try{
      final q = await TriviaRepository.loadRandomQuestionByDifficultyAndCategory(widget.difficulty, widget.category, askedQuestions);
      setState(() {
        question = q;
        loading = false;
        answered = false;
        selectedAnswer = null;
        totalQuestions++;
        askedQuestions.add(q.question);
      });
    } catch (e) {
      print("Errore nel caricamento della domanda: $e");
      setState(() {
        loading = false;
      });
    }
  }

  void checkAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    if (index == question!.correctIndex) {
      correctAnswers++;
    }

    Future.delayed(Duration(seconds: 1), () {
      if (totalQuestions == 10) {
        endGame();
      } else {
        loadRandomQuestion();
      }
    });
  }

  void endGame() {
    setState(() {
      gameEnded = true;
      endTime = DateTime.now().millisecondsSinceEpoch;
    });

    int totalTime = (endTime - startTime) ~/ 1000;

    String? loggedUser = ModalRoute.of(context)?.settings.arguments as String?;
    if (loggedUser != null) {
      print("DEBUG: Utente loggato: $loggedUser");
      ApiClient.saveTriviaScore(
        nickname: loggedUser,
        difficulty: widget.difficulty,
        category: widget.category,
        time: totalTime,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
      ).then((success) {
        print("DEBUG: Salvataggio punteggio ${success ? 'riuscito' : 'fallito'}");
      });
    } else {
      print("DEBUG: Nessun utente loggato, non salvo il punteggio");
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Partita Terminata!"),
        content: Text(
          "Hai risposto a $totalQuestions domande.\n"
          "Ne hai azzeccate $correctAnswers.\n"
          "Tempo totale: ${totalTime}s.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Trivia - ${widget.difficulty}")),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 80,
                  color: Color(0xFFFF9800),
                ),
                SizedBox(height: 20),
                Text(
                  "Sto pensando a una domanda...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Attendi un momento!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Trivia - ${widget.difficulty}")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Domanda $totalQuestions/10",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            SizedBox(height: 8),
            Text(
              question!.question,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),
            for (int i = 0; i < question!.answers.length; i++)
              Card(
                color: answered
                    ? (i == question!.correctIndex
                        ? Colors.green.shade300
                        : (i == selectedAnswer ? Colors.red.shade300 : null))
                    : null,
                child: ListTile(
                  title: Text(question!.answers[i]),
                  onTap: answered ? null : () => checkAnswer(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TriviaLeaderboard extends StatefulWidget {
  const TriviaLeaderboard({super.key});

  @override
  State<TriviaLeaderboard> createState() => _TriviaLeaderboardState();
}

class _TriviaLeaderboardState extends State<TriviaLeaderboard> {
  List<dynamic> scores = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    try {
      final response = await http.get(Uri.parse('${ApiClient.baseUrl}/get_trivia_scores.php'));
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          scores = data['scores'];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = data['message'] ?? 'Errore sconosciuto';
        });
      }
    } catch (e) {
      print("Errore caricamento classifica: $e");
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Classifica Trivia", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF8E44AD),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)],
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Classifica Trivia", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF8E44AD),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  "Errore: ${errorMessage!}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loadScores,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8E44AD),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Riprova"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Classifica Trivia", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8E44AD),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)],
          ),
        ),
        child: scores.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 80, color: Color(0xFF8E44AD)),
                    SizedBox(height: 20),
                    Text(
                      "Ancora nessun punteggio!",
                      style: TextStyle(fontSize: 18, color: Color(0xFF2C3E50)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: scores.length,
                itemBuilder: (context, index) {
                  final score = scores[index];
                  bool isTop3 = index < 3;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isTop3 ? Color(0xFFFFD700) : Colors.transparent,
                        width: isTop3 ? 2 : 0,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isTop3 ? Color(0xFFFFD700) : Color(0xFF8E44AD),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "#${index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            score['nickname'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          if (isTop3)
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        "${score['difficulty']} • ${score['category']} • ${score['time']}s",
                        style: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${score['correct_answers']}/${score['total_questions']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                          Text(
                            "Giuste",
                            style: TextStyle(fontSize: 10, color: Color(0xFF7F8C8D)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class TriviaQuestion {
  final int id;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String difficulty;
  final String category;

  TriviaQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.difficulty,
    required this.category,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      id: json['id'],
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctIndex: json['correctIndex'],
      difficulty: json['difficulty'],
      category: json['category'],
    );
  }
}

class TriviaRepository {
  static const baseUrl = "http://127.0.0.1:9000";

  static Future<TriviaQuestion> loadRandomQuestionByDifficultyAndCategory(String difficulty, String category, List<String> excludeQuestions) async {
    String excluded = excludeQuestions.join(';');
    final url = Uri.parse('$baseUrl/trivia/generate?difficulty=$difficulty&topic=$category&exclude=$excluded');
    final response = await http.get(url);

    print("Risposta dal server: ${response.body}");

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      
      if (data.containsKey('error')){
        throw Exception('Errore dal server: ${data['error']}');
      }

      int? correctIndex = data['correctIndex'];
      if (correctIndex == null || correctIndex < 0 || correctIndex >= (data['answers'] as List).length) {
        throw Exception('Risposta del server mancante dell\'indice della risposta corretta');
      }

      return TriviaQuestion(
        id: -1,
        question: data['question'],
        answers: List<String>.from(data['answers']),
        correctIndex: correctIndex,
        difficulty: difficulty,
        category: data['category'] ?? category,
      );
    } else {
      throw Exception('Errore HTTP: ${response.statusCode} - ${response.body}');
    }
  }
}