import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/star_rush_game.dart';
import '../models/game_result.dart';
import '../systems/audio_system.dart';
import '../systems/save_system.dart';
import '../systems/skin_catalog.dart';
import 'game_over_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.save, required this.audio});

  final SaveSystem save;
  final AudioSystem audio;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late StarRushGame _game;
  GameResult? _result;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final skin = SkinCatalog.byId(widget.save.selectedSkinId);
    _game = StarRushGame(
      shipColors: skin.colors,
      audio: widget.audio,
      saveSystem: widget.save,
      onGameOver: (result) {
        if (!mounted) return;
        setState(() => _result = result);
      },
    );
  }

  void _playAgain() {
    setState(() {
      _result = null;
      _startNewGame();
    });
  }

  void _backToMenu() {
    Navigator.of(context).pop(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BackButton(onTap: _backToMenu),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _game.score,
                        builder: (context, score, _) => Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _game.combo,
                        builder: (context, combo, _) => AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: combo > 1 ? 1 : 0,
                          child: Text(
                            'COMBO x$combo',
                            style: const TextStyle(
                              color: Color(0xFFFFC24B),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ValueListenableBuilder<int>(
                        valueListenable: _game.health,
                        builder: (context, health, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                i < health ? Icons.favorite : Icons.favorite_border,
                                color: const Color(0xFFFF6B6B),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_result != null)
            GameOverOverlay(
              result: _result!,
              onPlayAgain: _playAgain,
              onMainMenu: _backToMenu,
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
