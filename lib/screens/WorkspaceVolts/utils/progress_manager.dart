import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager {
  static const String _keyCompletedLevels = 'completed_levels';
  static const String _keyMaxUnlockedLevel = 'max_unlocked_level';
  static const String _keyPrefixScores = 'score_level_';
  static const String _keyTotalScore = 'total_score';
  static const String _keyPrefixCollected = 'collected_level_';

  // Carica i livelli completati (insieme di numeri)
  static Future<Set<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? completed = prefs.getStringList(_keyCompletedLevels);
    return completed?.map(int.parse).toSet() ?? {};
  }

  // Salva un livello come completato
  static Future<void> markLevelCompleted(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedLevels();
    completed.add(level);
    await prefs.setStringList(
      _keyCompletedLevels,
      completed.map((l) => l.toString()).toList(),
    );
    
    // Sblocca il livello successivo se esiste
    final maxUnlocked = prefs.getInt(_keyMaxUnlockedLevel) ?? 1;
    if (level == maxUnlocked && level < 100) {
      await prefs.setInt(_keyMaxUnlockedLevel, level + 1);
    }
  }

  // Controlla se un livello è sbloccato (1 è sempre sbloccato, altrimenti deve essere ≤ max_unlocked)
  static Future<bool> isLevelUnlocked(int level) async {
    if (level == 1) return true;
    final prefs = await SharedPreferences.getInstance();
    final maxUnlocked = prefs.getInt(_keyMaxUnlockedLevel) ?? 1;
    return level <= maxUnlocked;
  }

  static Future<bool> saveLevelScore(int level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefixScores$level';
    final currentBest = prefs.getInt(key) ?? 0;
    
    if (score > currentBest) {
      await prefs.setInt(key, score);
      return true; // Nuovo record!
    }
    return false; // Punteggio non migliore
  }

  static Future<int> getLevelBestScore(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefixScores$level') ?? 0;
  }

  static Future<Map<int, int>> getAllBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = <int, int>{};
    
    // Cerca tutte le chiavi che iniziano con il prefix
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_keyPrefixScores)) {
        final level = int.tryParse(key.replaceFirst(_keyPrefixScores, ''));
        final score = prefs.getInt(key);
        if (level != null && score != null) {
          scores[level] = score;
        }
      }
    }
    return scores;
  }

  // Salva il punteggio totale globale
  static Future<void> saveTotalScore(int totalScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalScore, totalScore);
  }

  // Carica il punteggio totale globale
  static Future<int> loadTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalScore) ?? 0;
  }

  // Salva i punti raccolti in un livello specifico
  static Future<void> saveCollectedPoints(int level, int collected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefixCollected$level', collected);
  }

  // Carica i punti raccolti in un livello specifico
  static Future<int> getCollectedPoints(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefixCollected$level') ?? 0;
  }

  // Resetta tutto
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletedLevels);
    await prefs.remove(_keyMaxUnlockedLevel);
    await prefs.remove(_keyTotalScore);

    for (final key in prefs.getKeys()) {
      if (key.startsWith(_keyPrefixScores) || key.startsWith(_keyPrefixCollected)) {
        await prefs.remove(key);
      }
    }
  }
}