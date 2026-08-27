/// Derives block speed and horizontal-movement variation from the current
/// score, so the game gradually ramps up instead of spiking in difficulty.
class DifficultySystem {
  static const double _baseSpeed = 90;
  static const double _maxSpeed = 320;
  static const double _speedRampPerBlock = 6.5;

  /// Horizontal speed (px/s) for the moving block at the given [blocksPlaced].
  static double speedFor(int blocksPlaced) {
    final speed = _baseSpeed + blocksPlaced * _speedRampPerBlock;
    return speed.clamp(_baseSpeed, _maxSpeed);
  }

  /// Occasionally the spawn side / amplitude gets extra variation once the
  /// player has proven they can handle the base pattern.
  static bool useWideSwing(int blocksPlaced) => blocksPlaced >= 12;

  static bool useDirectionJitter(int blocksPlaced) => blocksPlaced >= 20;
}
