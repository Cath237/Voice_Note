import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/toast.dart';
import '../../providers.dart';
import '../../widgets/app_bottom_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../documents/documents_list_screen.dart';
import '../history/history_screen.dart';
import '../recording/new_meeting_screen.dart';
import '../settings/settings_screen.dart';

/// Cadre de l'application : écran actif + barre du bas + bouton « + ».
/// Au lancement, il récupère ce qu'une interruption a pu laisser en route.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startupChecks());
  }

  Future<void> _startupChecks() async {
    // 1) Enregistrement interrompu : on récupère l'audio sauvegardé.
    //    Si l'enregistreur est encore vivant (écran simplement recréé),
    //    on ne touche à rien.
    if (!ref.read(recorderProvider).isRecording) {
      final report = await ref.read(recordingRecoveryProvider).recover();
      if (report.any) {
        AppToast.show(
          report.droppedSegments > 0
              ? 'Enregistrement interrompu récupéré. Le tout dernier extrait, '
              'incomplet, n\'a pas pu être conservé.'
              : 'Enregistrement interrompu récupéré : l\'audio sauvegardé est conservé.',
          type: ToastType.warning,
          duration: const Duration(seconds: 6),
        );
      }
    }

    // 2) Transcription interrompue : les segments « en cours » redeviennent « en attente ».
    final queue = ref.read(queueProvider);
    if (queue.running.value.isEmpty) await queue.recoverAfterCrash();

    // 3) Proposer de reprendre une transcription incomplète.
    await _offerResume();
  }

  Future<void> _offerResume() async {
    final settings = await ref.read(transcriptionSettingsStoreProvider).load();
    if (!settings.isReady || !mounted) return;

    final queue = ref.read(queueProvider);
    final pending = (await ref.read(dbProvider).incompleteTranscriptions())
        .where((i) => !queue.running.value.contains(i.meeting.id))
        .toList();
    if (pending.isEmpty || !mounted) return;

    final first = pending.first;
    final percent = (first.done * 100 / first.total).round();
    final last = first.lastDoneNumber == null
        ? null
        : 'segment_${first.lastDoneNumber.toString().padLeft(3, '0')}';

    final resume = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Une transcription est incomplète'),
        content: Text(
          'Réunion : ${first.meeting.title}\n'
              '${last == null ? '' : 'Dernier segment traité : $last\n'}'
              'Progression : $percent %'
              '${pending.length > 1 ? '\n\n(${pending.length - 1} autre(s) réunion(s) dans le même cas)' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Plus tard')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    );
    if (resume == true) {
      queue.retry(first.meeting.id); // sans attendre la fin
      AppToast.show('Transcription reprise', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navIndexProvider);
    return Scaffold(
      // IndexedStack garde chaque écran en vie : recherche et filtres conservés.
      body: IndexedStack(
        index: index,
        children: const [
          DashboardScreen(),
          HistoryScreen(),
          DocumentsListScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewMeetingScreen())),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomBar(
        currentIndex: index,
        onSelect: (i) => ref.read(navIndexProvider.notifier).state = i,
      ),
    );
  }
}