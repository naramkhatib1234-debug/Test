import 'package:flutter_test/flutter_test.dart';
import 'package:stack_rush/systems/difficulty_system.dart';

void main() {
  test('speed increases gradually and never decreases', () {
    double previous = DifficultySystem.speedFor(0);
    for (var blocks = 1; blocks <= 100; blocks++) {
      final speed = DifficultySystem.speedFor(blocks);
      expect(speed, greaterThanOrEqualTo(previous));
      previous = speed;
    }
  });

  test('speed is clamped to a sane maximum', () {
    expect(DifficultySystem.speedFor(10000), lessThanOrEqualTo(320));
  });

  test('movement variation unlocks only after enough blocks', () {
    expect(DifficultySystem.useWideSwing(0), isFalse);
    expect(DifficultySystem.useWideSwing(12), isTrue);
    expect(DifficultySystem.useDirectionJitter(0), isFalse);
    expect(DifficultySystem.useDirectionJitter(20), isTrue);
  });
}
