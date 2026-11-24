import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/services/meeting_player.dart';
import '../../providers.dart';
import '../../widgets/meeting_player_bar.dart';

import 'transcription_tab.dart';
import 'documents_tab.dart';
import '../../core/utils/toast.dart';
import 'summary_tab.dart';

String languageLabel(String code) => switch (code) {
  'fr' => 'Français',
  'en' => 'English',
  _ => 'Français / English',
};

class MeetingScreen extends ConsumerStatefulWidget {
  final String meetingId;
  final int initialTab; // 0 Transcription ... 4 Documents
  const MeetingScreen({super.key, required this.meetingId, this.initialTab = 0});

  @override
  ConsumerState<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  // Le lecteur appartient à cette page : créé à l'ouverture, libéré à la fermeture.
  final MeetingPlayer _player = MeetingPlayer();

  @override
  void initState() {
    super.initState();
    // Charge (ou recharge) l'audio dès que la liste des segments est connue.
    ref.listenManual<AsyncValue<List<AudioSegment>>>(
      segmentsProvider(widget.meetingId),
          (_, next) => next.whenData((list) async {
        await _player.load(list);
        if (mounted) setState(() {});
      }),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _seekAndPlay(int ms) async {
    if (!_player.hasAudio) return;
    await _player.seekToMs(ms);
    await _player.play();
  }

  Future<void> _moveToTrash(Meeting meeting) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mettre à la corbeille ?'),
        content: Text('« ${meeting.title} » pourra être restaurée depuis la corbeille.'),
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
    final db = ref.read(dbProvider);
    await db.moveToTrash(meeting.id);
    if (!mounted) return;
    Navigator.pop(context);
    AppToast.show(
      'Réunion déplacée dans la corbeille',
      actionLabel: 'Annuler',
      onAction: () => db.restore(meeting.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.meetingId;
    final meetingAsync = ref.watch(meetingProvider(id));

    return meetingAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Erreur : $e'))),
      data: (meeting) => DefaultTabController(
        length: 5,
        initialIndex: widget.initialTab,
        child: Scaffold(
          appBar: AppBar(
            title: Text(meeting.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'trash') _moveToTrash(meeting);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'trash', child: Text('Mettre à la corbeille')),
                ],
              ),
            ],
          ),
          body: Column(children: [
            _Header(meeting: meeting),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Transcription'),
              Tab(text: 'Résumé'),
              Tab(text: 'Notes'),
              Tab(text: 'Détails'),
              Tab(text: 'Documents'),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              TranscriptionTab(meeting: meeting, onSeek: _seekAndPlay),
              SummaryTab(meeting: meeting),
              _NotesTab(meetingId: id, onSeek: _seekAndPlay),
              _DetailsTab(meeting: meeting),
              DocumentsTab(meeting: meeting),
            ]),
          ),
            MeetingPlayerBar(player: _player, fallbackTotalMs: meeting.durationMs),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- En-tête

class _Header extends ConsumerWidget {
  final Meeting meeting;
  const _Header({required this.meeting});

  (String, Color) get _status => switch (meeting.status) {
    'completed' => ('Terminée', AppColors.done),
    'transcribing' => ('Transcription en cours', AppColors.processing),
    'recorded' => ('En attente de transcription', AppColors.waiting),
    'recording' || 'paused' => ('Enregistrement', AppColors.recordRed),
    _ => ('Erreur', AppColors.recordRed),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider(meeting.id)).valueOrNull ?? [];
    final (label, color) = _status;
    final small = Theme.of(context).textTheme.bodySmall;

    Widget info(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 4),
      Text(text, style: small),
    ]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 16, runSpacing: 6, children: [
          info(Icons.calendar_today_outlined, DateFormat('d MMMM y', 'fr').format(meeting.date)),
          info(Icons.timer_outlined, formatDuration(meeting.durationMs)),
          info(Icons.group_outlined, '${participants.length} participant${participants.length > 1 ? 's' : ''}'),
          info(Icons.language, languageLabel(meeting.language)),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------- Onglet Transcription


// ---------------------------------------------------------------- Onglet Notes

class _NotesTab extends ConsumerWidget {
  final String meetingId;
  final void Function(int ms) onSeek;
  const _NotesTab({required this.meetingId, required this.onSeek});

  static const _types = {
    'note': ('📝', 'Note'),
    'important': ('⭐', 'Important'),
    'decision': ('✅', 'Décision'),
    'verify': ('⚠️', 'À vérifier'),
    'action': ('📌', 'Action'),
    'question': ('❓', 'Question'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider(meetingId)).valueOrNull ?? [];

    if (notes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aucune note ni marqueur.\nPendant l\'enregistrement, utilisez les boutons Note et Marqueur.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final n = notes[i];
        final (emoji, label) = _types[n.type] ?? ('📝', 'Note');
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => onSeek(n.timestampMs),
            leading: Text(emoji, style: const TextStyle(fontSize: 24)),
            title: Text(n.content.isEmpty ? label : n.content),
            subtitle: Text('${formatDuration(n.timestampMs)} · $label · toucher pour écouter'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(dbProvider).deleteNote(n.id),
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------------------- Onglet Détails

class _DetailsTab extends ConsumerWidget {
  final Meeting meeting;
  const _DetailsTab({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider(meeting.id)).valueOrNull ?? [];
    final ctx = ref.watch(meetingContextProvider(meeting.id)).valueOrNull;
    final segments = ref.watch(segmentsProvider(meeting.id)).valueOrNull ?? [];
    final dictionary =
    ctx == null ? <String>[] : List<String>.from(jsonDecode(ctx.dictionaryJson));

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Expanded(child: Text(value.isEmpty ? '—' : value)),
      ]),
    );

    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            row('Titre', meeting.title),
            row('Description', meeting.description),
            row('Catégorie', meeting.category),
            row('Lieu', meeting.location),
            row('Langue', languageLabel(meeting.language)),
            row('Date', DateFormat('d MMMM y', 'fr').format(meeting.date)),
            row('Durée', formatDuration(meeting.durationMs)),
            row('Segments audio', '${segments.length}'),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Text('Participants', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (participants.isEmpty)
        const Text('Aucun participant renseigné.')
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in participants) Chip(avatar: const Icon(Icons.person, size: 18), label: Text(p.name)),
        ]),
      const SizedBox(height: 16),
      Text('Dictionnaire', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (dictionary.isEmpty)
        const Text('Aucun terme renseigné.')
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final w in dictionary) Chip(label: Text(w)),
        ]),
    ]);
  }
}