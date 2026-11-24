import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/services/transcription_settings.dart';
import '../../providers.dart';
import '../settings/transcription_settings_screen.dart';
import '../../core/utils/toast.dart';

/// Onglet Transcription : progression, recherche, édition, locuteurs.
class TranscriptionTab extends ConsumerStatefulWidget {
  final Meeting meeting;
  final void Function(int ms) onSeek; // positionne le lecteur audio
  const TranscriptionTab({super.key, required this.meeting, required this.onSeek});

  @override
  ConsumerState<TranscriptionTab> createState() => _TranscriptionTabState();
}

class _TranscriptionTabState extends ConsumerState<TranscriptionTab> {
  final _searchController = TextEditingController();
  final _listController = ItemScrollController();
  String _query = '';
  String? _highlightId;

  String get _id => widget.meeting.id;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ utilitaires

  String _speakerName(String? speakerId, List<Participant> people) {
    if (speakerId == null) return '';
    for (final p in people) {
      if (p.speakerIdentifier == speakerId) return p.name;
    }
    return 'Locuteur ?';
  }

  void _toast(String message) {
    if (!mounted) return;
    AppToast.show(message);
  }

  Future<String?> _askText(String title, String initial, {String confirm = 'Enregistrer'}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: Text(confirm),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- actions

  Future<void> _edit(TranscriptSegment line) async {
    final result = await showModalBottomSheet<(String, int?)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditSheet(initial: line.content),
    );
    if (result == null) return;
    final (text, splitAt) = result;
    final db = ref.read(dbProvider);

    if (text.trim().isEmpty) {
      _toast('Le texte est vide : utilisez « Supprimer » pour retirer la ligne');
      return;
    }
    if (splitAt != null) {
      await db.splitTranscriptLine(line, text, splitAt);
    } else if (text.trim() != line.content) {
      await db.updateTranscriptContent(line.id, text.trim());
    } else {
      return;
    }
    _toast('Modifications enregistrées');
  }

  Future<void> _delete(TranscriptSegment line) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cette ligne ?'),
        content: const Text('L\'audio original n\'est pas modifié.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.recordRed, minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(dbProvider).deleteTranscriptLine(line.id);
    _toast('Modifications enregistrées');
  }

