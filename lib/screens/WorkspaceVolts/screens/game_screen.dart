import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/levels.dart';
import '../utils/progress_manager.dart';

class GameScreen extends StatefulWidget {
  final int initialLevel;

  const GameScreen({super.key, this.initialLevel = 1});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int level = 1;
  int score = 0;
  int lives = 1;
  int levelStartScore = 0;
  int extinguisherCount = 0;
  bool isPaused = false;
  bool gameWon = false;
  bool isDead = false;
  int? bestScoreForCurrentLevel;
  int totalScore = 0;
  int collectedInCurrentLevel = 0;

  bool _exitMessageShown = false;

  double playerX = 1.0;
  double playerY = 10.0;
  
  double velocityX = 0.0;
  double velocityY = 0.0;
  bool onGround = false;
  
  bool leftPressed = false;
  bool rightPressed = false;
  bool jumpPressed = false;

  static const double moveAccel = 0.05;
  static const double friction = 0.80;
  static const double gravity = 0.06;
  static const double jumpForce = -0.68;
  static const double maxSpeedX = 0.20;
  static const double maxVelocityY = 15.0;

  double cellSize = 48.0;

  final List<Item> items = [];
  final List<Obstacle> obstacles = [];
  Exit? exit;

  bool invincible = false;
  Timer? invincibilityTimer;
  late Timer _physicsTimer;

  final Set<Offset> platformCells = {};
  final List<Level> _allLevels = allLevels;

