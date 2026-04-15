import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../main.dart';

class KakuroPuzzle extends StatefulWidget {
  const KakuroPuzzle({super.key, required this.title, this.loggedUser});
  
  final String title;
  final String? loggedUser;

  @override
  State<KakuroPuzzle> createState() => _KakuroDifficultyState();
}

class _KakuroDifficultyState extends State<KakuroPuzzle> {
  int selectedSize = 3;

  String textLabel(){
    if(selectedSize == 1){
      return "4x4";
    } else if (selectedSize == 2){
      return "6x6";
    } else if (selectedSize == 3){
      return "8x8";
    } else if (selectedSize == 4){
      return "9x11";
    } else {
      return "9x17";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Text(
                'Seleziona la grandezza della tabella',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              SizedBox(height: 20),
              Text(
                textLabel(),
                style: TextStyle(fontSize: 20, color: Color(0xFF7F8C8D)),
              ),
              Slider(
                value: selectedSize.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: textLabel(),
                activeColor: Color(0xFF3498DB),
                inactiveColor: Color(0xFFBDC3C7),
                onChanged: (value) {
                  setState(() {
                    selectedSize = value.toInt();
                  });
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KakuroStateful(
                        title: 'Kakuro',
                        size: selectedSize,
                        loggedUser: widget.loggedUser,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Inizia il gioco', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KakuroStateful extends StatefulWidget{
  final String title;
  final int size;
  final String? loggedUser;

  const KakuroStateful({
    super.key,
    required this.title,
    required this.size,
    this.loggedUser,
  });

  @override
  State<KakuroStateful> createState() => _Kakuro();
}

class _Kakuro extends State<KakuroStateful> {
  late List<List<KakuroCell>> solutionGrid;
  late List<List<KakuroCell>> visibleGrid;
  int selectedRow = -1;
  int selectedCol = -1;

  int secondsElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    solutionGrid = generatePuzzle(widget.size);
    printSolutionGrid(solutionGrid);
    visibleGrid = _createVisibleGrid(solutionGrid);
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void resetGame() {
    stopTimer();
    secondsElapsed = 0;
    solutionGrid = generatePuzzle(widget.size);
    printSolutionGrid(solutionGrid);
    visibleGrid = _createVisibleGrid(solutionGrid);
    selectedRow = -1;
    selectedCol = -1;
    startTimer();
  }

  List<List<KakuroCell>> _createVisibleGrid(List<List<KakuroCell>> solution) {
    return solution.map((row) {
      return row.map((cell) {
        if (cell.isClue) {
          return cell;
        } else {
          return KakuroCell(
            isClue: false,
            value: null,
          );
        }
      }).toList();
    }).toList();
  }

  Future<void> _saveScoreIfLoggedIn(int time, int size, String? username) async {
  if (username == null) return;

  if (kIsWeb) {
    await ApiClient.saveScore(username, 'kakuro', size, time);
  } else {
    Database db = await _getDb();
    List<Map<String, Object?>> users = await db.query('users', where: 'nickname = ?', whereArgs: [username]);
    if (users.isNotEmpty) {
      int userId = users.first['id'] as int;
      await db.insert('scores', {
        'userId': userId,
        'game': 'kakuro',
        'difficulty': size,
        'time': time,
      });
    }
  }
}

Future<Database> _getDb() async {
  String path = p.join(await getDatabasesPath(), 'games.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          nickname TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          birthdate TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE scores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          game TEXT NOT NULL,
          difficulty INTEGER NOT NULL,
          time INTEGER NOT NULL,
          timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (userId) REFERENCES users(id)
        )
      ''');
    },
  );
}

  void _onCellTap(int row, int col) {
    if (!visibleGrid[row][col].isClue) {
      setState(() {
        for (int i = 0; i < visibleGrid.length; i++) {
          for (int j = 0; j < visibleGrid[i].length; j++) {
            visibleGrid[i][j].isSelected = false;
          }
        }
        
        visibleGrid[row][col].isSelected = true;

        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _onNumberPressed(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        visibleGrid[selectedRow][selectedCol].value = visibleGrid[selectedRow][selectedCol].value == number ? null : number;
      });
    }
  }

  void _clearCell(){
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        visibleGrid[selectedRow][selectedCol].value = null;
      });
    }
  }

  void _verifySolution() {
    bool isCorrect = true;
    for (int i = 0; i < visibleGrid.length; i++) {
      for (int j = 0; j < visibleGrid[i].length; j++) {
        if (!visibleGrid[i][j].isClue) {
          if (visibleGrid[i][j].value != solutionGrid[i][j].value) {
            isCorrect = false;
            break;
          }
        }
      }
      if (!isCorrect) break;
    }

    stopTimer();

    if (isCorrect) {
      _saveScoreIfLoggedIn(secondsElapsed, widget.size, widget.loggedUser);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("Complimenti, hai vinto!", style: TextStyle(color: Colors.green)),
          content: Text("Hai completato il puzzle correttamente!\nTempo: ${formatTime(secondsElapsed)}"),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); resetGame();},
              child: Text("Gioca Ancora", style: TextStyle(color: Color(0xFF3498DB))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Torna Indietro", style: TextStyle(color: Color(0xFFE74C3C))),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("Hai perso", style: TextStyle(color: Colors.red)),
          content: Text("Soluzione corretta:\n${solutionToString()}"),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); resetGame();},
              child: Text("Riprova", style: TextStyle(color: Color(0xFF3498DB))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Torna Indietro", style: TextStyle(color: Color(0xFFE74C3C))),
            ),
          ],
        ),
      );
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  String solutionToString() {
    String result = "";
    for (var row in solutionGrid) {
      for (var cell in row) {
        if (cell.isClue) {
          result += "C ";
        } else {
          result += "${cell.value} ";
        }
      }
      result += "\n";
    }
    return result;
  }
  
  Widget _buildClueCell(KakuroCell cell) {
    return CustomPaint(
      painter: KakuroCluePainter(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                if (cell.horizontalClue != null)
                GestureDetector(
                  onTap: () {
                    int count = _getSegmentLength(true, cell, visibleGrid);
                    List<List<int>> combinations = getCombinations(cell.horizontalClue!, count);
                    _showCombinations(combinations, cell.horizontalClue!, count, "riga");
                  },
                  child: Text(
                    cell.horizontalClue.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                if (cell.verticalClue != null)
                  GestureDetector(
                    onTap: () {
                      int count = _getSegmentLength(false, cell, visibleGrid);
                      List<List<int>> combinations = getCombinations(cell.verticalClue!, count);
                      _showCombinations(combinations, cell.verticalClue!, count, "colonna");
                    },
                    child: Text(
                      cell.verticalClue.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),  
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getSegmentLength(bool isRow, KakuroCell cell, List<List<KakuroCell>> grid) {
    int count = 0;

    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (identical(grid[i][j], cell)) {
          if (isRow) {
            int c = j + 1;
            while (c < grid[i].length && !grid[i][c].isClue) {
              count++;
              c++;
            }
          } else {
            int r = i + 1;
            while (r < grid.length && !grid[r][j].isClue) {
              count++;
              r++;
            }
          }
          break;
        }
      }
    }

    return count;
  }

  void _showCombinations(List<List<int>> combinations, int sum, int count, String direction) {
    String text = "Combinazioni di $count numeri che sommati ottieni $sum ($direction):\n\n";
    for (var combo in combinations) {
      text += "(${combo.join(', ')})\n";
    }

    if (combinations.isEmpty) {
      text = "Nessuna combinazione possibile.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Combinazioni per $sum in $count celle"),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Chiudi"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCell(KakuroCell cell) {
    return Center(
      child: Text(
        cell.value?.toString() ?? "",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFFF5F7FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (index) {
          int number = index + 1;
          return ElevatedButton(
            onPressed: () => _onNumberPressed(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFECF0F1),
              foregroundColor: Color(0xFF2C3E50),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("$number", style: TextStyle(fontSize: 18)),
          );
        }),
      ),
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Regolamento Kakuro", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "• Ogni riga e colonna deve contenere numeri da 1 a 9.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                "• I numeri in un segmento (tra due celle nere) non si possono ripetere.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                "• I numeri all'interno delle celle nere indicano la somma dei numeri nel segmento orizzontale (in alto a destra) o verticale (in basso a sinistra).",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Chiudi"),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: FocusScope(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId && event.logicalKey.keyId <= LogicalKeyboardKey.digit9.keyId) {
              int number = event.logicalKey.keyId - LogicalKeyboardKey.digit1.keyId + 1;
              _onNumberPressed(number);
            }
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Timer: ${formatTime(secondsElapsed)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Color(0xFF2C3E50)),
                    onPressed: _showRules,
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.2,
                maxScale: 4.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int gridSize = widget.size == 4 ? 12 : (widget.size == 5 ? 18 : _getGridSize(widget.size));
                    int numCols = widget.size == 4 ? 10 : (widget.size == 5 ? 10 : gridSize);

                    double cellSize = 40.0;

                    return Center(
                      child: SizedBox(
                        width: cellSize * numCols,
                        height: cellSize * gridSize,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: numCols,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: gridSize * numCols,
                          itemBuilder: (context, index) {
                            int row = index ~/ numCols;
                            int col = index % numCols;
                            KakuroCell cell = visibleGrid[row][col];

                            return GestureDetector(
                              onTap: () => _onCellTap(row, col),
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: cell.isClue ? Colors.black : (cell.isSelected ? Color(0xFF85C1E9) : Colors.white),
                                  border: Border.all(color: cell.isSelected ? Color.fromARGB(255, 86, 165, 218) : Color(0xFFBDC3C7), width: 0.6),
                                ),
                                child: cell.isClue
                                  ? _buildClueCell(cell)
                                  : _buildInputCell(cell),
                              ),
                            );
                          },
                        )
                      )
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _verifySolution,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Verifica", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    stopTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  int _getGridSize(int size) {
    switch (size) {
      case 1:
        return 5;
      case 2:
        return 7;
      case 3:
        return 9;
      case 4:
        return 12;
      case 5:
        return 18;
      default:
        return 9;
    }
  }
}

class KakuroCluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
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
  bool isSelected;

  KakuroCell({
    this.isClue = false,
    this.horizontalClue,
    this.verticalClue,
    this.value,
    this.isSelected = false,
  });
}

List<List<KakuroCell>> generatePuzzle(int size) {
  int gridSize;

  switch (size) {
    case 1:
      gridSize = 5;
      break;
    case 2:
      gridSize = 7;
      break;
    case 3:
      gridSize = 9;
      break;
    case 4:
      gridSize = 12;
      break;
    case 5:
      gridSize = 18;
      break;
    default:
      gridSize = 9;
  }

  int numCols = size == 4 ? 10 : (size == 5 ? 10 : gridSize);

  List<List<KakuroCell>> grid = List.generate(gridSize, (i) {
    return List.generate(numCols, (j) {
      bool isClue = false;

      if(i == 0 || j ==0){
        isClue = true;
      }

      return KakuroCell(
        isClue: isClue,
        horizontalClue: null,
        verticalClue: null,
        value: null
      );
    });
  });

  Random rand = Random();

  int clueCountMin = 0;
  int clueCountMax = 0;

  if (size == 1) {
    clueCountMin = 4;
    clueCountMax = 6;
  } else if (size == 2) {
    clueCountMin = 10;
    clueCountMax = 10;
  } else if (size == 3) {
    clueCountMin = 16;
    clueCountMax = 18;
  } else if (size == 4) {
    clueCountMin = 15;
    clueCountMax = 30;
  } else if (size == 5) {
    clueCountMin = 55;
    clueCountMax = 60;
  }

  int clueCount = rand.nextInt(clueCountMax - clueCountMin + 1) + clueCountMin;

  Set<(int, int)> cluePositions = {};

  while (cluePositions.length < clueCount){
    int i = rand.nextInt(gridSize - 1) + 1;
    int j = rand.nextInt(numCols - 1) + 1;

    cluePositions.add((i, j));
  }

  for ((int, int) pos in cluePositions) {
    int i = pos.$1;
    int j = pos.$2;
    grid[i][j] = KakuroCell(
      isClue: true,
      horizontalClue: null,
      verticalClue: null,
      value: null
    );
  }

  for (int i = 1; i < gridSize; i++) {
    for (int j = 1; j < numCols; j++) {
      if (!grid[i][j].isClue){
        List<int> usedInRow = _getUsedNumbersInRowSegment(grid, i, j);
        List<int> usedInCol = _getUsedNumbersInColSegment(grid, i, j);

        List<int> available = List.generate(9, (i) => i + 1)
            .where((n) => !usedInRow.contains(n) && !usedInCol.contains(n))
            .toList();

        if(available.isNotEmpty){
          grid[i][j].value = available[rand.nextInt(available.length)];
        } else {
          grid[i][j] = KakuroCell(
            isClue: true,
            horizontalClue: null,
            verticalClue: null,
            value: null,
          );
        }
      }
    }
  }

  computeClues(grid);

  return grid;
}

void computeClues(List<List<KakuroCell>> grid) {
  int rows = grid.length;
  int cols = grid[0].length;

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (grid[i][j].isClue) {
        int? horizontalClue;
        int? verticalClue;

        if (j + 1 < cols && !grid[i][j + 1].isClue) {
          int sum = 0;
          int c = j + 1;
          while (c < cols && !grid[i][c].isClue) {
            if (grid[i][c].value != null) {
              sum += grid[i][c].value!;
            }
            c++;
          }
          if (sum > 0) {
            horizontalClue = sum;
          }
        }

        if (i + 1 < rows && !grid[i + 1][j].isClue) {
          int sum = 0;
          int r = i + 1;
          while (r < rows && !grid[r][j].isClue) {
            if (grid[r][j].value != null) {
              sum += grid[r][j].value!;
            }
            r++;
          }
          if (sum > 0) {
            verticalClue = sum;
          }
        }

        if (horizontalClue != null || verticalClue != null) {
          grid[i][j] = KakuroCell(
            isClue: true,
            horizontalClue: horizontalClue,
            verticalClue: verticalClue,
            value: null,
          );
        }
      }
    }
  }
}

List<int> _getUsedNumbersInRowSegment(List<List<KakuroCell>> grid, int row, int col) {
  List<int> used = [];

  int c = col - 1;
  while (c >= 0 && !grid[row][c].isClue) {
    if (grid[row][c].value != null) {
      used.add(grid[row][c].value!);
    }
    c--;
  }

  c = col + 1;
  while (c < grid[row].length && !grid[row][c].isClue) {
    if (grid[row][c].value != null) {
      used.add(grid[row][c].value!);
    }
    c++;
  }

  return used;
}

List<int> _getUsedNumbersInColSegment(List<List<KakuroCell>> grid, int row, int col) {
  List<int> used = [];

  int r = row - 1;
  while (r >= 0 && !grid[r][col].isClue) {
    if (grid[r][col].value != null) {
      used.add(grid[r][col].value!);
    }
    r--;
  }

  r = row + 1;
  while (r < grid.length && !grid[r][col].isClue) {
    if (grid[r][col].value != null) {
      used.add(grid[r][col].value!);
    }
    r++;
  }

  return used;
}

List<List<int>> getCombinations(int sum, int count) {
  List<List<int>> results = [];
  List<int> current = [];

  void backtrack(int start, int remainingSum, int remainingCount) {
    if (remainingCount == 0){
      if (remainingSum == 0){
        results.add(List.from(current));
      }
      return;
    }

    for (int i = start; i <= 9; i++) {
      if (i > remainingSum) break;
      current.add(i);
      backtrack(i + 1, remainingSum - i, remainingCount - 1);
      current.removeLast();
    }
  }

  backtrack(1, sum, count);
  return results;
}

void printSolutionGrid(List<List<KakuroCell>> grid) {
  print("\nSoluzione generata:");
  for (var row in grid) {
    String line = '';
    for (var cell in row) {
      if (cell.isClue) {
        line += 'C ';
      } else {
        line += '${cell.value ?? "_"} ';
      }
    }
    print(line);
  }
  print("\n");
}