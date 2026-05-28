import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService extends ChangeNotifier {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _altPlayer = AudioPlayer();
  bool _muted = false;
  double _volume = 0.7;
  bool _initialized = false;

  bool get isMuted => _muted;
  double get volume => _volume;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('sound_muted') ?? false;
    _volume = prefs.getDouble('sound_volume') ?? 0.7;
    notifyListeners();
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', value);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', _volume);
  }

  Future<void> play(String asset) async {
    if (_muted) return;
    try {
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('[SoundService] play $asset error: $e');
    }
  }

  Future<void> playOverlapping(String asset) async {
    if (_muted) return;
    try {
      await _altPlayer.setVolume(_volume);
      await _altPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('[SoundService] playOverlapping $asset error: $e');
    }
  }

  Future<void> playClick() => play('sounds/click.wav');
  Future<void> playCorrect() => play('sounds/correct.wav');
  Future<void> playWrong() => play('sounds/wrong.wav');
  Future<void> playReward() => play('sounds/reward.wav');
  Future<void> playLevelUp() => playOverlapping('sounds/level_up.wav');
  Future<void> playNotification() => playOverlapping('sounds/notification.wav');
  Future<void> playGameOver() => play('sounds/game_over.wav');

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _altPlayer.dispose();
    super.dispose();
  }
}

final soundProvider = ChangeNotifierProvider<SoundService>((ref) {
  final service = SoundService();
  service.init();
  ref.keepAlive();
  ref.onDispose(() => service.dispose());
  return service;
});
