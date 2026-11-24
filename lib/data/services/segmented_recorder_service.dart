import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../database/app_database.dart';

/// Moteur 1 : l'enregistreur local.
/// Il ne dépend NI d'Internet NI de la transcription.
///
/// Limite connue : le passage d'un segment au suivant (stop puis start)
/// coupe l'audio pendant quelques dizaines de millisecondes. C'est acceptable
/// pour de la parole.
class SegmentedRecorderService {
  SegmentedRecorderService(this._db);

  final AppDatabase _db;
  final AudioRecorder _rec = AudioRecorder();
  final _uuid = const Uuid();

  /// Écoutés par l'écran pour se mettre à jour.
  final ValueNotifier<int> elapsed = ValueNotifier(0);
  final ValueNotifier<bool> paused = ValueNotifier(false);

  /// Appelée chaque seconde (sert à mettre à jour la notification).
  void Function(int elapsedMs)? onTick;

  String? _meetingId;
  late Directory _audioDir;
  Duration _segmentLength = const Duration(minutes: 5);
  int _segmentNo = 0;
  int _segmentStartMs = 0;
  String? _segmentId;
  final Stopwatch _clock = Stopwatch(); // temps réellement enregistré, hors pauses
  Timer? _ticker;
  bool _rotating = false;
  bool _highQuality = false;

  bool get isRecording => _meetingId != null;
  String? get meetingId => _meetingId;
  int get elapsedMs => _clock.elapsedMilliseconds;
  int get segmentNumber => _segmentNo;

  Stream<Amplitude> amplitude() =>
      _rec.onAmplitudeChanged(const Duration(milliseconds: 120));

  Future<void> start(String meetingId,
      {SegmentationMode mode = SegmentationMode.auto, bool highQuality = false}) async {
    if (isRecording) throw StateError('Un enregistrement est déjà en cours');

    final docs = await getApplicationDocumentsDirectory();
    _audioDir = Directory(p.join(docs.path, 'meetings', meetingId, 'audio'));
    await _audioDir.create(recursive: true);

    _meetingId = meetingId;
    _segmentLength = mode.duration;
    _highQuality = highQuality;
    _segmentNo = 0;
    _segmentStartMs = 0;
    paused.value = false;
    elapsed.value = 0;

    try {
      await _openSegment();
    } catch (e) {
      _meetingId = null;
      rethrow;
    }
    _clock
      ..reset()
      ..start();
    await _db.setMeetingStatus(meetingId, 'recording');
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  /// Crée la ligne en base AVANT d'enregistrer : si l'application plante,
  /// le fichier audio est déjà connu et pourra être récupéré.
  Future<void> _openSegment() async {
    _segmentNo++;
    _segmentId = _uuid.v4();
    final path = p.join(
        _audioDir.path, 'segment_${_segmentNo.toString().padLeft(3, '0')}.m4a');

    await _db.addAudioSegment(AudioSegmentsCompanion.insert(
      id: _segmentId!,
      meetingId: _meetingId!,
      segmentNumber: _segmentNo,
      startMs: _segmentStartMs,
      endMs: _segmentStartMs,
      filePath: path,
      status: const Value('recording'),
    ));

    await _rec.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: _highQuality ? 128000 : 64000, // parole : ~29 Mo/h en standard
        sampleRate: _highQuality ? 44100 : 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<void> _closeSegment() async {
    await _rec.stop();
    final endMs = _clock.elapsedMilliseconds;
    if (_segmentId != null) {
      await _db.closeAudioSegment(_segmentId!, endMs);
    }
    _segmentStartMs = endMs;
  }

  Future<void> _onTick() async {
    final ms = _clock.elapsedMilliseconds;
    elapsed.value = ms;
    onTick?.call(ms);

    if (paused.value || _meetingId == null) return;

    // Sauvegarde régulière de la durée (utile en cas de plantage).
    if (ms ~/ 1000 % 10 == 0) {
      await _db.updateMeetingDuration(_meetingId!, ms);
    }

    // Segment suivant ?
    if (!_rotating && ms - _segmentStartMs >= _segmentLength.inMilliseconds) {
      _rotating = true;
      try {
        await _closeSegment();
        await _openSegment();
      } finally {
        _rotating = false;
      }
    }
  }

  Future<void> pause() async {
    if (!isRecording || paused.value) return;
    paused.value = true;
    _clock.stop();
    await _rec.pause();
    await _db.setMeetingStatus(_meetingId!, 'paused');
  }

  Future<void> resume() async {
    if (!isRecording || !paused.value) return;
    await _rec.resume();
    _clock.start();
    paused.value = false;
    await _db.setMeetingStatus(_meetingId!, 'recording');
  }

  /// Termine la réunion. Retourne la durée totale en millisecondes.
  Future<int> stop() async {
    final id = _meetingId;
    if (id == null) return 0;
    _ticker?.cancel();
    while (_rotating) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await _closeSegment();
    _clock.stop();
    final total = _clock.elapsedMilliseconds;
    elapsed.value = total;
    _meetingId = null;
    paused.value = false;
    await _db.finishRecording(id, total);
    return total;
  }

  Future<void> dispose() async {
    _ticker?.cancel();
    await _rec.dispose();
  }
}