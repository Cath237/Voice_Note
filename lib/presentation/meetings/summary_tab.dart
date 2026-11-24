import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/services/summary_data.dart';
import '../../data/services/transcription_settings.dart';
import '../../providers.dart';
import '../settings/transcription_settings_screen.dart';
import '../../core/utils/toast.dart';

class SummaryTab extends ConsumerStatefulWidget {
  final Meeting meeting;
  const SummaryTab({super.key, required this.meeting});

  @override
  ConsumerState<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends ConsumerState<SummaryTab> {


  String get _id => widget.meeting.id;

  SummaryData? get _summary {
    final raw = widget.meeting.summaryJson;
    if (raw == null) return null;
    try {
      return SummaryData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    AppToast.show(message);
  }

  Future<void> _generate({required bool regenerate}) async {
    final db = ref.read(dbProvider);
    if (await db.transcriptLineCount(_id) == 0) {
      _toast('Il n\'y a pas encore de transcription à résumer');
      return;
    }
    final settings = await ref.read(transcriptionSettingsStoreProvider).load();
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(regenerate ? 'Régénérer le résumé ?' : 'Générer le résumé ?'),
        content: Text(
          'Le TEXTE de la transcription (pas l\'audio) sera envoyé à '
              '${settings.provider.label} pour être résumé.'
              '${regenerate ? '\n\nLe résumé actuel sera remplacé.' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(summaryServiceProvider).generate(_id);
      AppToast.show('Résumé généré', type: ToastType.success);
    } catch (e) {
      AppToast.show('$e', type: ToastType.error, duration: const Duration(seconds: 8));
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(summaryServiceProvider);
    final settings = ref.watch(transcriptionSettingsProvider).valueOrNull;
    final summary = _summary;

    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: service.progress,
      builder: (context, running, _) {
        final message = running[_id];
        return ListView(padding: const EdgeInsets.all(16), children: [
          if (message != null) ...[
            Row(children: [
              const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ]),
            const SizedBox(height: 6),
            Text(
              'Gardez l\'application ouverte. Une longue réunion peut prendre quelques minutes.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          if (summary == null) _empty(context, settings, message != null) else ..._content(context, summary, message != null),
        ]);
      },
    );
  }

  // ------------------------------------------------------------- pas de résumé

  Widget _empty(BuildContext context, dynamic settings, bool busy) {
    final hasKey = settings?.hasKey ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.auto_awesome_outlined, size: 44, color: AppColors.blue),
          const SizedBox(height: 12),
          const Text(
            'Générez un compte rendu : résumé, points principaux, décisions, '
                'actions et questions en suspens.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (settings != null && !hasKey) ...[
            const Text('Il faut d\'abord renseigner votre clé API.', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TranscriptionSettingsScreen())),
              child: const Text('Configurer'),
            ),
          ] else
            FilledButton.icon(
              onPressed: busy ? null : () => _generate(regenerate: false),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Générer le résumé'),
            ),
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ résumé affiché

  List<Widget> _content(BuildContext context, SummaryData s, bool busy) {
    final date = DateFormat('d MMM y', 'fr').format(s.generatedAt);
    return [
      Text(
        'Résumé généré par IA le $date${s.model.isEmpty ? '' : ' · ${s.model}'}. '
            'À relire avant diffusion.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      if (s.overview.isNotEmpty) _section(context, 'Résumé général', Text(s.overview)),
      if (s.keyPoints.isNotEmpty)
        _section(context, 'Points principaux', _bullets(s.keyPoints, Icons.circle, 7)),
      if (s.decisions.isNotEmpty)
        _section(context, 'Décisions prises',
            _bullets(s.decisions, Icons.check_circle_outline, 18, color: AppColors.done)),
      if (s.actions.isNotEmpty) _section(context, 'Actions à effectuer', _actions(s)),
      if (s.openQuestions.isNotEmpty)
        _section(context, 'Questions en suspens',
            _bullets(s.openQuestions, Icons.help_outline, 18, color: AppColors.processing)),
      if (s.topics.isNotEmpty)
        _section(
          context,
          'Sujets abordés',
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in s.topics) Chip(label: Text(t)),
          ]),
        ),
      const SizedBox(height: 4),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: s.toCopyText()));
              _toast('Résumé copié');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copier'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: busy ? null : () => _generate(regenerate: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Régénérer'),
          ),
        ),
      ]),
    ];
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue)),
          const SizedBox(height: 8),
          child,
        ]),
      ),
    );
  }

  Widget _bullets(List<String> items, IconData icon, double size, {Color? color}) {
    return Column(children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 10),
              child: Icon(icon, size: size, color: color ?? AppColors.blue),
            ),
            Expanded(child: Text(item)),
          ]),
        ),
    ]);
  }

  Widget _actions(SummaryData s) {
    return Column(children: [
      for (final a in s.actions)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.push_pin_outlined, size: 18, color: AppColors.blue),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.action),
                const SizedBox(height: 2),
                Text('Responsable : ${a.owner} · Échéance : ${a.due}',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ]),
        ),
    ]);
  }
}