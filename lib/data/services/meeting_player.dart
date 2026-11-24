import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../database/app_database.dart';

/// Lit les segments d'une réunion comme UN SEUL enregistrement continu.
/// Les positions sont exprimées en millisecondes depuis le début de la réunion :
/// c'est le même repère que les notes et, plus tard, la transcription.
class MeetingPlayer {
  final AudioPlayer _player = AudioPlayer();
  List<AudioSegment> _segments = [];
  String _signature = '';

  bool get hasAudio => _segments.isNotEmpty;

  /// Durée totale d'après les segments (fin du dernier segment).
  int get totalMs => _segments.isEmpty ? 0 : _segments.last.endMs;

  /// Recharge seulement si la liste des segments a réellement changé,
  /// pour ne pas interrompre la lecture à chaque mise à jour de la base.
  Future<void> load(List<AudioSegment> segments) async {
    final usable = segments
        .where((s) => s.status != 'recording' && File(s.filePath).existsSync())
        .toList()
      ..sort((a, b) => a.segmentNumber.compareTo(b.segmentNumber));

    final signature = usable.map((s) => '${s.id}:${s.endMs}').join('|');
    if (signature == _signature) return;
    _signature = signature;
    _segments = usable;
    if (usable.isEmpty) return;

    await _player.setAudioSource(ConcatenatingAudioSource(
      children: [for (final s in usable) AudioSource.file(s.filePath)],
    ));
  }

  int _toGlobal(Duration position) {
    if (_segments.isEmpty) return 0;
    final i = (_player.currentIndex ?? 0).clamp(0, _segments.length - 1);
    return _segments[i].startMs + position.inMilliseconds;
  }

  int get currentMs => _toGlobal(_player.position);

  Stream<int> get positionMs => _player.positionStream.map(_toGlobal);

  Stream<bool> get isPlaying => _player.playerStateStream
      .map((s) => s.playing && s.processingState != ProcessingState.completed);

  Future<void> seekToMs(int ms) async {
    if (_segments.isEmpty) return;
    var index = 0;
    for (var i = 0; i < _segments.length; i++) {
      if (_segments[i].startMs <= ms) index = i;
    }
    final offset = (ms - _segments[index].startMs).clamp(0, 1 << 31);
    await _player.seek(Duration(milliseconds: offset), index: index);
  }

  Future<void> play() async {
    if (_segments.isEmpty) return;
    if (_player.processingState == ProcessingState.completed) await seekToMs(0);
    // Pas de await : play() ne se termine qu'à la fin de la lecture.
    unawaited(_player.play());
  }

  Future<void> pause() => _player.pause();

  Future<void> toggle() => _player.playing ? pause() : play();

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> dispose() => _player.dispose();
}