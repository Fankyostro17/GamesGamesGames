import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    socket?.disconnect();

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

      socket!.on('opponent_disconnected', (_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Avversario disconnesso"),
            content: Text("L'altro giocatore ha lasciato la partita."),
            actions: [
              TextButton(
                onPressed: () {
                  socket?.disconnect();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
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
                socket?.disconnect();
                Navigator.of(context).pop();
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

  void _disconnectAndExit() {
    print("Disconnected");
    socket?.close();
    socket = null;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF6A11CB),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _disconnectAndExit();
            },
          ),
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
      ),
    );
  }

  @override
  void dispose() {
    print("Dispose chiamato");
    socket?.disconnect();
    super.dispose();
  }
}