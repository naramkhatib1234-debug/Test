import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';

import '../models/game_result.dart';
import '../systems/audio_system.dart';
import '../systems/difficulty_system.dart';
import '../systems/save_system.dart';
import 'components/background_component.dart';
import 'components/block_component.dart';
import 'components/falling_debris_component.dart';
import 'components/floating_text_component.dart';
import 'components/moving_block_component.dart';
import 'components/particle_burst.dart';

enum RunState { playing, gameOver }

/// The full STACK RUSH game: spawns moving blocks, resolves drops against
/// the tower, tracks score/combo/coins and drives the camera + background.
class StackRushGame extends FlameGame with TapCallbacks {
  StackRushGame({
    required this._skinColors,
    required this.audio,
    required this.saveSystem,
    required this.onGameOver,
  });

  List<Color> _skinColors;
  final AudioSystem audio;
  final SaveSystem saveSystem;
  final void Function(GameResult result) onGameOver;

  static const double worldWidth = 360;
  static const double blockHeight = 42;
  static const double initialBlockWidth = 220;
  static const double hoverGap = 90;
  static const double perfectTolerance = 5;
  static const double minSurvivableWidth = 14;
  static const double _groundBottomMargin = blockHeight * 3;
  static const double _cameraMarginTop = hoverGap + blockHeight * 1.5;

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> combo = ValueNotifier(0);
  final ValueNotifier<int> coinsThisRun = ValueNotifier(0);
  final ValueNotifier<RunState> runState = ValueNotifier(RunState.playing);

  late final BackgroundComponent background;
  MovingBlockComponent? _movingBlock;

  double _currentX = 0;
  double _currentWidth = initialBlockWidth;
  double _topY = 0;
  int _blocksPlaced = 0;

  double _visibleWorldHeight = 640;
  double _cameraStartY = -640;
  double _cameraCurrentY = -640;
  bool _cameraInitialized = false;

  double _shakeTime = 0;
  double _shakeDuration = 0.01;
  double _shakeMagnitude = 0;
  final Random _rand = Random();

  void updateSkin(List<Color> colors) {
    _skinColors = colors;
  }

  @override
  Future<void> onLoad() async {
    background = BackgroundComponent(size: Vector2(1, 1));
    camera.viewport.add(background);

    camera.viewfinder.anchor = Anchor.topLeft;

    _currentX = (worldWidth - initialBlockWidth) / 2;
    _currentWidth = initialBlockWidth;
    _topY = 0;

    final ground = BlockComponent(
      position: Vector2(_currentX, 0),
      size: Vector2(_currentWidth, blockHeight),
      colors: _skinColors,
    );
    world.add(ground);

    _spawnNextMovingBlock();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0 || size.y <= 0) return;

    final aspect = size.y / size.x;
    _visibleWorldHeight = worldWidth * aspect;
    camera.viewfinder.visibleGameSize = Vector2(worldWidth, _visibleWorldHeight);
    _cameraStartY = -(_visibleWorldHeight - _groundBottomMargin);

    if (!_cameraInitialized) {
      _cameraCurrentY = _cameraStartY;
      _cameraInitialized = true;
    }

    if (isLoaded) {
      background.size = camera.viewport.size.clone();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_cameraInitialized) return;

    final desiredY = min(_cameraStartY, _topY - _cameraMarginTop);
    _cameraCurrentY += (desiredY - _cameraCurrentY) * min(1, dt * 4.5);

    double shakeX = 0;
    double shakeY = 0;
    if (_shakeTime > 0) {
      _shakeTime = max(0, _shakeTime - dt);
      final t = _shakeTime / _shakeDuration;
      final mag = _shakeMagnitude * t;
      shakeX = (_rand.nextDouble() * 2 - 1) * mag;
      shakeY = (_rand.nextDouble() * 2 - 1) * mag;
    }

