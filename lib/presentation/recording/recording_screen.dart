import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers.dart';

import '../../data/services/app_settings.dart';

import '../../core/utils/toast.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const RecordingScreen({super.key, required this.meetingId});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  static const _barCount = 40;

  final List<double> _levels = List.filled(_barCount, 0.0);
  StreamSubscription? _ampSub;
  String _title = '';
  bool _ready = false;
  String? _error;

  late final _rec = ref.read(recorderProvider);

  @override
  void initState() {
    super.initState();
    _begin();
  }

  Future<void> _begin() async {
    try {
      final db = ref.read(dbProvider);
      final meeting = await (db.select(db.meetings)
        ..where((m) => m.id.equals(widget.meetingId)))
          .getSingle();
      _title = meeting.title;

      final bg = ref.read(backgroundServiceProvider);
      final alreadyRunning =
          _rec.isRecording && _rec.meetingId == widget.meetingId;
      if (!alreadyRunning) {
        await bg.start(_title);
        final prefs = ref.read(appSettingsProvider);
        await _rec.start(widget.meetingId,
            mode: prefs.segmentation, highQuality: prefs.highQuality);
      }

      _rec.onTick = (ms) {
        // La notification affiche la durée, mise à jour toutes les 5 secondes.
        if (ms % 5000 < 1000) bg.updateDuration(_title, formatDuration(ms));
      };

      _ampSub = _rec.amplitude().listen((a) {
        if (!mounted) return;
        final level =
        _rec.paused.value ? 0.0 : ((a.current + 60) / 60).clamp(0.0, 1.0);
        setState(() {
          _levels.removeAt(0);
          _levels.add(level);
        });
      });

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      await ref.read(dbProvider).setMeetingStatus(widget.meetingId, 'error');
      await ref.read(backgroundServiceProvider).stop();
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    // On n'arrête PAS l'enregistrement ici : il appartient au service.
    _ampSub?.cancel();
    super.dispose();
  }

  // ---------- Actions ----------

  Future<void> _togglePause() async {
    _rec.paused.value ? await _rec.resume() : await _rec.pause();
  }

  Future<void> _addNote() async {
    final timestamp = _rec.elapsedMs; // l'instant où on appuie, pas où on valide
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Note · ${formatDuration(timestamp)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
              hintText: 'Vérifier le contrat avec le fournisseur'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    await ref.read(dbProvider).addNote(
        meetingId: widget.meetingId,
        timestampMs: timestamp,
        type: MarkerType.note.name,
        content: text);
    _toast('Note ajoutée · ${formatDuration(timestamp)}');
  }

  Future<void> _addMarker() async {
    final timestamp = _rec.elapsedMs;
    final choice = await showModalBottomSheet<(MarkerType, String)>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final (type, label) in [
            (MarkerType.important, '⭐  Important'),
            (MarkerType.decision, '✅  Décision'),
            (MarkerType.verify, '⚠️  À vérifier'),
            (MarkerType.action, '📌  Action'),
            (MarkerType.question, '❓  Question'),
          ])
            ListTile(title: Text(label), onTap: () => Navigator.pop(c, (type, label))),
        ]),
      ),
    );
    if (choice == null) return;
    await ref.read(dbProvider).addNote(
        meetingId: widget.meetingId,
        timestampMs: timestamp,
        type: choice.$1.name);
    _toast('${choice.$2.trim()} · ${formatDuration(timestamp)}');
  }

  Future<void> _stop() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arrêter la réunion ?'),
        content: const Text('L\'audio enregistré est conservé sur votre téléphone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Continuer')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.recordRed, minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Arrêter'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final total = await _rec.stop();
    await ref.read(backgroundServiceProvider).stop();
    // Lance la transcription seulement si le service est configuré et autorisé.
    final settings = await ref.read(transcriptionSettingsStoreProvider).load();
    if (settings.isReady) {
      ref.read(queueProvider).run(widget.meetingId); // sans attendre la fin
    }
    if (!mounted) return;
    AppToast.show('Réunion enregistrée · ${formatDuration(total)}');
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _toast(String message) {
    if (!mounted) return;
    AppToast.show(message);
  }

  // ---------- Écran ----------

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _toast('Appuyez sur « Arrêter » pour terminer la réunion');
      },
      child: Scaffold(
        backgroundColor: AppColors.deepBlue,
        body: SafeArea(
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: _buildRecorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecorder() {
    return ValueListenableBuilder<bool>(
      valueListenable: _rec.paused,
      builder: (context, isPaused, _) => Column(
        children: [
          Text(_title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.fiber_manual_record,
                size: 14, color: isPaused ? Colors.grey : AppColors.recordRed),
            const SizedBox(width: 6),
            Text(isPaused ? 'EN PAUSE' : 'ENREGISTREMENT',
                style: TextStyle(
                    color: isPaused ? Colors.white54 : AppColors.recordRed,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: _rec.elapsed,
            builder: (context, ms, _) => Column(children: [
              Text(formatDuration(ms),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(height: 4),
              Text(
                  'Segment ${_rec.segmentNumber} · ≈ ${(ms / 1000 * 8000 / 1000000).toStringAsFixed(1)} Mo',
                  style: const TextStyle(color: Colors.white54)),
            ]),
          ),
          const SizedBox(height: 28),
          _Waveform(levels: _levels),
          const Spacer(),
          IconButton.filled(
            iconSize: 44,
            padding: const EdgeInsets.all(18),
            style: IconButton.styleFrom(backgroundColor: AppColors.blue),
            onPressed: _togglePause,
            icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(isPaused ? 'Reprendre' : 'Pause',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: _lightButton(Icons.edit_note_rounded, 'Note', _addNote)),
            const SizedBox(width: 12),
            Expanded(child: _lightButton(Icons.bookmark_border_rounded, 'Marqueur', _addMarker)),
          ]),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.recordRed),
            onPressed: _stop,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Arrêter'),
          ),
        ],
      ),
    );
  }

  Widget _lightButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: AppColors.recordRed, size: 48),
            const SizedBox(height: 16),
            const Text('Impossible de démarrer l\'enregistrement',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Retour'),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Barres du niveau sonore : les plus récentes sont à droite.
class _Waveform extends StatelessWidget {
  final List<double> levels;
  const _Waveform({required this.levels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final l in levels)
            Container(
              width: 4,
              height: 6 + l * 80,
              decoration: BoxDecoration(
                color: AppColors.turquoise,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}