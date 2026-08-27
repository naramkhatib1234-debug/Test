import 'package:flutter_test/flutter_test.dart';
import 'package:stack_rush/systems/difficulty_system.dart';

void main() {
  test('spawn interval shortens as score grows and never undershoots the floor', () {
    double previous = DifficultySystem.spawnIntervalFor(0);
    for (var score = 10; score <= 2000; score += 10) {
      final interval = DifficultySystem.spawnIntervalFor(score);
      expect(interval, lessThanOrEqualTo(previous));
      expect(interval, greaterThanOrEqualTo(0.38));
      previous = interval;
    }
  });

  test('enemy speed increases gradually and is clamped to a sane maximum', () {
    double previous = DifficultySystem.enemySpeedFor(0);
    for (var score = 10; score <= 2000; score += 10) {
      final speed = DifficultySystem.enemySpeedFor(score);
      expect(speed, greaterThanOrEqualTo(previous));
      expect(speed, lessThanOrEqualTo(220));
      previous = speed;
    }
  });

  test('enemy behavior variety unlocks only after enough score', () {
    expect(DifficultySystem.useZigzagEnemies(0), isFalse);
    expect(DifficultySystem.useZigzagEnemies(40), isTrue);
    expect(DifficultySystem.useShootingEnemies(0), isFalse);
    expect(DifficultySystem.useShootingEnemies(90), isTrue);
    expect(DifficultySystem.useTankEnemies(0), isFalse);
    expect(DifficultySystem.useTankEnemies(150), isTrue);
  });
}
