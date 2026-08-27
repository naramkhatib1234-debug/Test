import 'package:flutter/material.dart';

/// Defines the visual style applied to the player's ship.
class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.colors,
    required this.unlockCost,
  });

  final String id;
  final String name;

  /// Gradient stops used to paint the ship (and its bullets) with this skin.
  final List<Color> colors;

  /// Coin cost to unlock. Zero means unlocked from the start.
  final int unlockCost;

  bool get isFree => unlockCost <= 0;

  LinearGradient gradient({double angle = 0.35}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}
