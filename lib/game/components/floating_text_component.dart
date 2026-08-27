import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart';

/// Small piece of text (e.g. "+10", "PERFECT!") that floats upward and
/// fades out, then removes itself. Purely decorative, world-space.
class FloatingTextComponent extends TextComponent {
  FloatingTextComponent({
    required String text,
    required Vector2 position,
    required Color color,
    double fontSize = 18,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Color(0x66000000), blurRadius: 4),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      MoveByEffect(
        Vector2(0, -40),
        EffectController(duration: 0.9, curve: Curves.easeOut),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.9, startDelay: 0.15),
        onComplete: removeFromParent,
      ),
    );
  }
}
