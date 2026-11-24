import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../widgets/meeting_tile.dart';
import '../recording/new_meeting_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingsProvider);
    return SafeArea(
      child: meetings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) => _Content(meetings: list),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  final List<Meeting> meetings;
  const _Content({required this.meetings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalMs = meetings.fold<int>(0, (sum, m) => sum + m.durationMs);
    final done = meetings.where((m) => m.status == 'completed').length;
    final pending = meetings
        .where((m) => m.status == 'recorded' || m.status == 'transcribing')
        .length;
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour Dorcas',
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('Gestion de vos réunions', style: text.bodyMedium),
            ]),
          ),
          Image.asset('assets/images/logo.png', width: 44),
        ]),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NewMeetingScreen())),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle réunion'),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _StatCard('${meetings.length}', 'Réunions')),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(formatTotal(totalMs), 'Durée totale')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _StatCard('$done', 'Terminées')),
          const SizedBox(width: 10),
          Expanded(child: _StatCard('$pending', 'En attente', color: AppColors.processing)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: Text('Récentes',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => ref.read(navIndexProvider.notifier).state = 1,
            child: const Text('Tout voir'),
          ),
        ]),
        const SizedBox(height: 4),
        if (meetings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('Aucune réunion pour le moment.\nAppuyez sur « Nouvelle réunion ».',
                  textAlign: TextAlign.center),
            ),
          )
        else
          for (final m in meetings.take(5)) MeetingTile(meeting: m),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _StatCard(this.value, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall),
        ]),
      ),
    );
  }
}