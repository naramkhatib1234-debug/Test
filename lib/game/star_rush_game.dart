import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../models/game_result.dart';
import '../systems/audio_system.dart';
import '../systems/difficulty_system.dart';
import '../systems/save_system.dart';
import 'components/bullet_component.dart';
import 'components/enemy_bullet_component.dart';
import 'components/enemy_component.dart';
import 'components/explosion_burst.dart';
import 'components/floating_text_component.dart';
import 'components/player_ship_component.dart';
import 'components/starfield_background_component.dart';

enum RunState { playing, gameOver }

/// STAR RUSH: drag to move, hold anywhere to fire. Survive descending
/// waves of enemies, chain kills for combo bonuses, and rack up score and
/// coins.
class StarRushGame extends FlameGame with DragCallbacks {
  StarRushGame({
    required this.shipColors,
    required this.audio,
    required this.saveSystem,
    required this.onGameOver,
  });

  final List<Color> shipColors;
  final AudioSystem audio;
  final SaveSystem saveSystem;
  final void Function(GameResult result) onGameOver;

  static const double _fireInterval = 0.22;
  static const double _comboWindow = 1.1;
  static const double _playerBottomMargin = 90;

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> combo = ValueNotifier(0);
  final ValueNotifier<int> coinsThisRun = ValueNotifier(0);
  final ValueNotifier<int> health = ValueNotifier(3);
  final ValueNotifier<RunState> runState = ValueNotifier(RunState.playing);

  late final StarfieldBackgroundComponent background;
  late final PlayerShipComponent player;

  bool _isFiring = false;
  double _fireCooldown = 0;
  double _spawnCooldown = 1.0;
  double _comboTimer = 0;
  int _lastCoinMilestone = 0;

  double _shakeTime = 0;
  double _shakeDuration = 0.01;
  double _shakeMagnitude = 0;
  final Random _random = Random();

  static const Map<EnemyKind, List<Color>> _enemyPalette = {
    EnemyKind.basic: [Color(0xFFFF6B6B), Color(0xFFB4223A)],
    EnemyKind.zigzag: [Color(0xFFC24BFF), Color(0xFF6A1B9A)],
    EnemyKind.tank: [Color(0xFFFFA24B), Color(0xFFB1560B)],
  };

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    background = StarfieldBackgroundComponent(size: size.clone());
    world.add(background);