    camera.viewfinder.position = Vector2(shakeX, _cameraCurrentY + shakeY);
    background.updateHeight(_blocksPlaced);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (runState.value != RunState.playing) return;
    _dropBlock();
  }

  void _spawnNextMovingBlock() {
    final wide = DifficultySystem.useWideSwing(_blocksPlaced);
    final minX = wide ? 0.0 : worldWidth * 0.12;
    final maxX = wide ? worldWidth : worldWidth * 0.88;

    final speed = DifficultySystem.speedFor(_blocksPlaced);
    final startFromLeft = _blocksPlaced.isEven;
    final startX = startFromLeft ? minX : (maxX - _currentWidth).clamp(minX, maxX);

    final block = MovingBlockComponent(
      position: Vector2(startX, _topY - hoverGap - blockHeight),
      size: Vector2(_currentWidth, blockHeight),
      colors: _skinColors,
      minX: minX,
      maxX: maxX,
      speed: speed,
      startGoingRight: startFromLeft,
    );

    _movingBlock = block;
    world.add(block);
  }

  void _dropBlock() {
    final block = _movingBlock;
    if (block == null || block.dropping) return;
    block.dropping = true;

    final landingY = _topY - blockHeight;

    block.add(
      MoveToEffect(
        Vector2(block.position.x, landingY),
        EffectController(duration: 0.11, curve: Curves.easeIn),
        onComplete: () => _resolveLanding(block),
      ),
    );
  }

  void _resolveLanding(MovingBlockComponent block) {
    final movingX = block.position.x;
    final movingWidth = block.size.x;

    final overlapStart = max(_currentX, movingX);
    final overlapEnd = min(_currentX + _currentWidth, movingX + movingWidth);
    final overlapWidth = overlapEnd - overlapStart;

    if (overlapWidth <= 0 || overlapWidth < minSurvivableWidth) {
      _fallOffAndEndGame(block);
      return;
    }

    final misalignment = (movingX - _currentX).abs();
    final isPerfect = misalignment <= perfectTolerance;

    double newX;
    double newWidth;

    if (isPerfect) {
      newX = _currentX;
      newWidth = _currentWidth;
    } else {
      newX = overlapStart;
      newWidth = overlapWidth;

      if (movingX < _currentX) {
        final leftoverWidth = overlapStart - movingX;
        _spawnDebris(
          position: Vector2(movingX, block.position.y),
          size: Vector2(leftoverWidth, blockHeight),
          direction: -1,
        );
      } else if (movingX + movingWidth > _currentX + _currentWidth) {
        final leftoverX = overlapEnd;
        final leftoverWidth = (movingX + movingWidth) - overlapEnd;
        _spawnDebris(
          position: Vector2(leftoverX, block.position.y),
          size: Vector2(leftoverWidth, blockHeight),
          direction: 1,
        );
      }
    }

    block.position.x = newX;
    block.size.x = newWidth;
    block.dropping = false;
    block.playLandBounce();

    _currentX = newX;
    _currentWidth = newWidth;
    _topY = block.position.y;
    _blocksPlaced += 1;
    _movingBlock = null;

    _applyScoring(isPerfect: isPerfect, blockCenter: Vector2(newX + newWidth / 2, _topY));

    _spawnNextMovingBlock();
  }

  void _spawnDebris({
    required Vector2 position,
    required Vector2 size,
    required double direction,
  }) {
    if (size.x <= 0.5) return;
    world.add(
      FallingDebrisComponent(
        position: position,
        size: size,
        colors: _skinColors,
        horizontalDirection: direction,
      ),
    );
  }

  void _applyScoring({required bool isPerfect, required Vector2 blockCenter}) {
    const basePoints = 1;
    int totalPoints = basePoints;
    int coinsEarned = 1;

    if (isPerfect) {
      final bonus = 2 + combo.value;
      totalPoints += bonus;
      combo.value += 1;
      coinsEarned += 3;
      audio.playPerfect();
      if (combo.value > 1) audio.playCombo();
      _triggerShake(magnitude: 3, duration: 0.18);

      world.add(buildPerfectBurst(position: blockCenter, colors: _skinColors));
      world.add(
        FloatingTextComponent(
          text: 'PERFECT!',
          position: blockCenter + Vector2(0, -blockHeight),
          color: const Color(0xFFFFF176),
          fontSize: 20,
        ),
      );
    } else {
      combo.value = 0;
      audio.playPlace();
    }

    if (_blocksPlaced % 10 == 0) {
      coinsEarned += 10;
    }

    world.add(
      FloatingTextComponent(
        text: '+$totalPoints',
        position: blockCenter + Vector2(0, -blockHeight * 0.4),
        color: const Color(0xFFFFFFFF),
      ),
    );

    score.value += totalPoints;
    coinsThisRun.value += coinsEarned;
  }

  void _fallOffAndEndGame(MovingBlockComponent block) {
    block.dropping = false;
    world.add(
      FallingDebrisComponent(
        position: block.position.clone(),
        size: block.size.clone(),
        colors: _skinColors,
        horizontalDirection: block.position.x < _currentX ? -1 : 1,
      ),
    );
    block.removeFromParent();
    _movingBlock = null;
    _triggerShake(magnitude: 6, duration: 0.3);
    _endGame();
  }

  void _triggerShake({required double magnitude, required double duration}) {
    _shakeMagnitude = magnitude;
    _shakeDuration = duration;
    _shakeTime = duration;
  }

  Future<void> _endGame() async {
    if (runState.value == RunState.gameOver) return;
    runState.value = RunState.gameOver;
    audio.playGameOver();

    final finalScore = score.value;
    final isNewBest = await saveSystem.submitScore(finalScore);
    await saveSystem.addCoins(coinsThisRun.value);

    onGameOver(
      GameResult(
        score: finalScore,
        bestScore: saveSystem.bestScore,
        isNewBest: isNewBest,
        coinsEarned: coinsThisRun.value,
      ),
    );
  }
}
