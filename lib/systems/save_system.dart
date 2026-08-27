import 'package:shared_preferences/shared_preferences.dart';

import 'skin_catalog.dart';

/// Wraps [SharedPreferences] to persist all game progress locally.
///
/// A single instance is created once at app start and shared across
/// screens/game logic so every read reflects the latest saved state.
class SaveSystem {
  SaveSystem._(this._prefs);

  static const _keyBestScore = 'best_score';
  static const _keyCoins = 'coins';
  static const _keySelectedSkin = 'selected_skin';
  static const _keyUnlockedSkins = 'unlocked_skins';
  static const _keySoundOn = 'sound_on';
  static const _keyMusicOn = 'music_on';

  final SharedPreferences _prefs;

  static Future<SaveSystem> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SaveSystem._(prefs);
  }

  int get bestScore => _prefs.getInt(_keyBestScore) ?? 0;

  /// Returns true if [score] beat the previous best.
  Future<bool> submitScore(int score) async {
    if (score > bestScore) {
      await _prefs.setInt(_keyBestScore, score);
      return true;
    }
    return false;
  }

  int get coins => _prefs.getInt(_keyCoins) ?? 0;

  Future<void> addCoins(int amount) async {
    if (amount == 0) return;
    await _prefs.setInt(_keyCoins, coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _prefs.setInt(_keyCoins, coins - amount);
    return true;
  }

  String get selectedSkinId =>
      _prefs.getString(_keySelectedSkin) ?? SkinCatalog.defaultSkinId;

  Future<void> selectSkin(String id) async {
    await _prefs.setString(_keySelectedSkin, id);
  }

  List<String> get unlockedSkinIds {
    return _prefs.getStringList(_keyUnlockedSkins) ??
        <String>[SkinCatalog.defaultSkinId];
  }

  bool isSkinUnlocked(String id) => unlockedSkinIds.contains(id);

  Future<void> unlockSkin(String id) async {
    final current = unlockedSkinIds;
    if (current.contains(id)) return;
    await _prefs.setStringList(_keyUnlockedSkins, [...current, id]);
  }

  bool get soundOn => _prefs.getBool(_keySoundOn) ?? true;

  Future<void> setSoundOn(bool value) async {
    await _prefs.setBool(_keySoundOn, value);
  }

  bool get musicOn => _prefs.getBool(_keyMusicOn) ?? true;

  Future<void> setMusicOn(bool value) async {
    await _prefs.setBool(_keyMusicOn, value);
  }
}
