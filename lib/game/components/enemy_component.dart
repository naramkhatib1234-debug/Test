import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

enum EnemyKind { basic, zigzag, tank }

/// A descending enemy. Depending on [kind] it may weave side to side, and
/// depending on [canShoot] it may periodically fire back at the player.
class EnemyComponent extends PositionComponent {
  EnemyComponent({
    required Vector2 position,
    required this.kind,
    required this.speed,
    required this.colors,
    required this.scoreValue,
    required this.coinValue,
    this.canShoot = false,
    this.onShoot,
  })  : maxHealth = kind == EnemyKind.tank ? 3 : 1,
        _baseX = position.x,
        super(
          position: position,
          size: kind == EnemyKind.tank ? Vector2.all(46) : Vector2.all(32),
          anchor: Anchor.center,
        ) {
    health = maxHealth;
  }

  final EnemyKind kind;
  final double speed;
  final List<Color> colors;
  final int scoreValue;
  final int coinValue;
  final bool canShoot;
  final void Function(Vector2 position)? onShoot;

  late int health;
  final int maxHealth;

  double _elapsed = 0;
  final double _baseX;
  double _shootCooldown = 1.2 + Random().nextDouble();

  /// Returns true if this hit destroyed the enemy.
  bool takeDamage(int amount) {
    health -= amount;
    return health <= 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y += speed * dt;

    if (kind == EnemyKind.zigzag) {
      position.x = _baseX + sin(_elapsed * 2.4) * 46;
    }

    if (canShoot) {
      _shootCooldown -= dt;
      if (_shootCooldown <= 0) {
        _shootCooldown = 1.6 + Random().nextDouble() * 0.8;
        onShoot?.call(position.clone());
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final body = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.95, h * 0.5)
      ..lineTo(w * 0.5, h * 0.95)
      ..lineTo(w * 0.05, h * 0.5)
      ..close();

    final paint = Paint()
      ..shader = Gradient.linear(Offset(0, 0), Offset(w, h), colors);
    canvas.drawShadow(body, const Color(0x66000000), 2, false);
    canvas.drawPath(body, paint);

    final core = Paint()..color = const Color(0xCCFFFFFF);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.12, core);

    if (maxHealth > 1) {
      final barBg = Paint()..color = const Color(0x55000000);
      final barFg = Paint()..color = const Color(0xFF6BFF8F);
      final barRect = Rect.fromLTWH(0, -10, w, 4);
      canvas.drawRect(barRect, barBg);
      canvas.drawRect(
        Rect.fromLTWH(0, -10, w * (health / maxHealth), 4),
        barFg,
      );
    }
  }
}
