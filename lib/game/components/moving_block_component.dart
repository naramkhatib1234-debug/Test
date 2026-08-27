import 'dart:ui';

import 'block_component.dart';

/// The active block the player is aiming, sliding back and forth above
/// the tower until the player taps to drop it.
class MovingBlockComponent extends BlockComponent {
  MovingBlockComponent({
    required super.position,
    required super.size,
    required super.colors,
    required this.minX,
    required this.maxX,
    required this.speed,
    bool startGoingRight = true,
  })  : _direction = startGoingRight ? 1 : -1;

  final double minX;
  final double maxX;
  double speed;

  double _direction;
  bool dropping = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (dropping) return;

    position.x += _direction * speed * dt;

    if (position.x <= minX) {
      position.x = minX;
      _direction = 1;
    } else if (position.x + size.x >= maxX) {
      position.x = maxX - size.x;
      _direction = -1;
    }
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
