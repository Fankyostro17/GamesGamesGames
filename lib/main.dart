import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'screens/Kakuro/KakuroPuzzle.dart';
import 'screens/Trivia/TriviaGames.dart';
import 'screens/WorkspaceVolts/WorkspaceVolts.dart';
import 'screens/SuperTris/SuperTrisGame.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;
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

  final int _itemsGames = 4;

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
                      itemCount: _itemsGames,
                      itemBuilder: (context, index) {
                        final games = [
                          {'title': 'Trivia', 'logo': '../assets/images/TriviaLogo.png'},
                          {'title': 'Super Tris', 'logo': '../assets/images/SuperTrisLogo.png'},
                          {'title': 'Kakuro', 'logo': '../assets/images/KakuroLogo.png'},
                          {'title': 'Workspace Volts', 'logo': '../assets/images/door.png'},
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
                                  : _selectedGame == 'Workspace Volts'
                                  ? SafetyApp()
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