import 'dart:ui';

import 'package:flame/components.dart';

/// A bullet fired by a shooting enemy, travelling straight down.
class EnemyBulletComponent extends PositionComponent {
  EnemyBulletComponent({
    required Vector2 position,
    this.speed = 260,
  }) : super(position: position, size: Vector2(7, 16), anchor: Anchor.center);

  final double speed;
  static const Color color = Color(0xFFFF5A7A);

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.x / 2)),
      paint,
    );
    final glow = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(size.x)),
      glow,
    );
  }
}
