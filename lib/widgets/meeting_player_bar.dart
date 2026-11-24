import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/services/meeting_player.dart';

/// Lecteur : ▶/⏸, curseur, ↶10 s, 10 s ↷, vitesse 0.75x à 2x.
class MeetingPlayerBar extends StatefulWidget {
  final MeetingPlayer player;
  final int fallbackTotalMs; // durée de la réunion si les segments n'en donnent pas
  const MeetingPlayerBar({
    super.key,
    required this.player,
    required this.fallbackTotalMs,
  });

  @override
  State<MeetingPlayerBar> createState() => _MeetingPlayerBarState();
}

class _MeetingPlayerBarState extends State<MeetingPlayerBar> {
  static const _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
  int _speedIndex = 1;
  double? _drag; // position pendant que le doigt déplace le curseur

  int get _total => math.max(widget.player.totalMs, widget.fallbackTotalMs);

  Future<void> _skip(int deltaMs) async {
    final target = (widget.player.currentMs + deltaMs).clamp(0, _total);
    await widget.player.seekToMs(target);
  }

  Future<void> _cycleSpeed() async {
    setState(() => _speedIndex = (_speedIndex + 1) % _speeds.length);
    await widget.player.setSpeed(_speeds[_speedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final total = _total;
    final scheme = Theme.of(context).colorScheme;

    if (!player.hasAudio || total <= 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            StreamBuilder<int>(
              stream: player.positionMs,
              builder: (context, snap) {
                final pos = (_drag ?? (snap.data ?? 0).toDouble())
                    .clamp(0, total.toDouble());
                return Column(children: [
                  Slider(
                    value: pos.toDouble(),
                    max: total.toDouble(),
                    onChanged: (v) => setState(() => _drag = v),
                    onChangeEnd: (v) async {
                      await player.seekToMs(v.round());
                      if (mounted) setState(() => _drag = null);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(pos.round()),
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(formatDuration(total),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ]);
              },
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                onPressed: _cycleSpeed,
                child: Text('${_speeds[_speedIndex]}x'),
              ),
              IconButton(
                iconSize: 30,
                onPressed: () => _skip(-10000),
                icon: const Icon(Icons.replay_10_rounded),
              ),
              StreamBuilder<bool>(
                stream: player.isPlaying,
                builder: (context, snap) {
                  final playing = snap.data ?? false;
                  return IconButton.filled(
                    iconSize: 34,
                    padding: const EdgeInsets.all(12),
                    style: IconButton.styleFrom(backgroundColor: scheme.primary),
                    onPressed: player.toggle,
                    icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  );
                },
              ),
              IconButton(
                iconSize: 30,
                onPressed: () => _skip(10000),
                icon: const Icon(Icons.forward_10_rounded),
              ),
              const SizedBox(width: 48), // équilibre avec le bouton de vitesse
            ]),
          ]),
        ),
      ),
    );
  }
}