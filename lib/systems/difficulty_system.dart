/// Derives enemy spawn rate, speed, and behavior variety from the current
/// score, so the game gradually ramps up instead of spiking in difficulty.
class DifficultySystem {
  static const double _baseSpawnInterval = 1.15;
  static const double _minSpawnInterval = 0.38;
  static const double _spawnRampPerPoint = 0.006;

  static const double _baseEnemySpeed = 70;
  static const double _maxEnemySpeed = 220;
  static const double _speedRampPerPoint = 0.9;

  /// Seconds between enemy spawns at the given [score].
  static double spawnIntervalFor(int score) {
    final interval = _baseSpawnInterval - score * _spawnRampPerPoint;
    return interval.clamp(_minSpawnInterval, _baseSpawnInterval);
  }

  /// Downward speed (px/s) for a freshly spawned enemy at the given [score].
  static double enemySpeedFor(int score) {
    final speed = _baseEnemySpeed + score * _speedRampPerPoint;
    return speed.clamp(_baseEnemySpeed, _maxEnemySpeed);
  }

  /// Enemies start weaving side-to-side once the player has proven they can
  /// handle a straight descent.
  static bool useZigzagEnemies(int score) => score >= 40;

  /// Enemies start firing back once the player is further in.
  static bool useShootingEnemies(int score) => score >= 90;

  /// Tougher (multi-hit) enemies show up later still.
  static bool useTankEnemies(int score) => score >= 150;
}
