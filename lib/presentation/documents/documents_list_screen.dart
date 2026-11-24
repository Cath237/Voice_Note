import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers.dart';
import '../meetings/meeting_screen.dart';

/// Réunions prêtes à exporter. Un tap ouvre directement leur onglet Documents.
class DocumentsListScreen extends ConsumerWidget {
  const DocumentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingsProvider).valueOrNull ?? [];
    final ready =
    meetings.where((m) => m.status == 'completed' || m.summaryJson != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: ready.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Les réunions transcrites apparaîtront ici, prêtes à être '
                'exportées en Word, PDF ou texte, imprimées ou partagées.',
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView(padding: const EdgeInsets.all(16), children: [
        for (final m in ready)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MeetingScreen(meetingId: m.id, initialTab: 4)),
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0x1F1565E0),
                child: Icon(Icons.description_outlined, color: AppColors.blue),
              ),
              title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${formatDay(m.date)}${m.summaryJson != null ? ' · résumé disponible' : ''}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
      ]),
    );
  }
}