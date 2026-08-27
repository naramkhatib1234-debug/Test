# Stack Rush

A polished portrait mobile game built with Flutter + Flame. Drop moving blocks to build the
tallest tower possible: tap anywhere to drop, align perfectly for bonus score and coins, and
unlock new skins as you play.

## Status

Complete and playable. Implemented:

- Core gameplay: moving block, tap-to-drop, overlap/collision resolution, tower building,
  progressively increasing difficulty, game over + restart.
- Perfect-placement system: "PERFECT!" popup, particle burst, screen shake, combo multiplier,
  bonus score, sound effect.
- Coins (earned by stacking, perfects, and score milestones) and a 7-skin unlock system
  (Classic, Neon, Candy, Galaxy, Fire, Ocean, Rainbow), no real-money purchases.
- Main menu, in-game HUD, game over screen, skins screen, settings screen (sound/music toggles).
- Local persistence (best score, coins, selected/unlocked skins, sound/music settings) via
  `shared_preferences` — progress survives closing the app.
- Portrait-only, safe-area aware, dynamic background that shifts theme as the tower climbs.
- `flutter analyze` clean and `flutter test` passing (unit tests for difficulty/save systems,
  widget smoke tests for app boot and navigation).

## Known environment limitation

This was built in a container without the Android SDK, and the SDK installer domain
(`dl.google.com`) is blocked by the sandbox's egress policy, so the APK itself could not be
built here. The Flutter project is otherwise complete and ready to build. On a machine with
Flutter + Android SDK installed:

```
flutter pub get
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Project layout

```
lib/
├── main.dart          # App entry point, bootstraps save/audio systems
├── game/              # Flame game engine: StackRushGame + components
├── screens/           # Main menu, game screen, skins, settings, game over
├── systems/           # Persistence, audio, skin catalog, difficulty curve
├── models/            # Skin and GameResult data classes
└── widgets/           # Shared UI widgets (buttons, stat chips)
```

## Development

```
flutter pub get
flutter analyze
flutter test
flutter build apk --release   # requires Android SDK
```
