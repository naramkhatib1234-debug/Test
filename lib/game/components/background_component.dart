import 'dart:ui';

import 'package:flame/components.dart';

/// Full-viewport gradient backdrop that smoothly shifts through a set of
/// themes as the tower grows taller, giving a sense of climbing higher.
class BackgroundComponent extends PositionComponent
    with HasGameReference {
  BackgroundComponent({required Vector2 size})
      : super(size: size, position: Vector2.zero(), priority: -10);

  static const List<List<Color>> _themes = [
    [Color(0xFF8FD3F4), Color(0xFFA1C4FD)], // day sky
    [Color(0xFFFBC2EB), Color(0xFFA6C1EE)], // sunrise pastel
    [Color(0xFFFF9A9E), Color(0xFFFAD0C4)], // sunset
    [Color(0xFF667EEA), Color(0xFF764BA2)], // dusk violet
    [Color(0xFF1E3C72), Color(0xFF2A5298)], // twilight blue
    [Color(0xFF0F2027), Color(0xFF203A43)], // night
    [Color(0xFF200122), Color(0xFF6F0000)], // aurora / high altitude
  ];

  double _progress = 0;

  /// 0.0 = ground level, increases roughly one full theme step per
  /// [themeStepBlocks] blocks placed.
  static const double themeStepBlocks = 8;

  void updateHeight(int blocksPlaced) {
    _progress = blocksPlaced / themeStepBlocks;
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
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(0, 0),
        Offset(0, size.y),
        [top, bottom],
      );
    canvas.drawRect(rect, paint);
  }

  void resize(Vector2 newSize) {
    size = newSize;
  }
}
