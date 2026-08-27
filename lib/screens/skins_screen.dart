import 'package:flutter/material.dart';

import '../models/skin.dart';
import '../systems/save_system.dart';
import '../systems/skin_catalog.dart';
import '../widgets/stat_chip.dart';

class SkinsScreen extends StatefulWidget {
  const SkinsScreen({super.key, required this.save});

  final SaveSystem save;

  @override
  State<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends State<SkinsScreen> {
  Future<void> _onTapSkin(Skin skin) async {
    if (widget.save.isSkinUnlocked(skin.id)) {
      await widget.save.selectSkin(skin.id);
      setState(() {});
      return;
    }

    final spent = await widget.save.spendCoins(skin.unlockCost);
    if (!spent) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${skin.unlockCost} coins to unlock ${skin.name}'),
          backgroundColor: const Color(0xFF232A6E),
        ),
      );
      return;
    }

    await widget.save.unlockSkin(skin.id);
    await widget.save.selectSkin(skin.id);
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
                      'SKINS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    StatChip(
                      icon: Icons.monetization_on,
                      value: '${widget.save.coins}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: SkinCatalog.all.length,
                    itemBuilder: (context, index) {
                      final skin = SkinCatalog.all[index];
                      final unlocked = widget.save.isSkinUnlocked(skin.id);
                      final selected = widget.save.selectedSkinId == skin.id;
                      return _SkinTile(
                        skin: skin,
                        unlocked: unlocked,
                        selected: selected,
                        onTap: () => _onTapSkin(skin),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final Skin skin;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withValues(alpha: 0.22),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: skin.gradient(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: skin.colors.last.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              skin.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18)
            else if (unlocked)
              const Text(
                'TAP TO SELECT',
                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${skin.unlockCost}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