    player = PlayerShipComponent(
      position: Vector2(size.x / 2, size.y - _playerBottomMargin),
      size: Vector2(52, 62),
      colors: shipColors,
    );
    world.add(player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.visibleGameSize = size.clone();
    if (isLoaded) {
      background.resize(size.clone());
      final halfWidth = player.size.x / 2;
      player.position.x =
          player.position.x.clamp(halfWidth, size.x - halfWidth).toDouble();
      player.position.y = size.y - _playerBottomMargin;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isFiring = true;
    _movePlayerTo(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _movePlayerTo(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isFiring = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isFiring = false;
  }

  void _movePlayerTo(Vector2 canvasPosition) {
    if (runState.value != RunState.playing) return;
    final halfWidth = player.size.x / 2;
    player.position.x = canvasPosition.x.clamp(halfWidth, size.x - halfWidth).toDouble();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (runState.value != RunState.playing) return;

    background.updateScore(score.value);

    _fireCooldown -= dt;
    if (_isFiring && _fireCooldown <= 0) {
      _fireCooldown = _fireInterval;
      _fireBullet();
    }

    _spawnCooldown -= dt;
    if (_spawnCooldown <= 0) {
      _spawnEnemy();
      _spawnCooldown = DifficultySystem.spawnIntervalFor(score.value);
    }

    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) combo.value = 0;
    }

    _handleCollisions();
    _updateShake(dt);
  }

  void _fireBullet() {
    world.add(
      BulletComponent(
        position: player.position - Vector2(0, player.size.y / 2),
        color: shipColors.last,
      ),
    );
    audio.playShoot();
  }

  void _spawnEnemy() {
    final s = score.value;
    EnemyKind kind = EnemyKind.basic;
    if (DifficultySystem.useTankEnemies(s) && _random.nextDouble() < 0.18) {
      kind = EnemyKind.tank;
    } else if (DifficultySystem.useZigzagEnemies(s) && _random.nextDouble() < 0.4) {
      kind = EnemyKind.zigzag;
    }

    final canShoot = DifficultySystem.useShootingEnemies(s) && _random.nextDouble() < 0.35;
    final baseSpeed = DifficultySystem.enemySpeedFor(s);
    final speed = kind == EnemyKind.tank ? baseSpeed * 0.65 : baseSpeed;

    final margin = 30.0;
    final x = margin + _random.nextDouble() * (size.x - margin * 2);

    final (scoreValue, coinValue) = switch (kind) {
      EnemyKind.basic => (10, 1),
      EnemyKind.zigzag => (16, 2),
      EnemyKind.tank => (32, 3),
    };

    world.add(
      EnemyComponent(
        position: Vector2(x, -30),
        kind: kind,
        speed: speed,
        colors: _enemyPalette[kind]!,
        scoreValue: scoreValue,
        coinValue: coinValue,
        canShoot: canShoot,
        onShoot: (pos) {
          world.add(EnemyBulletComponent(position: pos + Vector2(0, 22)));
        },
      ),
    );
  }

  void _handleCollisions() {
    final bullets = world.children.whereType<BulletComponent>().toList();
    final enemies = world.children.whereType<EnemyComponent>().toList();
    final enemyBullets = world.children.whereType<EnemyBulletComponent>().toList();

    for (final bullet in bullets) {
      if (!bullet.isMounted) continue;
      for (final enemy in enemies) {
        if (!enemy.isMounted) continue;
        final hitRadius = enemy.size.x / 2 + bullet.size.x / 2;
        if ((bullet.position - enemy.position).length < hitRadius) {
          bullet.removeFromParent();
          if (enemy.takeDamage(bullet.damage)) {
            _onEnemyKilled(enemy);
          }
          break;
        }
      }
    }

    for (final enemy in enemies) {
      if (!enemy.isMounted) continue;
      if (enemy.position.y - enemy.size.y / 2 > size.y) {
        enemy.removeFromParent();
        continue;
      }
      final hitRadius = (enemy.size.x / 2 + player.size.x / 2) * 0.65;
      if ((enemy.position - player.position).length < hitRadius) {
        enemy.removeFromParent();
        world.add(buildExplosion(position: enemy.position.clone(), colors: enemy.colors));
        _damagePlayer();
      }
    }

    for (final eb in enemyBullets) {
      if (!eb.isMounted) continue;
      if (eb.position.y - eb.size.y / 2 > size.y) {
        eb.removeFromParent();
        continue;
      }
      final hitRadius = (player.size.x / 2 + eb.size.x / 2) * 0.65;
      if ((eb.position - player.position).length < hitRadius) {
        eb.removeFromParent();
        _damagePlayer();
      }
    }
  }

  void _onEnemyKilled(EnemyComponent enemy) {
    enemy.removeFromParent();
    world.add(buildExplosion(position: enemy.position.clone(), colors: enemy.colors));
    audio.playExplosion();

    combo.value = _comboTimer > 0 ? combo.value + 1 : 1;
    _comboTimer = _comboWindow;

    final comboBonus = (combo.value - 1) * 2;
    final points = enemy.scoreValue + comboBonus;
    score.value += points;

    var coinsEarned = enemy.coinValue;
    if (combo.value > 2) coinsEarned += 1;

    final milestone = (score.value / 100).floor();
    if (milestone > _lastCoinMilestone) {
      coinsEarned += 10 * (milestone - _lastCoinMilestone);
      _lastCoinMilestone = milestone;
    }
    coinsThisRun.value += coinsEarned;

    world.add(
      FloatingTextComponent(
        text: '+$points',
        position: enemy.position + Vector2(0, -8),
        color: const Color(0xFFFFFFFF),
      ),
    );
    if (combo.value > 1) {
      audio.playCombo();
      world.add(
        FloatingTextComponent(
          text: 'x${combo.value} COMBO',
          position: enemy.position + Vector2(0, -26),
          color: const Color(0xFFFFC24B),
          fontSize: 16,
        ),
      );
    }
  }

  void _damagePlayer() {
    final tookDamage = player.takeHit();
    if (!tookDamage) return;

    audio.playHit();
    _triggerShake(magnitude: 6, duration: 0.28);
    combo.value = 0;
    _comboTimer = 0;
    health.value = player.health;

    if (player.health <= 0) {
      _endGame();
    }
  }

  void _updateShake(double dt) {
    double shakeX = 0;
    double shakeY = 0;
    if (_shakeTime > 0) {
      _shakeTime = max(0, _shakeTime - dt);
      final t = _shakeTime / _shakeDuration;
      final mag = _shakeMagnitude * t;
      shakeX = (_random.nextDouble() * 2 - 1) * mag;
      shakeY = (_random.nextDouble() * 2 - 1) * mag;
    }
    camera.viewfinder.position = Vector2(shakeX, shakeY);
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
