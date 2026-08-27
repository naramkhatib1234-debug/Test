import 'package:flutter/material.dart';

import '../systems/audio_system.dart';
import '../systems/save_system.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.save, required this.audio});

  final SaveSystem save;
  final AudioSystem audio;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundOn = widget.save.soundOn;
  late bool _musicOn = widget.save.musicOn;

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundOn = value);
    widget.audio.setSoundEnabled(value);
  }

  Future<void> _toggleMusic(bool value) async {
    setState(() => _musicOn = value);
    await widget.audio.setMusicEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF232A6E), Color(0xFF3D7FD9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingTile(
                  icon: Icons.volume_up_rounded,
                  label: 'Sound Effects',
                  value: _soundOn,
                  onChanged: _toggleSound,
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.music_note_rounded,
                  label: 'Music',
                  value: _musicOn,
                  onChanged: _toggleMusic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }
}
