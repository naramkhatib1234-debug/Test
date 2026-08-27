import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

/// The player's ship. Rendered as a simple triangular fuselage with an
/// engine glow, colored by the selected skin. Tracks health and a brief
/// invulnerability window (with a blink) after taking a hit.
class PlayerShipComponent extends PositionComponent {
  PlayerShipComponent({
    required Vector2 position,
    required Vector2 size,
    required this.colors,
    this.maxHealth = 3,
  })  : health = maxHealth,
        super(position: position, size: size, anchor: Anchor.center);

  List<Color> colors;
  final int maxHealth;
  int health;

  double _invulnerableTime = 0;
  static const double _invulnerabilityDuration = 1.1;

  bool get isInvulnerable => _invulnerableTime > 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_invulnerableTime > 0) {
      _invulnerableTime -= dt;
      opacity = (_invulnerableTime * 12).floor().isEven ? 1.0 : 0.35;
      if (_invulnerableTime <= 0) opacity = 1.0;
    }
  }

  double opacity = 1.0;

  /// Returns true if this hit reduced the ship's health (false if the hit
  /// was absorbed by invulnerability frames).
  bool takeHit() {
    if (isInvulnerable) return false;
    health -= 1;
    _invulnerableTime = _invulnerabilityDuration;
    add(
      ScaleEffect.to(
        Vector2.all(1.15),
        EffectController(duration: 0.08, curve: Curves.easeOut, reverseDuration: 0.12),
      ),
    );
    return true;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final fuselage = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.92, h * 0.85)
      ..lineTo(w / 2, h * 0.68)
      ..lineTo(w * 0.08, h * 0.85)
      ..close();

    final paint = Paint()
      ..color = colors.first.withValues(alpha: opacity)
      ..shader = colors.length > 1
          ? Gradient.linear(Offset(0, 0), Offset(0, h), colors)
          : null;
    canvas.drawShadow(fuselage, const Color(0x66000000), 3, false);
    canvas.drawPath(fuselage, paint);

    final cockpit = Paint()..color = const Color(0xCCFFFFFF).withValues(alpha: opacity * 0.9);
    canvas.drawCircle(Offset(w / 2, h * 0.42), w * 0.09, cockpit);

    final flame = Paint()..color = const Color(0xFF7FD3FF).withValues(alpha: opacity * 0.85);
    final flamePath = Path()
      ..moveTo(w * 0.38, h * 0.8)
      ..lineTo(w * 0.5, h * 1.05)
      ..lineTo(w * 0.62, h * 0.8)
      ..close();
    canvas.drawPath(flamePath, flame);
  }
}
