import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

/// A single settled layer of the tower. Also the base class for the
/// currently-moving block and for cut-off debris pieces.
class BlockComponent extends PositionComponent {
  BlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.colors,
    this.cornerRadius = 6,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  List<Color> colors;
  final double cornerRadius;

  late final Paint _shadowPaint = Paint()
    ..color = const Color(0x33000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      _shadowPaint,
    );

    final gradient = Paint()
      ..shader = (colors.length == 1
          ? null
          : Gradient.linear(
              Offset.zero,
              Offset(size.x, size.y),
              colors,
            ))
      ..color = colors.first;
    canvas.drawRRect(rrect, gradient);

    // Subtle top highlight for a glossy, polished look.
    final highlight = Paint()..color = const Color(0x33FFFFFF);
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, size.y * 0.35),
      Radius.circular(cornerRadius * 0.7),
    );
    canvas.drawRRect(highlightRect, highlight);
  }

  /// Quick squash-and-settle juice played when the block lands.
  void playLandBounce() {
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2(1.08, 0.82),
          EffectController(duration: 0.06, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2(1.0, 1.0),
          EffectController(duration: 0.14, curve: Curves.elasticOut),
        ),
      ]),
    );
  }
}
