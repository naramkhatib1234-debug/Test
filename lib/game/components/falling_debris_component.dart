import 'package:flame/components.dart';

import 'block_component.dart';

/// The sliced-off piece of a block that didn't overlap the tower. Purely
/// decorative: falls away under simple gravity and removes itself.
class FallingDebrisComponent extends BlockComponent {
  FallingDebrisComponent({
    required super.position,
    required super.size,
    required super.colors,
    required double horizontalDirection,
  })  : _velocity = Vector2(horizontalDirection * 60, -40),
        _life = 0;

  final Vector2 _velocity;
  double _life;

  static const double _gravity = 900;
  static const double _maxLife = 1.4;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    _velocity.y += _gravity * dt;
    position += _velocity * dt;
    angle += dt * (_velocity.x.sign == 0 ? 1 : _velocity.x.sign) * 3;

    if (_life >= _maxLife) {
      removeFromParent();
    }
  }
}
