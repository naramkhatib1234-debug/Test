import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../widgets/game_button.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  final GameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF232A6E),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.isNewBest)
              const Text(
                'NEW BEST!',
                style: TextStyle(
                  color: Color(0xFFFFC24B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              )
            else
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${result.score}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 64,
                height: 1,
              ),
            ),
            const Text(
              'SCORE',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                  icon: Icons.emoji_events,
                  color: const Color(0xFFFFC24B),
                  label: 'BEST',
                  value: '${result.bestScore}',
                ),
                _StatColumn(
                  icon: Icons.monetization_on,
                  color: const Color(0xFFFFD54B),
                  label: 'COINS',
                  value: '+${result.coinsEarned}',
                ),
              ],
            ),
            const SizedBox(height: 28),
            GameButton(
              label: 'PLAY AGAIN',
              icon: Icons.replay_rounded,
              color: const Color(0xFFFF6B6B),
              onPressed: onPlayAgain,
            ),
            const SizedBox(height: 14),
            GameButton(
              label: 'MAIN MENU',
              icon: Icons.home_rounded,
              filled: false,
              onPressed: onMainMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
