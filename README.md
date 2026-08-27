# Star Rush

A polished portrait mobile shooter built with Flutter + Flame. Drag to steer your ship, hold
anywhere to fire, and survive waves of descending enemies for as long as you can.

## Status

Complete and playable — this replaced the previous game in this repo, **Stack Rush** (a
block-stacking tower game), which has been fully removed.

Implemented:

- Core gameplay: drag-to-move + hold-to-fire controls, player bullets, three enemy types
  (basic, zigzag, tougher multi-hit "tank"), enemy return fire, collisions, player health
  (3 lives with brief invulnerability after a hit), game over + restart.
- Progression: enemy spawn rate and speed ramp up with score; zigzag movement, enemy gunfire,
  and tank enemies unlock in sequence as you go further, instead of spiking in difficulty.
- Kill-streak combo system: chaining kills within a short window multiplies bonus score,
  plays a rising sound cue, and a "xN COMBO" popup; getting hit resets the streak.
- Coins (earned per kill, streak bonuses, and score milestones) and a 7-ship skin/unlock
  system (Classic, Neon, Candy, Galaxy, Fire, Ocean, Rainbow), no real-money purchases —
  reused directly from Stack Rush's save/skin systems, just reskinned as ship paint jobs.
- Main menu, in-game HUD (score, combo, lives), game over screen, ship-skins screen, settings
  screen (sound/music toggles).
- Local persistence (best score, coins, selected/unlocked ships, sound/music settings) via
  `shared_preferences` — progress survives closing the app.
- Portrait-only, safe-area aware, scrolling starfield background whose color theme shifts
  deeper into space as your score climbs.
- `flutter analyze` clean and `flutter test` passing (unit tests for the difficulty curve and
  save system, widget smoke tests for app boot and navigation).

## Known environment limitation

This was built in a container without the Android SDK, and the SDK installer domain
(`dl.google.com`) is blocked by the sandbox's egress policy, so the APK itself could not be
built here directly. Instead, `.github/workflows/build-apk.yml` builds it on GitHub Actions
(which has full Android tooling) on every push, and publishes per-architecture APKs to a
rolling `latest-apk` GitHub release. On a machine with Flutter + Android SDK installed you can
also build it yourself:

```
flutter pub get
flutter build apk --release --split-per-abi
```

The output APKs land in `build/app/outputs/flutter-apk/` — `app-arm64-v8a-release.apk` is the
one virtually all modern phones need.

## Project layout

```
lib/
├── main.dart          # App entry point, bootstraps save/audio systems
├── game/              # Flame game engine: StarRushGame + components
├── screens/           # Main menu, game screen, ship skins, settings, game over
├── systems/           # Persistence, audio, skin catalog, difficulty curve
├── models/            # Skin and GameResult data classes
└── widgets/           # Shared UI widgets (buttons, stat chips)
```

## Development

```
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi   # requires Android SDK
```
