import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/services/app_settings.dart';
import '../trash/trash_screen.dart';
import 'transcription_settings_screen.dart';
import 'permissions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<T?> _pick<T>(BuildContext context, String title, List<(T, String)> options, T current) {
    return showDialog<T>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(title),
        children: [
          for (final (value, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, value),
              child: Row(children: [
                Expanded(child: Text(label)),
                if (value == current) const Icon(Icons.check, size: 20),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    final segmentationLabel = switch (s.segmentation) {
      SegmentationMode.auto => 'Automatique (5 min)',
      SegmentationMode.fiveMinutes => '5 minutes',
      SegmentationMode.tenMinutes => '10 minutes',
    };
    final languageLabel = switch (s.defaultLanguage) {
      'fr' => 'Français',
      'en' => 'English',
      _ => 'Automatique',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(children: [
        _header(context, 'Enregistrement'),
        ListTile(
          leading: const Icon(Icons.graphic_eq),
          title: const Text('Qualité audio'),
          subtitle: Text(s.highQuality ? 'Haute (fichiers plus lourds)' : 'Standard'),
          onTap: () async {
            final v = await _pick<bool>(context, 'Qualité audio',
                [(false, 'Standard'), (true, 'Haute (fichiers plus lourds)')], s.highQuality);
            if (v != null) notifier.change((c) => c.copyWith(highQuality: v));
          },
        ),
        ListTile(
          leading: const Icon(Icons.content_cut),
          title: const Text('Segmentation'),
          subtitle: Text(segmentationLabel),
          onTap: () async {
            final v = await _pick<SegmentationMode>(
              context,
              'Segmentation',
              const [
                (SegmentationMode.auto, 'Automatique (5 min)'),
                (SegmentationMode.fiveMinutes, '5 minutes'),
                (SegmentationMode.tenMinutes, '10 minutes'),
              ],
              s.segmentation,
            );
            if (v != null) notifier.change((c) => c.copyWith(segmentation: v));
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Langue de transcription par défaut'),
          subtitle: Text(languageLabel),
          onTap: () async {
            final v = await _pick<String>(
              context,
              'Langue par défaut',
              const [('auto', 'Automatique'), ('fr', 'Français'), ('en', 'English')],
              s.defaultLanguage,
            );
            if (v != null) notifier.change((c) => c.copyWith(defaultLanguage: v));
          },
        ),
        _header(context, 'Apparence'),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Mode sombre'),
          value: s.themeMode == ThemeMode.dark,
          onChanged: (v) =>
              notifier.change((c) => c.copyWith(themeMode: v ? ThemeMode.dark : ThemeMode.light)),
        ),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('Taille du texte'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.9, label: Text('Petit')),
                ButtonSegment(value: 1.0, label: Text('Normal')),
                ButtonSegment(value: 1.15, label: Text('Grand')),
              ],
              selected: {s.textScale},
              onSelectionChanged: (v) => notifier.change((c) => c.copyWith(textScale: v.first)),
            ),
          ),
        ),
        _header(context, 'Fiabilité'),
        ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: const Text('Permissions et fiabilité'),
          subtitle: const Text('Microphone, notifications, économie d\'énergie'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PermissionsScreen())),
        ),
        _header(context, 'Services'),
        ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: const Text('Transcription et résumé'),
          subtitle: const Text('Service, clé API, autorisation d\'envoi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TranscriptionSettingsScreen())),
        ),
        _header(context, 'Données'),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Corbeille'),
          subtitle: const Text('Restaurer ou supprimer définitivement'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const TrashScreen())),
        ),
        const SizedBox(height: 16),
        const Center(child: Text('VoiceNote 0.1.0', style: TextStyle(fontSize: 12))),
        const SizedBox(height: 24),
      ]),
    );
  }
}