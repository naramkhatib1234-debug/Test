import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class _Star {
  _Star(this.x, this.y, this.size, this.speedFactor, this.opacity);
  double x;
  double y;
  final double size;
  final double speedFactor;
  final double opacity;
}

/// Scrolling starfield backdrop whose color theme gradually shifts deeper
/// into space as the score climbs.
class StarfieldBackgroundComponent extends PositionComponent {
  StarfieldBackgroundComponent({required Vector2 size})
      : super(size: size, position: Vector2.zero(), priority: -10) {
    _spawnStars();
  }

  static const List<List<Color>> _themes = [
    [Color(0xFF0B1240), Color(0xFF1B2A6B)], // near orbit
    [Color(0xFF141138), Color(0xFF3A1B6B)], // deep space
    [Color(0xFF1C0B33), Color(0xFF5A1B5E)], // nebula
    [Color(0xFF1A0620), Color(0xFF7A1E3D)], // red giant field
    [Color(0xFF10041A), Color(0xFF3D0B4A)], // void
  ];

  static const double themeStepScore = 60;

  final List<_Star> _stars = [];
  final Random _random = Random(11);
  double _progress = 0;

  void updateScore(int score) {
    _progress = score / themeStepScore;
  }

  void _spawnStars() {
    _stars.clear();
    final count = (size.x * size.y / 9000).clamp(30, 120).toInt();
    for (var i = 0; i < count; i++) {
      _stars.add(
        _Star(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
          0.6 + _random.nextDouble() * 1.8,
          0.3 + _random.nextDouble() * 1.0,
          0.3 + _random.nextDouble() * 0.7,
        ),
      );
    }
  }

  void resize(Vector2 newSize) {
    size = newSize;
    _spawnStars();
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final star in _stars) {
      star.y += 60 * star.speedFactor * dt;
      if (star.y > size.y) {
        star.y = 0;
        star.x = _random.nextDouble() * size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final maxIndex = _themes.length - 1;
    final clamped = _progress.clamp(0.0, maxIndex.toDouble()).toDouble();
    final lowerIndex = clamped.floor().clamp(0, maxIndex).toInt();
    final upperIndex = (lowerIndex + 1).clamp(0, maxIndex).toInt();
    final t = (clamped - lowerIndex).toDouble();

    final lower = _themes[lowerIndex];
    final upper = _themes[upperIndex];
    final top = Color.lerp(lower[0], upper[0], t)!;
    final bottom = Color.lerp(lower[1], upper[1], t)!;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..shader = Gradient.linear(Offset(0, 0), Offset(0, size.y), [top, bottom]);
    canvas.drawRect(rect, bgPaint);

    for (final star in _stars) {
      final paint = Paint()..color = Color.fromRGBO(255, 255, 255, star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }
}
