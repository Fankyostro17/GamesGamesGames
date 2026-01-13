import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    try {
      sqfliteFfiInit();
      databaseFactory = ffi_web.databaseFactoryFfiWeb;
    } catch (e) {
      print("Errore inizializzazione Web: $e");
    }
  } else {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }
  }
  
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
  String? _currentUser;
  String? _selectedGame;

  void _selectGame(String game) {
    setState(() {
      _selectedGame = _selectedGame == game ? null : game;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: [
          if(_currentUser == null)
            IconButton(
              icon: Icon(Icons.login, color: Colors.white),
              onPressed: () async {
                String? user = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                if(user != null){
                  setState(() {
                    _currentUser = user;
                  });
                }
              },
            )
          else
            PopupMenuButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Utente: $_currentUser'),
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  onTap: () {
                    setState(() {
                      _currentUser = null;
                    });
                  },
                ),
              ],
            ),
        ],
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FD), Color(0xFFD6EAF8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              if (_currentUser != null)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFAED6F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Loggato come: $_currentUser',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final games = [
                          {'title': 'Trivia', 'logo': '../assets/images/TriviaLogo.png'},
                          {'title': 'Super Tris', 'logo': '../assets/images/SuperTrisLogo.png'},
                          {'title': 'Kakuro', 'logo': '../assets/images/KakuroLogo.png'},
                        ];
                        final game = games[index];
                        bool isSelected = _selectedGame == game['title'];

                        return _buildGameCard(
                          title: game['title']!,
                          logoAsset: game['logo']!,
                          isSelected: isSelected,
                          onTap: () => _selectGame(game['title']!),
                        );
                      },
                    );
                  }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                          _selectedGame == 'Trivia'
                            ? TriviaDifficulty(title: "Trivia Difficulty")
                            : _selectedGame == 'Super Tris'
                              ? SuperTrisChoiceScreen()
                              : _selectedGame == 'Kakuro'
                                ? KakuroPuzzle(
                                    title: "Kakuro Difficulty",
                                    loggedUser: _currentUser,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Inizia il Gioco',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String logoAsset,
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
            color: isSelected ? Color(0xFF3498DB) : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                logoAsset,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
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

class ApiClient {
  static const String baseUrl = 'http://192.168.10.219/games_db/api'; //"http://10.0.2.2/games_db/api" per emulatore android

  static Future<bool> _register(String email, String nickname, String password, String birthdate) async {
    try {
      print("Invio registrazione a: http://127.0.0.1/games_db/api/register.php");
      print("Dati: email=$email, nickname=$nickname, password=$password, birthdate=$birthdate");

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register.php'));
      request.fields['email'] = email;
      request.fields['nickname'] = nickname;
      request.fields['password'] = password;
      request.fields['birthdate'] = birthdate;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Status code: ${response.statusCode}");
      print("Response body: $responseBody");

      if (response.statusCode == 200) {
        var data = jsonDecode(responseBody);
        return data['success'] == true;
      } else {
        print("Errore HTTP: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Errore registrazione: $e");
      return false;
    }
  }

  static Future<String?> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'login': login,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['nickname'];
      }
      return null;
    } catch (e) {
      print("Errore login: $e");
      return null;
    }
  }

  static Future<bool> saveScore(String nickname, String game, int difficulty, int time) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_score.php'),
        body: {
          'nickname': nickname,
          'game': game,
          'difficulty': difficulty.toString(),
          'time': time.toString(),
        },
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Errore salvataggio punteggio: $e");
      return false;
    }
  }

  static Future<bool> saveTriviaScore({
    required String nickname,
    required String difficulty,
    required String category,
    required int time,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      print("Invio dati a: $baseUrl/save_trivia_score.php");
      print("Dati: nickname=$nickname, difficulty=$difficulty, category=$category, time=$time, correctAnswers=$correctAnswers, totalQuestions=$totalQuestions");

      final response = await http.post(
        Uri.parse('$baseUrl/save_trivia_score.php'),
        body: {
          'nickname': nickname,
          'difficulty': difficulty,
          'category': category,
          'time': time.toString(),
          'correctAnswers': correctAnswers.toString(),
          'totalQuestions': totalQuestions.toString(),
        },
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Errore salvataggio punteggio trivia: $e");
      return false;
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(title: Text("Accedi")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: 400,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Accedi al tuo account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: "Email o Nickname",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      String login = _loginController.text;
                      String password = _passwordController.text;

                      String? user = await _authenticate(login, password);
                      if (user != null) {
                        Navigator.pop(context, user);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Errore"),
                            content: Text("Email/Nickname o Password errati."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Accedi", style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text("Non hai un account? Registrati qui"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _authenticate(String login, String password) async {
    if (kIsWeb) {
      return await ApiClient.login(login, password);
    } else {
      Database db = await _getDb();
      List<Map<String, Object?>> users = await db.query(
        'users',
        where: '(email = ? OR nickname = ?) AND password = ?',
        whereArgs: [login, login, password],
      );
      if (users.isNotEmpty) {
        return users.first['nickname'] as String;
      }
      return null;
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
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _birthdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(title: Text("Registrati")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: 400,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Crea un nuovo account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: "Nickname",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            _birthdate = date;
                          });
                        }
                      });
                    },
                    child: Text(_birthdate == null ? "Seleziona Data di Nascita" : "Data: ${_birthdate!.toLocal().toString().split(' ')[0]}"),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      bool success = await ApiClient._register(
                        _emailController.text,
                        _nicknameController.text,
                        _passwordController.text,
                        _birthdate!.toIso8601String().split('T')[0],
                      );
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Errore"),
                            content: Text("Email o Nickname già esistenti, o dati non validi."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Registrati", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  stopTimer() {
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

class SuperTrisChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modalità Super Tris",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FD), Color(0xFFD6EAF8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChoiceCard(
                title: "1 vs AI",
                subtitle: "Gioca contro un'intelligenza artificiale",
                icon: Icons.computer_outlined,
                color: Color(0xFF3498DB),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Funzione in sviluppo"),
                      content: Text("Questa modalità verrà implementata in futuro."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildChoiceCard(
                title: "1 vs 1 Locale",
                subtitle: "Gioca con un amico sullo stesso dispositivo",
                icon: Icons.people_alt_outlined,
                color: Color(0xFF2ECC71),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperTrisLocal(title: "Super Tris Locale"),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildChoiceCard(
                title: "1 vs 1 Online",
                subtitle: "Gioca contro un avversario in tempo reale",
                icon: Icons.network_wifi_outlined,
                color: Color(0xFF9B59B6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperTrisOnline(title: "Super Tris Online"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
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
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class SuperTrisLocal extends StatefulWidget {
  const SuperTrisLocal({super.key, required this.title});

  final String title;

  @override
  State<SuperTrisLocal> createState() => _SuperTrisLocalState();
}

class _SuperTrisLocalState extends State<SuperTrisLocal> {
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
  bool gameOver = false;
  String winner = "";

  void playCell(int bigIndex, int cellIndex) {
    if(gameOver) return;

    int r = bigIndex ~/ 3;
    int c = bigIndex % 3;

    if (bigBoard[r][c] != "") return;

    if (forcedBoard != null && forcedBoard != bigIndex) {
      int fr = forcedBoard! ~/ 3;
      int fc = forcedBoard! % 3;
      if (bigBoard[fr][fc] == "" && !isBoardFull(forcedBoard!)) {
        return;
      }
    }

    if (board[r][c][cellIndex] != "") return;

    setState(() {
      board[r][c][cellIndex] = currentPlayer;

      String subWinner = checkWinnerInSmallBoard(r, c);
      if (subWinner != "") {
        bigBoard[r][c] = subWinner;
      } else if (isBoardFull(bigIndex)) {
        bigBoard[r][c] = "D";
      }

      forcedBoard = cellIndex;

      if (bigBoard[forcedBoard! ~/ 3][forcedBoard! % 3] != "" || isBoardFull(forcedBoard!)) forcedBoard = null;

      currentPlayer = currentPlayer == "X" ? "O" : "X";
    });

    String gameWinner = isFinishBigBoard();
    if (gameWinner != "") {
      setState((){
        gameOver = true;
        winner = gameWinner;
      });
      _showGameOverDialog();
      return;
    }

    if (isBigBoardFull()) {
      setState(() {
        gameOver = true;
        winner = "Pareggio";
      });
      _showGameOverDialog();
    }

  }

  bool isBigBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (bigBoard[i][j] == "") return false;
      }
    }
    return true;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Partita terminata"),
          content: Text(winner == "Pareggio" ? "È un pareggio!" : "Vince: $winner"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.generate(3, (_) => List.filled(9, "")));
      bigBoard = List.generate(3, (_) => List.filled(3, ""));
      currentPlayer = "X";
      forcedBoard = null;
      gameOver = false;
      winner = "";
    });
  }

  String checkWinnerInSmallBoard(int r, int c) {
    List<String> subBoard = board[r][c];

    if (subBoard[0] == subBoard[1] && subBoard[0] == subBoard[2] && subBoard[0] != "") return subBoard[0];
    if (subBoard[3] == subBoard[4] && subBoard[3] == subBoard[5] && subBoard[3] != "") return subBoard[3];
    if (subBoard[6] == subBoard[7] && subBoard[6] == subBoard[8] && subBoard[6] != "") return subBoard[6];

    if (subBoard[0] == subBoard[3] && subBoard[0] == subBoard[6] && subBoard[0] != "") return subBoard[0];
    if (subBoard[1] == subBoard[4] && subBoard[1] == subBoard[7] && subBoard[1] != "") return subBoard[1];
    if (subBoard[2] == subBoard[5] && subBoard[2] == subBoard[8] && subBoard[2] != "") return subBoard[2];

    if (subBoard[0] == subBoard[4] && subBoard[0] == subBoard[8] && subBoard[0] != "") return subBoard[0];
    if (subBoard[2] == subBoard[4] && subBoard[2] == subBoard[6] && subBoard[2] != "") return subBoard[2];

    return "";
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
      appBar: AppBar(title: Text(widget.title, style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF2C3E50),),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FD), Color.fromARGB(255, 70, 167, 236)],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder: (context, bigIndex) {
            int r = bigIndex ~/ 3;
            int c = bigIndex % 3;

            if(bigBoard[r][c] != "" && bigBoard[r][c] != "D"){
              return Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    bigBoard[r][c],
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ),
              );

            }

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
      ),
    );
  }
}

