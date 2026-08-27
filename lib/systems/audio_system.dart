import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'save_system.dart';

/// Centralizes sound-effect and music playback, respecting the user's
/// saved sound/music toggles from [SaveSystem].
///
/// Playback failures (e.g. no audio plugin available on the current
/// platform, as in widget tests) are swallowed so they never interrupt
/// gameplay.
class AudioSystem {
  AudioSystem(this._save);

  final SaveSystem _save;
  bool _musicStarted = false;

  static const _sfxFiles = [
    'place.wav',
    'perfect.wav',
    'combo.wav',
    'gameover.wav',
  ];

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([..._sfxFiles, 'music_loop.wav']);
    } catch (e) {
      debugPrint('AudioSystem.preload failed: $e');
    }
  }

  void playPlace() => _playSfx('place.wav', 0.6);

  void playPerfect() => _playSfx('perfect.wav', 0.8);

  void playCombo() => _playSfx('combo.wav', 0.5);

  void playGameOver() => _playSfx('gameover.wav', 0.7);

  void _playSfx(String file, double volume) {
    if (!_save.soundOn) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (e) {
      debugPrint('AudioSystem.play($file) failed: $e');
    }
  }

  Future<void> startMusic() async {
    if (!_save.musicOn) return;
    try {
      _musicStarted = true;
      await FlameAudio.bgm.play('music_loop.wav', volume: 0.35);
    } catch (e) {
      debugPrint('AudioSystem.startMusic failed: $e');
    }
  }

  Future<void> stopMusic() async {
    _musicStarted = false;
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('AudioSystem.stopMusic failed: $e');
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _save.setMusicOn(enabled);
    if (enabled) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  void setSoundEnabled(bool enabled) {
    _save.setSoundOn(enabled);
  }

  bool get isMusicRunning => _musicStarted;
}
