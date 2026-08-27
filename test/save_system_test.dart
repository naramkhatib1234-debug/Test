import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_rush/systems/save_system.dart';
import 'package:stack_rush/systems/skin_catalog.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults are sensible on first run', () async {
    final save = await SaveSystem.load();
    expect(save.bestScore, 0);
    expect(save.coins, 0);
    expect(save.selectedSkinId, SkinCatalog.defaultSkinId);
    expect(save.unlockedSkinIds, [SkinCatalog.defaultSkinId]);
    expect(save.soundOn, isTrue);
    expect(save.musicOn, isTrue);
  });

  test('submitScore only updates best score when beaten', () async {
    final save = await SaveSystem.load();
    expect(await save.submitScore(10), isTrue);
    expect(save.bestScore, 10);
    expect(await save.submitScore(5), isFalse);
    expect(save.bestScore, 10);
    expect(await save.submitScore(20), isTrue);
    expect(save.bestScore, 20);
  });

  test('coins accumulate and cannot go negative', () async {
    final save = await SaveSystem.load();
    await save.addCoins(50);
    expect(save.coins, 50);
    expect(await save.spendCoins(30), isTrue);
    expect(save.coins, 20);
    expect(await save.spendCoins(100), isFalse);
    expect(save.coins, 20);
  });

  test('skins unlock and persist selection', () async {
    final save = await SaveSystem.load();
    expect(save.isSkinUnlocked('neon'), isFalse);
    await save.unlockSkin('neon');
    expect(save.isSkinUnlocked('neon'), isTrue);
    await save.selectSkin('neon');
    expect(save.selectedSkinId, 'neon');
  });
}
