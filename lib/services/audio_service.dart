import 'package:audioplayers/audioplayers.dart';

/// Plays short sound effects for game events.
///
/// Falls back silently if audio files are missing — the game
/// still works without assets during early development.
class AudioService {
  final AudioPlayer _flapPlayer = AudioPlayer();
  final AudioPlayer _scorePlayer = AudioPlayer();
  final AudioPlayer _hitPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool enabled = true;
  bool isBgmMuted = false;

  Future<void> playFlap() => _play(_flapPlayer, 'sounds/jump.mp3');
  Future<void> playScore() => _play(_scorePlayer, 'sounds/pass.mp3');
  Future<void> playHit() => _play(_hitPlayer, 'sounds/crash.mp3');
  Future<void> playLife() => _play(_hitPlayer, 'sounds/life.mp3');
  Future<void> playSpell() => _play(_hitPlayer, 'sounds/spell.mp3');

  Future<void> startBgm() async {
    if (!enabled || isBgmMuted) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (!enabled || isBgmMuted) return;
    await _bgmPlayer.resume();
  }

  Future<void> _play(AudioPlayer player, String asset) async {
    if (!enabled) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Silently ignore — sound assets may not exist yet.
    }
  }

  void dispose() {
    _flapPlayer.dispose();
    _scorePlayer.dispose();
    _hitPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
