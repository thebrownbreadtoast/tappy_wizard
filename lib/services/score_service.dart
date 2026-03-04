import 'package:shared_preferences/shared_preferences.dart';

/// Tracks current score and persists the all-time high score.
class ScoreService {
  static const _highScoreKey = 'high_score';

  int _score = 0;
  int _highScore = 0;
  SharedPreferences? _prefs;

  int get score => _score;
  int get highScore => _highScore;
  bool get isNewHighScore => _score > _highScore;

  /// Call once at app startup to load the stored high score.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs?.getInt(_highScoreKey) ?? 0;
  }

  void increment() {
    _score++;
  }

  /// Saves the high score if the current score beats it.
  Future<void> saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      await _prefs?.setInt(_highScoreKey, _highScore);
    }
  }

  void resetScore() {
    _score = 0;
  }
}
