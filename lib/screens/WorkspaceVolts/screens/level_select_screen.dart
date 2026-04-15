import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/progress_manager.dart';
import 'game_screen.dart';
import '../models/levels.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Set<int> _completedLevels = {};
  int _maxUnlockedLevel = 1;
  Map<int, int> _bestScores = {};
  Map<int, int> _collectedPoints = {};
  bool _loading = true;

  int _totalLevels = 0;
  int _totalScore = 0;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try{
      final completed = await ProgressManager.getCompletedLevels();
      final prefs = await SharedPreferences.getInstance();
      final maxUnlocked = prefs.getInt('max_unlocked_level') ?? 1;
      final scores = await ProgressManager.getAllBestScores();
      final totalScore = await ProgressManager.loadTotalScore();

      final totalLevels = allLevels.length;

      if (totalLevels == 0) {
        throw Exception("allLevels è vuoto! Controlla levels.dart");
      }

      final collected = <int, int>{};
      for (int i = 1; i <= totalLevels; i++) {
        collected[i] = await ProgressManager.getCollectedPoints(i);
      }
      
      if (mounted){
        setState(() {
          _completedLevels = completed;
          _maxUnlockedLevel = maxUnlocked;
          _bestScores = scores;
          _collectedPoints = collected;
          _totalScore = totalScore;
          _totalLevels = totalLevels;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString(); 
        });
      }
    }
    
  }

  /*Future<void> _loadProgress() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final completed = ProgressManager.getCompletedLevels();
      
      final box = GetStorage('safety_game_data');
      final maxUnlocked = box.read<int>('max_unlocked_level') ?? 1;
      
      final scores = ProgressManager.getAllBestScores();
      final totalScore = ProgressManager.loadTotalScore();
      final totalLevels = allLevels.length;

      final collected = <int, int>{};
      for (int i = 1; i <= totalLevels; i++) {
        collected[i] = ProgressManager.getCollectedPoints(i);
      }
      
      if (mounted) {
        setState(() {
          _completedLevels = completed;
          _maxUnlockedLevel = maxUnlocked;
          _bestScores = scores;
          _collectedPoints = collected;
          _totalScore = totalScore;
          _totalLevels = totalLevels;
          _loading = false;
        });
      }
    } catch (e) {
      print("Errore in _loadProgress: $e");
      if (mounted) setState(() => _loading = false);
    }
  }*/

  /*int _getMaxUnlocked() {
    final box = GetStorage('safety_game_data');
    return box.read<int>('max_unlocked_level') ?? 1;
  }*/

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A192F),
        body: Center(child: CircularProgressIndicator(color: Colors.cyan)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A192F),
        body: Center(
          child: Text(
            'Errore nel caricamento dei progressi:\n$_errorMessage',
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SELEZIONA LIVELLO',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'PressStart2P',
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_totalScore',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'Livelli completati: ${_completedLevels.length}',
                    style: const TextStyle(color: Colors.green, fontSize: 11),
                  ),
                  Text(
                    'Sbloccati fino al: $_maxUnlockedLevel',
                    style: const TextStyle(color: Colors.cyan, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _totalLevels > 0
              ? GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _totalLevels,
                itemBuilder: (context, index) {
                  final levelNum = index + 1;
                  final isUnlocked = levelNum <= _maxUnlockedLevel;
                  final isCompleted = _completedLevels.contains(levelNum);
                  final collectedPoints = _collectedPoints[levelNum] ?? 0;
                  final maxPossiblePoints = allLevels[index].maxPossibleScore;
                  
                  return _LevelButton(
                    level: levelNum,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    collectedPoints: collectedPoints,
                    maxPossiblePoints: maxPossiblePoints,
                    onTap: isUnlocked
                        ? () => _startLevel(levelNum)
                        : null,
                  );
                },
              )
              : const Center(
                child: Text(
                  'Nessun livello disponibile',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
            
            // Pulsante reset (solo per debug)
            /*Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () async {
                  await ProgressManager.resetProgress();
                  _loadProgress();
                },
                child: const Text(
                  'Resetta progressi',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  void _startLevel(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(initialLevel: level),
      ),
    ).then((_) {
      _loadProgress();
    });
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCompleted;
  final int collectedPoints;
  final int maxPossiblePoints;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.collectedPoints,
    required this.maxPossiblePoints,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPerfect = isCompleted && collectedPoints >= maxPossiblePoints;
    final displayScore = isCompleted ? collectedPoints : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCompleted ? (isPerfect ? Colors.green[900] : Colors.green[800]) : const Color(0xFF1E3A5F))
              : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked 
                ? (isPerfect ? Colors.amber : (isCompleted ? Colors.green : Colors.cyan)) 
                : Colors.grey,
            width: 2,
          ),
          boxShadow: isUnlocked && !isCompleted
              ? [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPerfect) const Icon(Icons.star, color: Colors.amber, size: 16)
            else if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
            if (isUnlocked)
              Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(Icons.lock, color: Colors.grey, size: 18),
            const SizedBox(height: 6),

            if (isUnlocked)
              Text(
                '$displayScore/$maxPossiblePoints',
                style: TextStyle(
                  color: isPerfect ? Colors.amber : Colors.white70,
                  fontSize: 11,
                  fontWeight: isPerfect ? FontWeight.bold : FontWeight.normal,
                ),
              ),

            if (isPerfect)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'PERFETTO!',
                  style: TextStyle(
                    color: Colors.amber[400],
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}