  @override
  void initState() {
    super.initState();
    level = widget.initialLevel;
    _loadTotalScore();
    _initLevel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updatePhysics();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    ProgressManager.saveTotalScore(totalScore);
    _physicsTimer.cancel();
    invincibilityTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _updatePhysics() {
    if (isPaused || gameWon || isDead) return;

    if (leftPressed) {
      velocityX -= moveAccel;
    } else if (rightPressed) velocityX += moveAccel;
    else velocityX *= friction;

    velocityX = velocityX.clamp(-maxSpeedX, maxSpeedX);

    playerX += velocityX;
    _resolveHorizontalCollisions();

    if (jumpPressed && onGround) {
      velocityY = jumpForce;
      onGround = false;
      jumpPressed = false;
    }

    velocityY += gravity;
    velocityY = velocityY.clamp(-maxVelocityY, maxVelocityY);
    
    playerY += velocityY;
    onGround = false;
    _resolveVerticalCollisions();

    playerX = playerX.clamp(0.0, 11.0);
    if (playerY > 16.0) {
      _hitObstacle(ObstacleType.electricalPanel);
    }
    playerY = playerY.clamp(0.0, 16.0);

    _checkInteractions();

    setState(() {});
  }

  void _resolveHorizontalCollisions() {
    int leftTile = playerX.floor();
    int rightTile = playerX.ceil();
    int topTile = playerY.floor();
    int bottomTile = (playerY + 0.99).floor();

    if (velocityX < 0) {
      for (int y = topTile; y <= bottomTile; y++) {
        if (platformCells.contains(Offset(leftTile.toDouble(), y.toDouble()))) {
          playerX = leftTile + 1.0;
          velocityX = 0;
          break;
        }
      }
    }

    if (velocityX > 0) {
      for (int y = topTile; y <= bottomTile; y++) {
        if (platformCells.contains(Offset(rightTile.toDouble(), y.toDouble()))) {
          playerX = rightTile - 1.0;
          velocityX = 0;
          break;
        }
      }
    }
  }

  void _resolveVerticalCollisions() {
    int leftTile = playerX.floor();
    int rightTile = playerX.ceil();
    int topTile = playerY.floor();
    int bottomTile = (playerY + 0.99).floor();

    if (velocityY > 0) {
      for (int x = leftTile; x <= rightTile; x++) {
        if (platformCells.contains(Offset(x.toDouble(), bottomTile.toDouble()))) {
          playerY = bottomTile - 1.0;
          velocityY = 0;
          onGround = true;
          break;
        }
      }
    }

    if (velocityY < 0) {
      for (int x = leftTile; x <= rightTile; x++) {
        if (platformCells.contains(Offset(x.toDouble(), topTile.toDouble()))) {
          playerY = topTile + 1.0;
          velocityY = 0;
          break;
        }
      }
    }
  }

  void _initLevel() async {
    if (level - 1 >= _allLevels.length) {
      print('Nessun altro livello disponibile!');
      return;
    }

    final currentLevel = _allLevels[level - 1];
    items.clear(); items.addAll(currentLevel.items);
    obstacles.clear(); obstacles.addAll(currentLevel.obstacles);
    exit = currentLevel.exit;
    platformCells.clear(); platformCells.addAll(currentLevel.platforms);
    bestScoreForCurrentLevel = await ProgressManager.getLevelBestScore(level);
    collectedInCurrentLevel = await ProgressManager.getCollectedPoints(level);

    playerX = currentLevel.playerStartPos.dx;
    playerY = currentLevel.playerStartPos.dy;
    velocityX = 0; velocityY = 0;
    onGround = false;
    jumpPressed = false;

    leftPressed = false;
    rightPressed = false;

    levelStartScore = score;
    extinguisherCount = 0;

    collectedInCurrentLevel = 0;

    setState(() {});
  }

  Future<void> _loadTotalScore() async {
    totalScore = await ProgressManager.loadTotalScore();
    if (score == 0) score = totalScore;
  }

  void _handleKeyInput(KeyEvent event) {
    if (isPaused || gameWon || isDead) return;

    final isDown = event is KeyDownEvent;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) leftPressed = isDown;
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) rightPressed = isDown;
    if ((key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyW) && isDown) jumpPressed = true;
  }

  void _onLeftDown() => leftPressed = true;
  void _onLeftUp() => leftPressed = false;
  void _onRightDown() => rightPressed = true;
  void _onRightUp() => rightPressed = false;
  void _onJump() => jumpPressed = true;

  void _hitObstacle(ObstacleType type) {
    if (isDead || isPaused || gameWon) return;
    if (lives <= 0) return;
    lives--;
    if (lives == 0) {
      setState(() {
        isDead = true;
        velocityX = 0;
        velocityY = 0;
        leftPressed = false;
        rightPressed = false;
        jumpPressed = false;
        extinguisherCount = 0;
      });
    } else {
      setState(() {
        playerX = _allLevels[level - 1].playerStartPos.dx;
        playerY = _allLevels[level - 1].playerStartPos.dy;
        velocityX = 0;
        velocityY = 0;
        invincible = true;
        leftPressed = false;
        rightPressed = false;
        jumpPressed = false;
        extinguisherCount = 0;
      });
      invincibilityTimer?.cancel();
      invincibilityTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => invincible = false);
      });
    }
  }

  void _applyItemEffect(ItemType type) {
    switch (type) {
      case ItemType.gloves:
        invincibilityTimer?.cancel();
        setState(() => invincible = true);
        invincibilityTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => invincible = false);
        });
        break;
      case ItemType.helmet:
        score += 15;
        break;
      case ItemType.extinguisher:
      case ItemType.idrante:
        obstacles.removeWhere((obs) =>
            obs.pos.dx.round() == playerX.round() || obs.pos.dy.round() == playerY.round());
        break;
    }
  }

  void _levelComplete() async {
    gameWon = true;
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (mounted) {
        await ProgressManager.markLevelCompleted(level);

        score += 50;

        await ProgressManager.saveLevelScore(level, score);

        totalScore = score;
        await ProgressManager.saveTotalScore(totalScore);

        final previousBest = await ProgressManager.getCollectedPoints(level);
        if (collectedInCurrentLevel > previousBest) {
          await ProgressManager.saveCollectedPoints(level, collectedInCurrentLevel);
        }

        if (level >= _allLevels.length) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: const Color(0xFF0A192F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.green, width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.amber[400],
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      'COMPLIMENTI!',
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Hai completato tutti i livelli!\nSei un esperto di sicurezza!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Punteggio totale: $score',
                      style: TextStyle(
                        color: Colors.amber[400],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.home, color: Colors.black),
                        label: const Text(
                          'TORNA ALLA HOME',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return;
        }

        setState(() {
          level++;
          gameWon = false;
          leftPressed = false;
          rightPressed = false;
          jumpPressed = false;
          _initLevel();
        });
      }
    });
  }

  /*void _levelComplete() {
    gameWon = true;
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      // ✅ TUTTI QUESTI METODI ORA SONO SINCRONI (niente await!)
      ProgressManager.markLevelCompleted(level);
      
      score += 50; // Bonus completamento
      
      ProgressManager.saveLevelScore(level, score);
      
      totalScore = score;
      ProgressManager.saveTotalScore(totalScore);
      
      // ✅ Confronto e salvataggio punti raccolti (sincrono)
      final previousBest = ProgressManager.getCollectedPoints(level);
      if (collectedInCurrentLevel > previousBest) {
        ProgressManager.saveCollectedPoints(level, collectedInCurrentLevel);
      }
      
      // ✅ Controlla se è l'ultimo livello
      if (level >= _allLevels.length) {
        // 🎉 Mostra popup finale
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: const Color(0xFF0A192F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.green, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: Colors.amber[400]),
                  const SizedBox(height: 20),
                  Text(
                    'COMPLIMENTI!',
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hai completato tutti i livelli!\nSei un esperto di sicurezza! 🔒⚡',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Punteggio totale: $score',
                    style: TextStyle(color: Colors.amber[400], fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Chiudi dialog
                        Navigator.pop(context); // Torna a LevelSelect
                        Navigator.pop(context); // Torna a Home
                      },
                      icon: const Icon(Icons.home, color: Colors.black),
                      label: const Text('TORNA ALLA HOME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        // ✅ IMPORTANTE: Non avanzare oltre l'ultimo livello
        return;
      }
      
      // ✅ Solo se NON è l'ultimo livello, avanza
      setState(() {
        level++;
        gameWon = false;
        leftPressed = false;
        rightPressed = false;
        jumpPressed = false;
        _initLevel();
      });
    });
  }*/

  void _checkInteractions() {
    if (level - 1 >= _allLevels.length) {
      print('[DEBUG] Livello $level non esiste in allLevels (max: ${_allLevels.length})');
      return;
    }

    int gridX = playerX.round();
    int gridY = playerY.round();
    Offset playerGridPos = Offset(gridX.toDouble(), gridY.toDouble());

    for (int i = items.length - 1; i >= 0; i--) {
      if (items[i].pos == playerGridPos) {
        final item = items[i];
        _collectItem(item);
        items.removeAt(i);
      }
    }

    for (final obs in obstacles) {
      if (obs.pos == playerGridPos) {
        if (obs.type == ObstacleType.fire) {
          if (extinguisherCount > 0) {
            extinguisherCount--;
            obstacles.remove(obs);
            print('🧯 Fuoco spento! Estintori rimasti: $extinguisherCount');
          } else {
            _hitObstacle(obs.type);
          } break;
        } 

        if (!invincible) {
          _hitObstacle(obs.type);
        }

        break;
      }
    }

    if (exit != null && exit!.pos == playerGridPos) {
      final totalItems = _allLevels[level - 1].items.length;
      final collectedItems = totalItems - items.length;
      
      if (collectedItems >= (totalItems * 0.5).ceil()) {
        _exitMessageShown = false;
        _levelComplete();
      } else {
        if (!_exitMessageShown) {
          _showBlockedExitMessage();
          _exitMessageShown = true;
        }
      }
    } else {
      _exitMessageShown = false;
    }
  }

  void _collectItem(Item item) {
    score += item.points;
    collectedInCurrentLevel += item.points;
    
    switch (item.type) {
      case ItemType.gloves:
        _activateInvincibility();
        break;
      case ItemType.helmet:
        score += 5;
        break;
      case ItemType.extinguisher:
        extinguisherCount++;
        print('🧯 Estintore raccolto! Totale in inventario: $extinguisherCount');
        break;
      case ItemType.idrante:
        _extinguishFiresInRow(playerY.round());
        print('🚒 Idrante usato! Fuochi nella riga ${playerY.round()} spenti.');
        break;
    }
    
    print('Raccolto: ${item.type} (+${item.points} punti) | Totale livello: $collectedInCurrentLevel');
  }

  void _activateInvincibility() {
    invincibilityTimer?.cancel();
    setState(() => invincible = true);
    
    invincibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => invincible = false);
    });
  }

  void _clearNearbyHazards(int playerGridX, int playerGridY) {
    obstacles.removeWhere((obs) {
      int obsX = obs.pos.dx.round();
      int obsY = obs.pos.dy.round();
      return obsX == playerGridX || obsY == playerGridY;
    });
    print('🧯 Pericoli vicini eliminati!');
  }

  void _extinguishFiresInRow(int rowY) {
    final firesInRow = obstacles.where((obs) => 
      obs.type == ObstacleType.fire && obs.pos.dy.round() == rowY).length;
    
    obstacles.removeWhere((obs) => 
      obs.type == ObstacleType.fire && obs.pos.dy.round() == rowY);
    
    print('🚒 Fuochi spenti nella riga $rowY: $firesInRow');
    
    score += firesInRow * 5;
  }

  void _showBlockedExitMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔒 Raccogli almeno il 50% degli oggetti per uscire!'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyInput,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
              painter: _GridPainter(),
            ),
            Center(
              child: SizedBox(
                width: cellSize * 12,
                height: cellSize * 16,
                child: Stack(
                  children: [
                    ..._buildPlatforms(),
                    ...items.map((item) => _buildItem(item)),
                    ...obstacles.map((obs) => _buildObstacle(obs)),
                    if (exit != null) _buildExit(exit!),
                    _buildPlayer(),
                  ],
                ),
              ),
            ),
            _buildTopBar(),
            _buildBottomControls(),
            if (isPaused) _buildPauseOverlay(),
            if (gameWon) _buildWinOverlay(),
            if (isDead) _buildDeathOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeathOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Card(
          color: const Color(0xFF0A192F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'SEI MORTO!',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Punteggio: $score',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isDead = false;
                        lives = 1;
                        score = levelStartScore;
                        extinguisherCount = 0;
                        leftPressed = false;
                        rightPressed = false;
                        jumpPressed = false;
                        _initLevel();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.black),
                    label: const Text(
                      'RIPROVA',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  width: 200,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home, color: Colors.cyan),
                    label: const Text(
                      'HOME',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.cyan,
                      side: const BorderSide(color: Colors.cyan),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlatforms() {
    return platformCells.map((pos) => Positioned(
      left: pos.dx * cellSize, top: pos.dy * cellSize,
      width: cellSize, height: cellSize,
      child: Container(color: const Color(0xFF2A476B)),
    )).toList();
  }

  /*Widget _buildPlayer() {
    return Positioned(
      left: playerX * cellSize,
      top: playerY * cellSize,
      width: cellSize,
      height: cellSize,
      child: Container(
        decoration: BoxDecoration(
          color: isDead 
              ? Colors.red[900] 
              : (invincible 
                  ? (DateTime.now().millisecondsSinceEpoch ~/ 100 % 2 == 0 
                      ? Colors.yellow 
                      : Colors.yellow.withOpacity(0.3))
                  : Colors.cyan),
          
          borderRadius: BorderRadius.circular(4),
          
          border: Border.all(
            color: isDead 
                ? Colors.red 
                : (invincible ? Colors.orange : Colors.white), 
            width: isDead ? 3 : (invincible ? 3 : 2),
          ),
          
          boxShadow: isDead ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.8),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ] : (invincible ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : []),
        ),
        child: Center(
          child: Text(
            isDead ? '💀' : (invincible ? '🧤' : '👤'),
            style: TextStyle(fontSize: cellSize * 0.8),
          ),
        ),
      ),
    );
  }*/

  Widget _buildPlayer() {
    return Positioned(
      left: playerX * cellSize,
      top: playerY * cellSize,
      width: cellSize,
      height: cellSize,
      child: Container(
        decoration: BoxDecoration(
          color: isDead 
              ? Colors.red[900] 
              : (invincible 
                  ? (DateTime.now().millisecondsSinceEpoch ~/ 100 % 2 == 0 
                      ? Colors.yellow 
                      : Colors.yellow.withOpacity(0.3))
                  : Colors.transparent),
          
          borderRadius: BorderRadius.circular(4),
          
          /*border: Border.all(
            color: isDead 
                ? Colors.red 
                : (invincible ? Colors.orange : Colors.white), 
            width: isDead ? 3 : (invincible ? 3 : 2),
          ),*/

          boxShadow: isDead ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.8),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ] : (invincible ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : []),
        ),
        child: Center(
          child: _buildPlayerGraphic(),
        ),
      ),
    );
  }

  Widget _buildPlayerGraphic() {
    final bool facingLeft = velocityX < 0;

    Widget image = Image.asset(
      'assets/images/player.png',
      width: cellSize * 0.85,
      height: cellSize * 0.85,
      fit: BoxFit.contain,
    );

    if (facingLeft && !isDead) {
      return Transform.scale(
        scaleX: -1.0,
        scaleY: 1.0,
        child: image,
      );
    }

    return image;
  }

  Widget _buildItem(Item item) {
    Color color; String emoji;
    switch (item.type) {
      case ItemType.gloves: color = Colors.purpleAccent; emoji = '🧤'; break;
      case ItemType.helmet: color = Colors.red; emoji = '⛑️'; break;
      case ItemType.extinguisher: color = Colors.red; emoji = '🧯'; break;
      case ItemType.idrante: color = Colors.red.shade700; emoji = '🚒'; break;
    }
    return Positioned(
      left: item.pos.dx * cellSize, top: item.pos.dy * cellSize,
      width: cellSize, height: cellSize,
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.9), shape: BoxShape.circle),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: cellSize * 0.7))),
      ),
    );
  }

  Widget _buildObstacle(Obstacle obs) {
    Color color; String emoji;
    switch (obs.type) {
      case ObstacleType.electricShock: color = Colors.orange; emoji = '⚡'; break;
      case ObstacleType.exposedCable: color = Colors.grey; emoji = '🔌'; break;
      case ObstacleType.electricalPanel: color = Colors.red; emoji = '⚠️'; break;
      case ObstacleType.fire: color = Colors.orange.shade700; emoji = '🔥'; break;
    }

    final obstacleWidget = Container(
      decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle,
        boxShadow: obs.type == ObstacleType.fire ? [
          BoxShadow(
            color: Colors.orange.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: cellSize * 0.7)))
    );

    if (obs.type == ObstacleType.fire) {
      return Positioned(
        left: obs.pos.dx * cellSize,
        top: obs.pos.dy * cellSize,
        width: cellSize,
        height: cellSize,
        child: AnimatedOpacity(
          opacity: (0.7 + (DateTime.now().millisecondsSinceEpoch % 500) / 1000).clamp(0.0, 1.0),
          duration: const Duration(milliseconds: 100),
          child: AnimatedScale(
            scale: (0.95 + (DateTime.now().millisecondsSinceEpoch % 300) / 1000).clamp(0.0, 1.0),
            duration: const Duration(milliseconds: 80),
            child: obstacleWidget,
          ),
        ),
      );
    }

    return Positioned(
      left: obs.pos.dx * cellSize, top: obs.pos.dy * cellSize,
      width: cellSize, height: cellSize,
      child: obstacleWidget,
    );
  }

  Widget _buildExit(Exit exit) {
    return Positioned(
      left: exit.pos.dx * cellSize, top: exit.pos.dy * cellSize,
      width: cellSize, height: cellSize,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white, width: 2)),
        child: Center(child: Text('🚪', style: TextStyle(fontSize: cellSize * 0.8))),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 16, left: 16, right: 16,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.home, color: Colors.cyan, size: 28), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Text('LV.$level', style: const TextStyle(color: Colors.cyan, fontSize: 16)),
          const SizedBox(width: 24),
          
          Row(children: [
            const Icon(Icons.flash_on, color: Colors.orange, size: 16), 
            const SizedBox(width: 4), 
            Text('$score', style: const TextStyle(color: Colors.white, fontSize: 16))
          ]),
          
          if (extinguisherCount > 0) ...[
            const SizedBox(width: 16),
            Row(children: [
              const Text('🧯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('x$extinguisherCount', style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
          ],
          
          if (bestScoreForCurrentLevel != null && score > bestScoreForCurrentLevel!) ...[
            const SizedBox(width: 8),
            Text(
              '🔥 NEW!',
              style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
          
          const Spacer(),
          IconButton(icon: const Icon(Icons.pause, color: Colors.cyan, size: 28), onPressed: () => setState(() => isPaused = true)),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _touchButton(Icons.arrow_back_ios, _onLeftDown, _onLeftUp),
              const SizedBox(width: 6),
              _touchButton(Icons.arrow_forward_ios, _onRightDown, _onRightUp),
            ],
          ),
          
          _touchButton(Icons.play_arrow, _onJump, null, label: 'SALTA', isJump: true),
        ],
      ),
    );
  }

  Widget _touchButton(IconData icon, VoidCallback onDown, VoidCallback? onUp, {String? label, bool isJump = false}) {
    final isPressed = isJump 
        ? jumpPressed 
        : (icon == Icons.arrow_back_ios ? leftPressed : rightPressed);
    
    final buttonSize = isJump ? 72.0 : 60.0;
    final iconSize = isJump ? 28.0 : 24.0;
    
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp?.call(),
      onTapCancel: () => onUp?.call(),
      onLongPressStart: (_) => onDown(),
      onLongPressEnd: (_) => onUp?.call(),
      onLongPressCancel: () => onUp?.call(),
      onPanStart: (_) => onDown(),
      onPanEnd: (_) => onUp?.call(),
      onPanCancel: () => onUp?.call(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isPressed)
              Container(
                width: buttonSize + 8,
                height: buttonSize + 8,
                decoration: BoxDecoration(
                  shape: isJump ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isJump ? null : BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isJump ? Colors.orange : Colors.cyan).withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                shape: isJump ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isJump ? null : BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.cyan,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                  if (label != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (isPressed)
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: isJump ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isJump ? null : BorderRadius.circular(12),
                ),
              ),
            
            if (!isJump)
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: buttonSize - 4,
                height: buttonSize - 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.cyan.withOpacity(
                      0.3 + 0.2 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000,
                    ),
                    width: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pauseButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          color: const Color(0xFF0A192F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.cyan, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled,
                  size: 48,
                  color: Colors.cyan[400],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'PAUSA',
                  style: TextStyle(
                    color: Colors.cyan[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Punteggio: $score',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                
                _pauseButton('RIPRENDI', Colors.cyan, () {
                  setState(() => isPaused = false);
                }),
                const SizedBox(height: 12),
                
                _pauseButton('RICOMINCIA', Colors.amber, () {
                  setState(() {
                    isPaused = false;
                    lives = 1;
                    score = levelStartScore;
                    extinguisherCount = 0;
                    leftPressed = false;
                    rightPressed = false;
                    jumpPressed = false;
                    final startLevel = _allLevels[level - 1];
                    playerX = startLevel.playerStartPos.dx;
                    playerY = startLevel.playerStartPos.dy;
                    velocityX = 0;
                    velocityY = 0;
                    onGround = false;
                    _initLevel();
                  });
                }),
                const SizedBox(height: 12),
                
                _pauseButton('MENÙ', Colors.red, () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildWinOverlay() => Container(color: Colors.black.withOpacity(0.8), child: Center(child: Text('LIVELLO COMPLETATO!', style: TextStyle(color: Colors.cyan, fontSize: 24))));
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E293B).withOpacity(0.3)..strokeWidth = 0.5;
    final step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}