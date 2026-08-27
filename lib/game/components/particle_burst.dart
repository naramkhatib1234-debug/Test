import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// Builds a small radial burst of particles, used to celebrate a perfect
/// block placement.
ParticleSystemComponent buildPerfectBurst({
  required Vector2 position,
  required List<Color> colors,
}) {
  final random = Random();

  return ParticleSystemComponent(
    position: position,
    particle: Particle.generate(
      count: 18,
      lifespan: 0.7,
      generator: (i) {
        final angle = random.nextDouble() * 2 * pi;
        final speed = 60 + random.nextDouble() * 90;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final color = colors[random.nextInt(colors.length)];

        return AcceleratedParticle(
          speed: velocity,
          acceleration: Vector2(0, 180),
          child: CircleParticle(
            radius: 2 + random.nextDouble() * 2.5,
            paint: Paint()..color = color,
          ),
        );
      },
    ),
  );
}
