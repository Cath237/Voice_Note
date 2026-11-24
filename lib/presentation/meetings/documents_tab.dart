import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/theme/app_theme.dart';
import '../../core/utils/toast.dart';
import '../../data/database/app_database.dart';
import '../../data/services/document_service.dart';
import '../../data/services/meeting_document.dart';
import '../../data/services/share_service.dart';
import '../../providers.dart';
import 'pdf_preview_screen.dart';

class DocumentsTab extends ConsumerStatefulWidget {
  final Meeting meeting;
  const DocumentsTab({super.key, required this.meeting});

  @override
  ConsumerState<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<DocumentsTab> {
  bool _summary = true;
  bool _transcript = true;
  bool _notes = true;
  bool _timestamps = true;
  bool _speakers = true;
  String? _busy; // message affiché pendant la création d'un document

  String get _id => widget.meeting.id;
  bool get _meetingHasSummary => widget.meeting.summaryJson != null;

  ExportOptions get _options => ExportOptions(
    includeSummary: _summary && _meetingHasSummary,
    includeTranscript: _transcript,
    includeNotes: _notes,
    includeTimestamps: _timestamps,
    includeSpeakers: _speakers,
  );

  void _toast(String message) => AppToast.show(message);

  /// Y a-t-il quelque chose à mettre dans le document, d'après les cases cochées ?
  Future<bool> _canExport() async {
    final hasLines = await ref.read(dbProvider).transcriptLineCount(_id) > 0;
    return (_transcript && hasLines) || (_summary && _meetingHasSummary);
  }

  Future<void> _run(String label, Future<void> Function() job) async {
    if (_busy != null) return;
    setState(() => _busy = label);
    try {
      await job();
    } catch (e) {
      _toast('Échec : $e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  // ----------------------------------------------------------------- actions

  Future<void> _export(ExportFormat format) => _run('Création du document...', () async {
    if (!await _canExport()) {
      _toast('Rien à exporter : cochez la transcription ou le résumé');
      return;
    }
    final file = await ref.read(documentServiceProvider).export(_id, format, _options);
    await ref.read(shareProvider).shareFiles(
      [ShareItem(file.path, p.basename(file.path))],
      subject: widget.meeting.title,
    );
  });

  Future<void> _preview() => _run('Préparation de l\'aperçu...', () async {
    if (!await _canExport()) {
      _toast('Rien à imprimer : cochez la transcription ou le résumé');
      return;
    }
    final bytes = await ref.read(documentServiceProvider).pdfBytes(_id, _options);
    if (!mounted) return;
    final name = '${exportBaseName(widget.meeting.title, widget.meeting.date)}.pdf';
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewScreen(bytes: bytes, fileName: name)),
    );
  });

  Future<void> _share() async {
    final audioCount = (ref.read(segmentsProvider(_id)).valueOrNull ?? const [])
        .where((s) => s.status != 'recording')
        .length;
    final hasText = await _canExport();
    if (!mounted) return;
    final choice = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ShareSheet(audioCount: audioCount, hasText: hasText),
    );
    if (choice == null || choice.isEmpty) return;

    await _run('Préparation du partage...', () async {
      final docs = ref.read(documentServiceProvider);
      final items = <ShareItem>[];

      if (choice.contains('audio')) {
        items.addAll(await docs.audioItems(_id, widget.meeting.title, widget.meeting.date));
      }
      for (final (key, format) in [
        ('word', ExportFormat.word),
        ('pdf', ExportFormat.pdf),
        ('txt', ExportFormat.txt),
      ]) {
        if (choice.contains(key)) {
          final file = await docs.export(_id, format, _options);
          items.add(ShareItem(file.path, p.basename(file.path)));
        }
      }
      if (items.isEmpty) {
        _toast('Rien à partager');
        return;
      }
      await ref.read(shareProvider).shareFiles(items, subject: widget.meeting.title);
    });
  }

  // ------------------------------------------------------------------ écran

  Widget _action(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: _busy == null,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_busy != null) ...[
        Row(children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(_busy!),
        ]),
        const SizedBox(height: 12),
      ],
      Card(
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Contenu du document', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          CheckboxListTile(
            value: _summary && _meetingHasSummary,
            onChanged: _meetingHasSummary ? (v) => setState(() => _summary = v ?? true) : null,
            title: const Text('Résumé'),
            subtitle: _meetingHasSummary
                ? null
                : const Text('Pas encore généré (onglet Résumé)'),
          ),
          CheckboxListTile(
            value: _transcript,
            onChanged: (v) => setState(() => _transcript = v ?? true),
            title: const Text('Transcription'),
          ),
          CheckboxListTile(
            value: _timestamps,
            onChanged: (v) => setState(() => _timestamps = v ?? true),
            title: const Text('Horodatage'),
          ),
          CheckboxListTile(
            value: _speakers,
            onChanged: (v) => setState(() => _speakers = v ?? true),
            title: const Text('Noms des locuteurs'),
          ),
          CheckboxListTile(
            value: _notes,
            onChanged: (v) => setState(() => _notes = v ?? true),
            title: const Text('Notes et marqueurs'),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Text('Exporter', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      _action(Icons.description_outlined, AppColors.blue, 'Word (.docx)',
          'Créer le document et le partager', () => _export(ExportFormat.word)),
      _action(Icons.picture_as_pdf_outlined, AppColors.recordRed, 'PDF',
          'Créer le document et le partager', () => _export(ExportFormat.pdf)),
      _action(Icons.text_snippet_outlined, AppColors.waiting, 'Texte (.txt)',
          'Créer le fichier et le partager', () => _export(ExportFormat.txt)),
      _action(Icons.print_outlined, AppColors.deepBlue, 'Aperçu et impression',
          'Voir le PDF, puis imprimer', _preview),
      _action(Icons.share_outlined, AppColors.done, 'Partager la réunion',
          'Audio, Word, PDF : WhatsApp, Gmail, Drive...', _share),
    ]);
  }
}

// --------------------------------------------------- Fenêtre « Partager la réunion »

class _ShareSheet extends StatefulWidget {
  final int audioCount;
  final bool hasText;
  const _ShareSheet({required this.audioCount, required this.hasText});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final Set<String> _selected = {};

  Widget _option(String key, String title, {String? subtitle, bool enabled = true}) {
    return CheckboxListTile(
      value: _selected.contains(key),
      enabled: enabled,
      onChanged: (v) => setState(() => v == true ? _selected.add(key) : _selected.remove(key)),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Partager la réunion',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          _option('audio', 'Audio (.m4a)',
              subtitle: widget.audioCount > 1
                  ? '${widget.audioCount} fichiers, un par segment de 5 minutes'
                  : null,
              enabled: widget.audioCount > 0),
          _option('word', 'Document Word (.docx)', enabled: widget.hasText),
          _option('pdf', 'Document PDF', enabled: widget.hasText),
          _option('txt', 'Document texte (.txt)', enabled: widget.hasText),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Les documents contiennent ce que vous avez coché dans « Contenu du document » '
                  '(résumé, transcription...). Dans la liste qui s\'ouvre, choisissez WhatsApp, '
                  'Gmail, Drive ou une autre application.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.done),
              onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected),
              icon: const Icon(Icons.share),
              label: const Text('Partager'),
            ),
          ),
        ]),
      ),
    );
  }
}