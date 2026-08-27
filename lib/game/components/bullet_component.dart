import 'dart:ui';

import 'package:flame/components.dart';

/// A player-fired bullet travelling straight up.
class BulletComponent extends PositionComponent {
  BulletComponent({
    required Vector2 position,
    required this.color,
    this.speed = 620,
    this.damage = 1,
  }) : super(position: position, size: Vector2(6, 18), anchor: Anchor.center);

  final Color color;
  final double speed;
  final int damage;

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;
    if (position.y < -size.y) {
      removeFromParent();
    }
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
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(size.x)),
      glow,
    );
  }
}
