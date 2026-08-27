import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../systems/audio_system.dart';
import '../systems/save_system.dart';
import '../widgets/game_button.dart';
import '../widgets/stat_chip.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'skins_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.save, required this.audio});

  final SaveSystem save;
  final AudioSystem audio;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<void> _openPlay() async {
    await Navigator.of(context).push<GameResult>(
      MaterialPageRoute(
        builder: (_) => GameScreen(save: widget.save, audio: widget.audio),
      ),
    );
    setState(() {});
  }

  Future<void> _openSkins() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SkinsScreen(save: widget.save)),
    );
    setState(() {});
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(save: widget.save, audio: widget.audio),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1240), Color(0xFF1B2A6B), Color(0xFF3A1B6B)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatChip(
                      icon: Icons.emoji_events,
                      value: '${widget.save.bestScore}',
                      color: const Color(0xFFFFC24B),
                    ),
                    StatChip(
                      icon: Icons.monetization_on,
                      value: '${widget.save.coins}',
                      color: const Color(0xFFFFD54B),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                Column(
                  children: [
                    Text(
                      'STAR',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'RUSH',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC24BFF),
                        letterSpacing: 10,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 4),
                GameButton(
                  label: 'PLAY',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFFFF6B6B),
                  onPressed: _openPlay,
                ),
                const SizedBox(height: 16),
                GameButton(
                  label: 'SHIPS',
                  icon: Icons.rocket_launch_rounded,
                  filled: false,
                  onPressed: _openSkins,
                ),
                const SizedBox(height: 16),
                GameButton(
                  label: 'SETTINGS',
                  icon: Icons.settings_rounded,
                  filled: false,
                  onPressed: _openSettings,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
