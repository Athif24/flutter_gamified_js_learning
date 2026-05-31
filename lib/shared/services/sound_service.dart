import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService extends ChangeNotifier {
  final Set<AudioPlayer> _activePlayers = {};
  bool _muted = false;
  double _volume = 0.7;
  bool _initialized = false;
  final _initCompleter = Completer<void>();

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
    _initCompleter.complete();
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
    await _initCompleter.future;
    if (_muted) return;
    final player = AudioPlayer();
    _activePlayers.add(player);

    // TODO: ganti pola cleanup listener dengan dispose() yang lebih robust — player.dispose() tidak boleh dipanggil dua kali
    unawaited(
      player.onPlayerComplete.first.then((_) {
        _activePlayers.remove(player);
        player.dispose();
      }).catchError((_) {
        _activePlayers.remove(player);
        player.dispose();
      }),
    );

    try {
      await player.setVolume(_volume);
      await player.play(AssetSource(asset));
    } catch (e) {
      _activePlayers.remove(player);
      await player.dispose();
    }
  }

  Future<void> playOverlapping(String asset) => play(asset);

  Future<void> playClick() => play('sounds/click.wav');
  Future<void> playCorrect() => play('sounds/correct.wav');
  Future<void> playWrong() => play('sounds/wrong.wav');
  Future<void> playReward() => play('sounds/reward.wav');
  Future<void> playLevelUp() => playOverlapping('sounds/level_up.wav');
  Future<void> playNotification() => playOverlapping('sounds/notification.wav');
  Future<void> playGameOver() => play('sounds/game_over.wav');

  @override
  void dispose() {
    for (final p in _activePlayers.toList()) {
      p.dispose();
    }
    _activePlayers.clear();
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
