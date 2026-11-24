import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../core/utils/toast.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  void _toast(BuildContext context, String message) => AppToast.show(message);

  Future<bool> _confirm(BuildContext context, String title, String body, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.recordRed, minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deleteForever(BuildContext context, WidgetRef ref, Meeting m) async {
    if (ref.read(queueProvider).running.value.contains(m.id)) {
      _toast(context, 'Transcription en cours : réessayez dans un instant');
      return;
    }
    final ok = await _confirm(
      context,
      'Supprimer définitivement ?',
      '« ${m.title} » sera effacée pour toujours : audio, transcription, notes, '
          'résumé et documents exportés. Cette action est irréversible.',
      'Supprimer',
    );
    if (!ok || !context.mounted) return;
    await ref.read(trashServiceProvider).deletePermanently(m.id);
    if (context.mounted) _toast(context, 'Réunion supprimée définitivement');
  }

  Future<void> _empty(BuildContext context, WidgetRef ref, int count) async {
    final ok = await _confirm(
      context,
      'Vider la corbeille ?',
      '$count réunion${count > 1 ? 's' : ''} sera${count > 1 ? 'ont' : ''} effacée'
          '${count > 1 ? 's' : ''} pour toujours, avec leur audio et leurs documents. '
          'Cette action est irréversible.',
      'Vider',
    );
    if (!ok || !context.mounted) return;
    final skip = ref.read(queueProvider).running.value;
    final deleted = await ref.read(trashServiceProvider).emptyTrash(skip: skip);
    if (context.mounted) {
      _toast(context, deleted == count
          ? 'Corbeille vidée'
          : '$deleted supprimée(s) : une transcription est encore en cours pour les autres');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(trashProvider);
    final items = trash.valueOrNull ?? const <Meeting>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corbeille'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _empty(context, ref, items.length),
              child: const Text('Vider', style: TextStyle(color: AppColors.recordRed)),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('La corbeille est vide.', textAlign: TextAlign.center),
        ),
      )
          : ListView(padding: const EdgeInsets.all(16), children: [
        for (final m in items)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${formatDay(m.date)} · ${formatDuration(m.durationMs)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  tooltip: 'Restaurer',
                  icon: const Icon(Icons.restore),
                  onPressed: () async {
                    await ref.read(dbProvider).restore(m.id);
                    if (context.mounted) _toast(context, 'Réunion restaurée');
                  },
                ),
                IconButton(
                  tooltip: 'Supprimer définitivement',
                  icon: const Icon(Icons.delete_forever, color: AppColors.recordRed),
                  onPressed: () => _deleteForever(context, ref, m),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}