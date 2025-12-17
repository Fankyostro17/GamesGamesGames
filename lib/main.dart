import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'CustomIconsSuperTris.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games!!',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const SetGames(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SetGames extends StatefulWidget {
  const SetGames({super.key});

  @override
  State<SetGames> createState() => _SetGamesState();
}

class _SetGamesState extends State<SetGames> {
  bool _triviaSelected = false;
  bool _superTrisSelected = false;
  bool _kakuroSelected = false;

  void _resetSelections(){
    setState(() {
      _triviaSelected = false;
      _superTrisSelected = false;
      _kakuroSelected = false;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Seleziona il gioco con cui vuoi giocare')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImageButton(
                      width: double.infinity,
                      height: 80,
                      pressedImage: Image.asset('assets/images/button_pressed.png'),
                      unpressedImage: Image.asset('assets/images/button_unpressed.png'),
                      onTap: () {
                        _resetSelections();
                        setState(() {
                          _triviaSelected = true;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("Trivia", style: TextStyle(color: Colors.black, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImageButton(
                      width: double.infinity,
                      height: 80,
                      pressedImage: Image.asset("assets/pressed.png"),
                      unpressedImage: Image.asset("assets/unpressed.png"),
                      onTap: () {
                        _resetSelections();
                        setState(() {
                          _superTrisSelected = true;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_on, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("Super Tris", style: TextStyle(color: Colors.black, fontSize: 18))
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImageButton(
                      width: double.infinity,
                      height: 80,
                      pressedImage: Image.asset("assets/pressed.png"),
                      unpressedImage: Image.asset("assets/unpressed.png"),
                      onTap: () {
                        _resetSelections();
                        setState(() {
                          _kakuroSelected = true;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("Kakuro", style: TextStyle(color: Colors.black, fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                      _triviaSelected ? 
                        TriviaDifficulty(
                          title: "Trivia Difficulty"
                        )
                      : _superTrisSelected ?
                        SuperTris(
                          title: "Super Tris"
                        )
                      : _kakuroSelected ?
                        KakuroDifficulty(
                          title: "Kakuro Difficulty",
                        )
                      : AlertDialog(
                          title: const Text("Gioco Non Selezionato"),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Per favore seleziona un gioco prima di premere il bottone 'Inizia il gioco'"),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: const Text("Chiudi"),
                            ),
                          ],
                        ),
                  ),
                );
              },
              child: const Text('Inizia il gioco'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageButton extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final Image pressedImage;
  final Image unpressedImage;
  final VoidCallback? onTap;

  const ImageButton({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    required this.pressedImage,
    required this.unpressedImage,
    this.onTap,
  }) : super(key: key);

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPressed = !_isPressed;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _isPressed
                ? widget.pressedImage.image
                : widget.unpressedImage.image,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class KakuroPuzzle extends StatefulWidget {
  const KakuroPuzzle({super.key, required this.title, required this.size});
  
  final String title;
  final int size;

  @override
  State<KakuroPuzzle> createState() => _Kakuro();
}

class KakuroDifficulty extends StatelessWidget {
  final String title;
  const KakuroDifficulty({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => KakuroPuzzle(size: 5, title: "Kakuro 5x5"),
                ));
              },
              child: Text("5 x 5"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => KakuroPuzzle(size: 7, title: "Kakuro 7x7"),
                ));
              },
              child: Text("7 x 7"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kakuro extends State<KakuroPuzzle> {
  late List<List<KakuroCell>> grid;
  int selectedRow = -1;
  int selectedCol = -1;

  @override
  void initState() {
    super.initState();
    grid = generatePuzzle(widget.size);
  }

  void _onCellTap(int row, int col) {
    if (!grid[row][col].isClue) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _onNumberPressed(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        grid[selectedRow][selectedCol].value = grid[selectedRow][selectedCol].value == number ? null : number;
      });
    }
  }

  void _clearCell() {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        grid[selectedRow][selectedCol].value = null;
      });
    }
  }

  
  Widget _buildClueCell(KakuroCell cell) {
    return CustomPaint(
      painter: KakuroCluePainter(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            // Riga superiore: numero verticale in alto a destra (se presente)
            Row(
              children: [
                Spacer(),
                if (cell.verticalClue != null)
                  Text(
                    cell.verticalClue.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
              ],
            ),
            Spacer(),
            // Riga inferiore: numero orizzontale in basso a sinistra (se presente)
            Row(
              children: [
                if (cell.horizontalClue != null)
                  Text(
                    cell.horizontalClue.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInputCell(KakuroCell cell) {
    return Center(
      child: Text(
        cell.value?.toString() ?? "",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey.shade300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (index) {
          int number = index + 1;
          return ElevatedButton(
            onPressed: () => _onNumberPressed(number),
            child: Text("$number"),
          );
        }),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double cellSize = constraints.maxWidth / widget.size;

                return Center(
                  child: SizedBox(
                    width: cellSize * widget.size,
                    height: cellSize * widget.size,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.size,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: widget.size * widget.size,
                      itemBuilder: (context, index) {
                        int row = index ~/ widget.size;
                        int col = index % widget.size;
                        KakuroCell cell = grid[row][col];

                        return GestureDetector(
                          onTap: () => _onCellTap(row, col),
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: cell.isClue ? Colors.black : Colors.white,
                              border: Border.all(color: Colors.grey, width: 0.6),
                            ),
                            child: cell.isClue
                              ? _buildClueCell(cell)
                              : _buildInputCell(cell),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          _buildKeypad(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearCell,
        child: Icon(Icons.clear),
      ),
    );
  }
}

class KakuroCluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // sfondo nero (già impostato dal Container) -> qui disegniamo solo la diagonale bianca
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // linea diagonale dal basso sinistra all'alto destra
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class KakuroCell {
  final bool isClue;
  final int? horizontalClue;
  final int? verticalClue;
  int? value;

  KakuroCell({
    this.isClue = false,
    this.horizontalClue,
    this.verticalClue,
    this.value,
  });
}

List<List<KakuroCell>> generatePuzzle(int size) {
  if (size == 5) {
    return [
      [KakuroCell(), KakuroCell(), KakuroCell(), KakuroCell(), KakuroCell()],
      [
        KakuroCell(),
        KakuroCell(isClue: true, horizontalClue: 16, verticalClue: 10),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
      ],
      [
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(isClue: true, horizontalClue: 9),
        KakuroCell(),
      ],
      [
        KakuroCell(isClue: true, verticalClue: 16),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
      ],
      [
        KakuroCell(isClue: true, verticalClue: 10),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
        KakuroCell(),
      ],
    ];
  } else {
    return List.generate(size, (i) => List.generate(size, (j) => KakuroCell()));
  }
}

class TriviaDifficulty extends StatefulWidget {
  const TriviaDifficulty({super.key, required this.title});

  final String title;

  @override
  State<TriviaDifficulty> createState() => _TriviaGames();
}

class _TriviaGames extends State<TriviaDifficulty>{
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>
                    TriviaGame(difficulty: "easy")));
              },
              child: Text("Facile"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>
                    TriviaGame(difficulty: "medium")));
              },
              child: Text("Medio"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>
                    TriviaGame(difficulty: "hard")));
              },
              child: Text("Difficile"),
            ),
          ],
        ),
      ),
    );
  }
}


class TriviaGame extends StatefulWidget {
  final String difficulty;
  const TriviaGame({super.key, required this.difficulty});

  @override
  State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  TriviaQuestion? question;
  bool loading = true;
  bool answered = false;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadRandomQuestion();
  }

  Future<void> loadRandomQuestion() async {
    final filtered = await TriviaRepository.loadByDifficulty(widget.difficulty);
    
    filtered.shuffle();
    setState(() {
      question = filtered.first;
      loading = false;
    });
  }

  void checkAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(index == question!.correctIndex
              ? "✔ Corretto!"
              : "✘ Sbagliato"),
          content: Text(
            "Risposta esatta: ${question!.answers[question!.correctIndex]}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // ritorna alla selezione difficoltà
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Trivia - ${widget.difficulty}")),
        body: Center(child: CircularProgressIndicator()),
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
  static List<TriviaQuestion> _cache = [];

  static Future<List<TriviaQuestion>> loadAllQuestions() async {
    if (_cache.isNotEmpty) return _cache;

    // Flutter genera automaticamente una lista di tutti gli asset
    final manifest =
        await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifest);

    // Filtra tutti i file nella cartella trivia/
    final quizFiles = manifestMap.keys
        .where((path) => path.startsWith("assets/data/trivia/"))
        .where((path) => path.endsWith(".json"))
        .toList();

    List<TriviaQuestion> allQuestions = [];

    for (String file in quizFiles) {
      final jsonString = await rootBundle.loadString(file);
      final data = json.decode(jsonString);

      final list = (data['questions'] as List)
          .map((q) => TriviaQuestion.fromJson(q))
          .toList();

      allQuestions.addAll(list);
    }

    _cache = allQuestions;
    return _cache;
  }

  static Future<List<TriviaQuestion>> loadByDifficulty(String difficulty) async {
    final all = await loadAllQuestions();
    return all.where((q) => q.difficulty == difficulty).toList();
  }
}

class SuperTris extends StatefulWidget {
  const SuperTris({super.key, required this.title});

  final String title;

  @override
  State<SuperTris> createState() => _SuperTrisState();
}

class _SuperTrisState extends State<SuperTris> {

  List<List<List<String>>> board = List.generate(
    3,
    (_) => List.generate(3, (_) => List.filled(9, "")),
  );

  List<List<String>> bigBoard = List.generate(
    3,
    (_) => List.filled(3, ""),
  );

  String currentPlayer = "X";
  int? forcedBoard; // da 0 a 8

  void playCell(int bigIndex, int cellIndex) {
    if (forcedBoard != null && forcedBoard != bigIndex) return;

    if (board[bigIndex ~/ 3][bigIndex % 3][cellIndex] != "") return;

    setState(() {
      board[bigIndex ~/ 3][bigIndex % 3][cellIndex] = currentPlayer;

      forcedBoard = cellIndex;

      if (isBoardFull(forcedBoard!)) forcedBoard = null;

      currentPlayer = currentPlayer == "X" ? "O" : "X";
    });

    String vincitore = "";
    List<dynamic> out = isFinish();
    if(out[2] != ""){
      bigBoard[out[0]][out[1]] = out[2];
      /* impostare la grafica della X o O gigante */
      vincitore = isFinishBigBoard();
      if(vincitore != ""){
        /* caso di vittoria */
      }
    }
  }

  String isFinishBigBoard(){
    if(bigBoard[0][0] == bigBoard[0][1] &&
      bigBoard[0][0] == bigBoard[0][2] &&
      (bigBoard[0][0] != "" &&
      bigBoard[0][1] != "" &&
      bigBoard[0][2] != "")){
      return bigBoard[0][0];
    }
    if(bigBoard[1][0] == bigBoard[1][1] &&
      bigBoard[1][0] == bigBoard[1][2] &&
      (bigBoard[1][0] != "" &&
      bigBoard[1][1] != "" &&
      bigBoard[1][2] != "")){
      return bigBoard[1][0];
    }
    if(bigBoard[2][0] == bigBoard[2][1] &&
      bigBoard[2][0] == bigBoard[2][2] &&
      (bigBoard[2][0] != "" &&
      bigBoard[2][1] != "" &&
      bigBoard[2][2] != "")){
      return bigBoard[2][0];
    }
    if(bigBoard[0][0] == bigBoard[1][0] &&
      bigBoard[0][0] == bigBoard[2][0] &&
      (bigBoard[0][0] != "" && 
      bigBoard[1][0] != "" &&
      bigBoard[2][0] != "")){
      return bigBoard[0][0];
    }
    if(bigBoard[0][1] == bigBoard[1][1] &&
      bigBoard[0][1] == bigBoard[2][1] &&
      (bigBoard[0][1] != "" && 
      bigBoard[1][1] != "" &&
      bigBoard[2][1] != "")){
      return bigBoard[0][1];
    }
    if(bigBoard[0][2] == bigBoard[1][2] &&
      bigBoard[0][2] == bigBoard[2][2] &&
      (bigBoard[0][2] != "" && 
      bigBoard[1][2] != "" &&
      bigBoard[2][2] != "")){
      return bigBoard[0][2];
    }
    if(bigBoard[0][0] == bigBoard[1][1] &&
      bigBoard[0][0] == bigBoard[2][2] &&
      (bigBoard[0][0] != "" && 
      bigBoard[1][1] != "" &&
      bigBoard[2][2] != "")){
      return bigBoard[0][0];
    }
    if(bigBoard[0][2] == bigBoard[1][1] &&
      bigBoard[0][2] == bigBoard[2][0] &&
      (bigBoard[0][2] != "" && 
      bigBoard[1][1] != "" &&
      bigBoard[2][0] != "")){
      return bigBoard[0][2];
    }
    return "";
  }

  List<dynamic> isFinish() {
    String vincitore = "";
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if(board[i][j][0] == board[i][j][1] &&
         board[i][j][0] == board[i][j][2] &&
          (board[i][j][0] != "" &&
          board[i][j][1] != "" &&
          board[i][j][2] != "")){
          vincitore = board[i][j][0];
        }
        if(board[i][j][3] == board[i][j][4] &&
         board[i][j][3] == board[i][j][5] &&
          (board[i][j][3] != "" && 
          board[i][j][4] != "" &&
          board[i][j][5] != "")){
          vincitore = board[i][j][3];
        }
        if(board[i][j][6] == board[i][j][7] &&
         board[i][j][6] == board[i][j][8] &&
          (board[i][j][6] != "" && 
          board[i][j][7] != "" &&
          board[i][j][8] != "")){
          vincitore = board[i][j][6];
        }
        if(board[i][j][0] == board[i][j][3] &&
         board[i][j][0] == board[i][j][6] &&
          (board[i][j][0] != "" && 
          board[i][j][3] != "" &&
          board[i][j][6] != "")){
          vincitore = board[i][j][0];
        }
        if(board[i][j][1] == board[i][j][4] &&
         board[i][j][1] == board[i][j][7] &&
          (board[i][j][1] != "" && 
          board[i][j][4] != "" &&
          board[i][j][7] != "")){
          vincitore = board[i][j][1];
        }
        if(board[i][j][2] == board[i][j][5] &&
         board[i][j][2] == board[i][j][8] &&
          (board[i][j][2] != "" && 
          board[i][j][5] != "" &&
          board[i][j][8] != "")){
          vincitore = board[i][j][2];
        }
        if(board[i][j][0] == board[i][j][4] &&
         board[i][j][0] == board[i][j][8] &&
          (board[i][j][0] != "" && 
          board[i][j][4] != "" &&
          board[i][j][8] != "")){
          vincitore = board[i][j][0];
        }
        if(board[i][j][2] == board[i][j][4] &&
         board[i][j][2] == board[i][j][6] &&
          (board[i][j][2] != "" && 
          board[i][j][4] != "" &&
          board[i][j][6] != "")){
          vincitore = board[i][j][2];
        }
        if(vincitore != ""){
          return [i, j, vincitore];
        }
      }
    }
    return [0, 0, ""];
  }

  bool isBoardFull(int index) {
    int r = index ~/ 3;
    int c = index % 3;
    return board[r][c].every((v) => v != "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, bigIndex) {
          int r = bigIndex ~/ 3;
          int c = bigIndex % 3;

          return Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: forcedBoard == null || forcedBoard == bigIndex
                    ? Colors.blue
                    : Colors.grey,
                width: 3,
              ),
            ),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, cellIndex) {
                return GestureDetector(
                  onTap: () => playCell(bigIndex, cellIndex),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Center(
                      child: Text(
                        board[r][c][cellIndex],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
