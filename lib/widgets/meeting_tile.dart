import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../data/database/app_database.dart';
import '../presentation/meetings/meeting_screen.dart';
import '../presentation/recording/recording_screen.dart';
import '../providers.dart';
import '../core/utils/toast.dart';

/// Envoie une réunion à la corbeille, avec possibilité d'annuler.
Future<void> moveMeetingToTrash(BuildContext context, WidgetRef ref, Meeting m) async {
  if (m.status == 'recording' || m.status == 'paused') {
    AppToast.show('Arrêtez d\'abord l\'enregistrement');
    return;
  }
  final db = ref.read(dbProvider);
  await db.moveToTrash(m.id);
  AppToast.show(
    'Réunion déplacée dans la corbeille',
    actionLabel: 'Annuler',
    onAction: () => db.restore(m.id),
  );
}

/// Ligne de réunion utilisée par l'accueil et par l'historique.
class MeetingTile extends ConsumerWidget {
  final Meeting meeting;
  const MeetingTile({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(transcriptionProgressProvider).valueOrNull?[meeting.id];

    final (label, color) = switch (meeting.status) {
      'completed' => ('Terminée', AppColors.done),
      'transcribing' => (
      progress == null ? 'En cours' : 'En cours ${(progress * 100).round()} %',
      AppColors.processing
      ),
      'recorded' => ('En attente', AppColors.waiting),
      'recording' || 'paused' => ('Enregistrement', AppColors.recordRed),
      _ => ('Erreur', AppColors.recordRed),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onLongPress: () => moveMeetingToTrash(context, ref, meeting),
        onTap: () {
          // Une réunion en cours rouvre l'enregistreur ; sinon, sa page.
          final live = meeting.status == 'recording' || meeting.status == 'paused';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => live
                  ? RecordingScreen(meetingId: meeting.id)
                  : MeetingScreen(meetingId: meeting.id),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.mic_rounded, color: color),
        ),
        title: Text(meeting.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${formatDay(meeting.date)} · ${formatDuration(meeting.durationMs)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}