  Future<void> _pickLanguage(TranscriptSegment line) async {
    final code = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Langue de cette ligne'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(c, 'fr'), child: const Text('Français')),
          SimpleDialogOption(onPressed: () => Navigator.pop(c, 'en'), child: const Text('English')),
          SimpleDialogOption(onPressed: () => Navigator.pop(c, 'unknown'), child: const Text('Non précisée')),
        ],
      ),
    );
    if (code == null) return;
    await ref.read(dbProvider).updateTranscriptLanguage(line.id, code);
    _toast('Modifications enregistrées');
  }

  Future<void> _pickSpeaker(TranscriptSegment line, List<Participant> people) async {
    final db = ref.read(dbProvider);
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Qui parle ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: const Text('Aucun locuteur'),
            trailing: line.speakerId == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(c, 'none'),
          ),
          for (final p in people)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(p.name),
              trailing: (p.speakerIdentifier != null && p.speakerIdentifier == line.speakerId)
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(c, p),
            ),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text('Nouveau locuteur'),
            onTap: () => Navigator.pop(c, 'new'),
          ),
        ]),
      ),
    );
    if (choice == null) return;

    String? speakerId;
    if (choice == 'none') {
      speakerId = null;
    } else if (choice == 'new') {
      speakerId = await _createSpeaker(people.length);
      if (speakerId == null) return;
    } else {
      speakerId = await db.ensureSpeakerId(choice as Participant);
    }
    await db.updateTranscriptSpeaker(line.id, speakerId);
    _toast('Modifications enregistrées');
  }

  Future<String?> _createSpeaker(int existingCount) async {
    final name = await _askText('Nouveau locuteur', 'Locuteur ${existingCount + 1}', confirm: 'Créer');
    if (name == null || name.isEmpty) return null;
    return ref.read(dbProvider).addSpeaker(_id, name);
  }

  Future<void> _manageSpeakers() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Consumer(builder: (context, ref, _) {
        final people = ref.watch(participantsProvider(_id)).valueOrNull ?? [];
        return SafeArea(
          child: ListView(shrinkWrap: true, children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Locuteurs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Renommer un locuteur met à jour toute la transcription.'),
            ),
            for (final p in people)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(p.name),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  final name = await _askText('Renommer le locuteur', p.name);
                  if (name != null && name.isNotEmpty) {
                    await ref.read(dbProvider).renameParticipant(p.id, name);
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: const Text('Ajouter un locuteur'),
              onTap: () => _createSpeaker(people.length),
            ),
          ]),
        );
      }),
    );
  }

  Future<void> _onMenu(String action, TranscriptSegment line, int index,
      List<TranscriptSegment> all, List<Participant> people) async {
    final db = ref.read(dbProvider);
    switch (action) {
      case 'edit':
        await _edit(line);
      case 'speaker':
        await _pickSpeaker(line, people);
      case 'language':
        await _pickLanguage(line);
      case 'mergePrev':
        await db.mergeTranscriptLines(all[index - 1], line);
        _toast('Modifications enregistrées');
      case 'mergeNext':
        await db.mergeTranscriptLines(line, all[index + 1]);
        _toast('Modifications enregistrées');
      case 'delete':
        await _delete(line);
    }
  }

  /// Depuis un résultat de recherche : retour à la transcription,
  /// à la bonne ligne, qui est brièvement surlignée.
  void _openResult(TranscriptSegment result, List<TranscriptSegment> all) {
    final index = all.indexWhere((l) => l.id == result.id);
    setState(() {
      _query = '';
      _searchController.clear();
      _highlightId = result.id;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index >= 0 && _listController.isAttached) {
        _listController.jumpTo(index: index);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _highlightId == result.id) setState(() => _highlightId = null);
    });
  }

  // ------------------------------------------------------------------ écran

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(transcriptProvider(_id)).valueOrNull ?? [];
    final people = ref.watch(participantsProvider(_id)).valueOrNull ?? [];

    final q = normalizeForSearch(_query.trim());
    final results =
    q.isEmpty ? null : lines.where((l) => normalizeForSearch(l.content).contains(q)).toList();

    return Column(children: [
      _ProgressPanel(meeting: widget.meeting),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Rechercher dans la transcription',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _query = '';
                    _searchController.clear();
                  }),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Locuteurs',
            icon: const Icon(Icons.groups_outlined),
            onPressed: _manageSpeakers,
          ),
        ]),
      ),
      if (results != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Résultats (${results.length})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      Expanded(child: results != null ? _results(results, lines, people) : _fullList(lines, people)),
    ]);
  }

  Widget _results(List<TranscriptSegment> results, List<TranscriptSegment> all, List<Participant> people) {
    if (results.isEmpty) {
      return const Center(child: Text('Aucun résultat'));
    }
    final q = normalizeForSearch(_query.trim());
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final r = results[i];
        final who = _speakerName(r.speakerId, people);
        return ListTile(
          onTap: () => _openResult(r, all),
          title: _highlighted(r.content, q),
          subtitle: Text('${formatDuration(r.startMs)}${who.isEmpty ? '' : ' · $who'}'),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  /// Texte avec les occurrences recherchées en gras et surlignées.
  Widget _highlighted(String text, String normalizedQuery) {
    final normalized = normalizeForSearch(text);
    final spans = <TextSpan>[];
    var from = 0;
    while (true) {
      final at = normalized.indexOf(normalizedQuery, from);
      if (at < 0) break;
      if (at > from) spans.add(TextSpan(text: text.substring(from, at)));
      spans.add(TextSpan(
        text: text.substring(at, at + normalizedQuery.length),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          backgroundColor: AppColors.turquoise.withOpacity(0.3),
        ),
      ));
      from = at + normalizedQuery.length;
    }
    if (from < text.length) spans.add(TextSpan(text: text.substring(from)));
    return Text.rich(
      TextSpan(style: DefaultTextStyle.of(context).style, children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _fullList(List<TranscriptSegment> lines, List<Participant> people) {
    if (lines.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Le texte apparaîtra ici au fur et à mesure de la transcription.\nVotre audio est conservé.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ScrollablePositionedList.builder(
      itemScrollController: _listController,
      padding: const EdgeInsets.all(12),
      itemCount: lines.length,
      itemBuilder: (context, i) => _line(lines[i], i, lines, people),
    );
  }

  Widget _line(TranscriptSegment line, int index, List<TranscriptSegment> all, List<Participant> people) {
    final who = _speakerName(line.speakerId, people);
    final highlighted = line.id == _highlightId;
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.turquoise.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => widget.onSeek(line.startMs), // écouter ce passage
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 0, 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  [
                    formatDuration(line.startMs),
                    if (who.isNotEmpty) who,
                    if (line.language != 'unknown') line.language,
                    if (line.edited) 'modifié',
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(line.content),
              ]),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) => _onMenu(v, line, index, all, people),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Modifier / séparer')),
                const PopupMenuItem(value: 'speaker', child: Text('Changer le locuteur')),
                const PopupMenuItem(value: 'language', child: Text('Corriger la langue')),
                PopupMenuItem(
                    value: 'mergePrev',
                    enabled: index > 0,
                    child: const Text('Fusionner avec la précédente')),
                PopupMenuItem(
                    value: 'mergeNext',
                    enabled: index < all.length - 1,
                    child: const Text('Fusionner avec la suivante')),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- Fenêtre d'édition

class _EditSheet extends StatefulWidget {
  final String initial;
  const _EditSheet({required this.initial});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _split() {
    final at = _controller.selection.baseOffset;
    if (at <= 0 || at >= _controller.text.length) {
      setState(() => _error = 'Placez d\'abord le curseur dans le texte, là où couper.');
      return;
    }
    Navigator.pop(context, (_controller.text, at));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Texte de la ligne'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.recordRed, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: _split,
                  child: const Text('Séparer au curseur'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, (_controller.text, null)),
                  child: const Text('Enregistrer'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------- Progression de la transcription

class _ProgressPanel extends ConsumerWidget {
  final Meeting meeting;
  const _ProgressPanel({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = meeting.id;
    final queue = ref.watch(queueProvider);
    final segments = ref.watch(segmentsProvider(id)).valueOrNull ?? [];
    final settings = ref.watch(transcriptionSettingsProvider).valueOrNull;

    final total = segments.length;
    final done = segments.where((s) => s.status == 'completed').length;
    final failed = segments.where((s) => s.status == 'failed').toList();
    final recording = meeting.status == 'recording' || meeting.status == 'paused';

    // Rien à afficher une fois tout transcrit.
    if (total == 0 || recording || done == total) return const SizedBox.shrink();

    return ValueListenableBuilder<Set<String>>(
      valueListenable: queue.running,
      builder: (context, runningSet, _) {
        final isRunning = runningSet.contains(id);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Transcription : $done / $total segments traités',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: done / total, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 10),
            if (settings != null && !settings.isReady)
              Card(
                color: AppColors.processing.withOpacity(0.12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Pour transcrire, choisissez un service, collez votre clé API '
                        'et autorisez l\'envoi de l\'audio.'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TranscriptionSettingsScreen())),
                      child: const Text('Configurer'),
                    ),
                  ]),
                ),
              )
            else if (isRunning)
              ValueListenableBuilder<bool>(
                valueListenable: queue.waitingForNetwork,
                builder: (context, waiting, _) => Row(children: [
                  const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      waiting
                          ? 'En attente de connexion Internet. L\'audio est conservé.'
                          : 'Transcription en cours (audio envoyé à ${settings?.provider.label ?? 'service'})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ]),
              )
            else
              FilledButton.icon(
                onPressed: () => queue.retry(id),
                icon: const Icon(Icons.subject_rounded),
                label: Text(done == 0 && failed.isEmpty
                    ? 'Lancer la transcription'
                    : 'Reprendre la transcription'),
              ),
            if (failed.isNotEmpty && !isRunning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${failed.length} segment(s) en échec : ${failed.first.errorMessage ?? 'erreur inconnue'}',
                  style: const TextStyle(color: AppColors.recordRed, fontSize: 12),
                ),
              ),
          ]),
        );
      },
    );
  }
}