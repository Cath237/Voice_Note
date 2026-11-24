import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../widgets/meeting_tile.dart';
import '../trash/trash_screen.dart';

enum _Filter { all, today, week, month, done, live, waiting, errors }

const _filterLabels = <_Filter, String>{
  _Filter.all: 'Toutes',
  _Filter.today: 'Aujourd\'hui',
  _Filter.week: 'Cette semaine',
  _Filter.month: 'Ce mois',
  _Filter.done: 'Terminées',
  _Filter.live: 'En cours',
  _Filter.waiting: 'En attente',
  _Filter.errors: 'Erreurs',
};

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  _Filter _filter = _Filter.all;
  String _query = '';
  Set<String>? _contentMatches; // réunions dont participants / transcription correspondent

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final q = value.trim();
      final ids = q.length < 2 ? null : await ref.read(dbProvider).meetingIdsMatching(q);
      if (mounted) setState(() => _contentMatches = ids);
    });
  }

  bool _matchesFilter(Meeting m) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(m.date.year, m.date.month, m.date.day);
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.today:
        return day == today;
      case _Filter.week:
        return !day.isBefore(today.subtract(Duration(days: now.weekday - 1)));
      case _Filter.month:
        return m.date.year == now.year && m.date.month == now.month;
      case _Filter.done:
        return m.status == 'completed';
      case _Filter.live:
        return const {'recording', 'paused', 'transcribing'}.contains(m.status);
      case _Filter.waiting:
        return m.status == 'recorded';
      case _Filter.errors:
        return m.status == 'error';
    }
  }

  bool _matchesQuery(Meeting m) {
    final q = _query.trim();
    if (q.isEmpty) return true;
    final nq = normalizeForSearch(q);
    final dateText = normalizeForSearch(DateFormat('d MMMM y', 'fr').format(m.date));
    return normalizeForSearch(m.title).contains(nq) ||
        dateText.contains(nq) ||
        (_contentMatches?.contains(m.id) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final meetings = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réunions'),
        actions: [
          IconButton(
            tooltip: 'Corbeille',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TrashScreen())),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Titre, participant, contenu, date...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _search.clear();
                  _onQueryChanged('');
                },
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            for (final f in _Filter.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_filterLabels[f]!),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                ),
              ),
          ]),
        ),
        Expanded(
          child: meetings.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur : $e')),
            data: (all) {
              final shown = all.where((m) => _matchesFilter(m) && _matchesQuery(m)).toList();
              if (shown.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      all.isEmpty
                          ? 'Aucune réunion pour le moment.'
                          : 'Aucune réunion ne correspond à cette recherche.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  for (final m in shown) MeetingTile(meeting: m),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Appui long sur une réunion : mettre à la corbeille.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}