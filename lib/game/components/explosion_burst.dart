import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// Builds a small radial burst of particles, used to celebrate a destroyed
/// enemy or a player hit.
ParticleSystemComponent buildExplosion({
  required Vector2 position,
  required List<Color> colors,
  int count = 16,
  double speed = 90,
}) {
  final random = Random();

  return ParticleSystemComponent(
    position: position,
    particle: Particle.generate(
      count: count,
      lifespan: 0.6,
      generator: (i) {
        final angle = random.nextDouble() * 2 * pi;
        final velocityMag = speed * 0.5 + random.nextDouble() * speed;
        final velocity = Vector2(cos(angle), sin(angle)) * velocityMag;
        final color = colors[random.nextInt(colors.length)];

        return AcceleratedParticle(
          speed: velocity,
          acceleration: Vector2(0, 60),
          child: CircleParticle(
            radius: 2 + random.nextDouble() * 2.5,
            paint: Paint()..color = color,
          ),
        );
      },
    ),
  );
}
