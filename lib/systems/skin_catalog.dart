import 'package:flutter/material.dart';

import '../models/skin.dart';

/// Static catalog of every skin available in the game.
class SkinCatalog {
  SkinCatalog._();

  static const String defaultSkinId = 'classic';

  static const List<Skin> all = [
    Skin(
      id: 'classic',
      name: 'Classic',
      colors: [Color(0xFF6FB3F2), Color(0xFF3D7FD9)],
      unlockCost: 0,
    ),
    Skin(
      id: 'neon',
      name: 'Neon',
      colors: [Color(0xFF39FF9E), Color(0xFF00C2FF)],
      unlockCost: 120,
    ),
    Skin(
      id: 'candy',
      name: 'Candy',
      colors: [Color(0xFFFF8FD6), Color(0xFFFF5A9E)],
      unlockCost: 150,
    ),
    Skin(
      id: 'galaxy',
      name: 'Galaxy',
      colors: [Color(0xFF8E5CF7), Color(0xFF3B1F8C)],
      unlockCost: 200,
    ),
    Skin(
      id: 'fire',
      name: 'Fire',
      colors: [Color(0xFFFFC24B), Color(0xFFFF4B2B)],
      unlockCost: 200,
    ),
    Skin(
      id: 'ocean',
      name: 'Ocean',
      colors: [Color(0xFF00E5C7), Color(0xFF0072B5)],
      unlockCost: 250,
    ),
    Skin(
      id: 'rainbow',
      name: 'Rainbow',
      colors: [
        Color(0xFFFF5A5A),
        Color(0xFFFFC24B),
        Color(0xFF39FF9E),
        Color(0xFF4BA6FF),
        Color(0xFFC24BFF),
      ],
      unlockCost: 350,
    ),
  ];

  static Skin byId(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => all.first);
  }
}
