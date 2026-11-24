import 'package:flutter/material.dart';

/// Barre du bas : 4 onglets + place pour le bouton central « + ».
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  const AppBottomBar({super.key, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget item(int index, IconData icon, String label) {
      final color = index == currentIndex ? primary : grey;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: color),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: color)),
            ]),
          ),
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      padding: EdgeInsets.zero,
      child: Row(children: [
        item(0, Icons.home_rounded, 'Accueil'),
        item(1, Icons.mic_none_rounded, 'Réunions'),
        const SizedBox(width: 72), // place du bouton central
        item(2, Icons.description_outlined, 'Documents'),
        item(3, Icons.settings_outlined, 'Paramètres'),
      ]),
    );
  }
}