class SuperTrisOnline extends StatefulWidget {
  const SuperTrisOnline({super.key, required this.title});

  final String title;

  @override
  State<SuperTrisOnline> createState() => _SuperTrisOnlineState();
}

class _SuperTrisOnlineState extends State<SuperTrisOnline> {
  IO.Socket? socket;
  String? roomCode;
  bool isCreating = false;
  bool isConnected = false;
  String enteredCode = '';
  String mySymbol = "";

  List<List<List<String>>> board = List.generate(3, (_) => List.generate(3, (_) => List.filled(9, "")));
  List<List<String>> bigBoard = List.generate(3, (_) => List.filled(3, ""));
  String currentPlayer = "X";
  int? forcedBoard;
  bool gameOver = false;
  String winner = "";

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://127.0.0.1:12345', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket!.onConnect((_) {
      print('Connected');
    });

    socket!.on('created', (data) {
      setState(() {
        roomCode = data['roomCode'];
        mySymbol = "X";
        isCreating = false;
        isConnected = true;
      });
    });

    socket!.on('joined', (data) {
      setState(() {
        roomCode = data['roomCode'];
        mySymbol = "O";
        isConnected = true;
      });
    });

    socket!.on('update', (data) {
      setState(() {
        board = List<List<List<String>>>.from(data['board'].map((r) => 
          List<List<String>>.from(r.map((c) => List<String>.from(c)))));
        bigBoard = List<List<String>>.from(data['bigBoard'].map((r) => List<String>.from(r)));
        currentPlayer = data['currentPlayer'];
        forcedBoard = data['forcedBoard'];
        gameOver = data['gameOver'];
        winner = data['winner'];
      });

      if (gameOver) {
        _showGameOverDialog();
      }
    });

    socket!.on('error', (data) {
      print('Error: ${data['message']}');
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Partita terminata"),
          content: Text(winner == "Pareggio" ? "È un pareggio!" : "Vince: $winner"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void makeMove(int bigIndex, int cellIndex) {
    if (!isConnected || gameOver) return;

    if (currentPlayer != mySymbol) return;

    socket!.emit('move', {
      'roomCode': roomCode,
      'bigIndex': bigIndex,
      'cellIndex': cellIndex
    });
  }

  void createRoom() {
    setState(() => isCreating = true);
    socket!.emit('create');
  }

  void joinRoom() {
    if (enteredCode.isEmpty) return;
    socket!.emit('join', {'roomCode': enteredCode});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6A11CB),
      ),
      body: isConnected
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Codice stanza: $roomCode",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Turno: $currentPlayer",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "Tu sei: $mySymbol",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, bigIndex) {
                        int r = bigIndex ~/ 3;
                        int c = bigIndex % 3;

                        if (bigBoard[r][c] != "" && bigBoard[r][c] != "D") {
                          return Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.yellow.shade600,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white70,
                            ),
                            child: Center(
                              child: Text(
                                bigBoard[r][c],
                                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white38),
                              ),
                            ),
                          );
                        }

                        return Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: forcedBoard == null || forcedBoard == bigIndex
                                  ? Colors.cyan.shade400
                                  : Colors.grey.shade400,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, cellIndex) {
                              bool isPlayable = isConnected && 
                                            !gameOver && 
                                            currentPlayer == mySymbol;

                              return GestureDetector(
                                onTap: isPlayable ? () => makeMove(bigIndex, cellIndex) : null,
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white30),
                                    color: isPlayable 
                                              ? Colors.green.shade200
                                              : Colors.grey.shade300,
                                  ),
                                  child: Center(
                                    child: Text(
                                      board[r][c][cellIndex],
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],              
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (roomCode == null)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: createRoom,
                              child: Text("Crea Stanza"),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              decoration: InputDecoration(hintText: "Inserisci codice stanza"),
                              onChanged: (value) => enteredCode = value.toUpperCase(),
                            ),
                            ElevatedButton(
                              onPressed: joinRoom,
                              child: Text("Unisciti"),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text("Codice stanza: $roomCode", style: TextStyle(fontSize: 24, color: Colors.white)),
                            SizedBox(height: 20),
                            Text(isConnected ? "Connesso!" : "In attesa di connessione...", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }
}