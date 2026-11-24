import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../database/app_database.dart';

class RecoveryReport {
  final int recoveredMeetings;
  final int droppedSegments;
  const RecoveryReport(this.recoveredMeetings, this.droppedSegments);

  bool get any => recoveredMeetings > 0;
}

/// Après un arrêt brutal de l'application pendant un enregistrement :
/// - les segments déjà fermés sont intacts ;
/// - le segment qui était en cours est récupéré s'il est lisible (sa durée est relue
///   dans le fichier), sinon il est écarté ;
/// - la réunion repasse à « En attente » avec sa vraie durée.
class RecordingRecoveryService {
  RecordingRecoveryService(this._db);
  final AppDatabase _db;

  Future<RecoveryReport> recover() async {
    var dropped = 0;

    for (final seg in await _db.interruptedSegments()) {
      final ms = await _readableDurationMs(seg.filePath);
      if (ms > 0) {
        await _db.closeAudioSegment(seg.id, seg.startMs + ms);
      } else {
        // Fichier vide ou illisible. Le fichier reste sur le disque ;
        // il disparaîtra avec la réunion à la suppression définitive.
        await _db.deleteAudioSegment(seg.id);
        dropped++;
      }
    }

    var recovered = 0;
    for (final m in await _db.interruptedMeetings()) {
      final total = await _db.recordedDurationMs(m.id);
      await _db.finishRecording(m.id, total);
      recovered++;
    }
    return RecoveryReport(recovered, dropped);
  }

  Future<int> _readableDurationMs(String path) async {
    final file = File(path);
    if (!await file.exists() || await file.length() < 1024) return 0;
    final player = AudioPlayer();
    try {
      final d = await player.setFilePath(path).timeout(const Duration(seconds: 10));
      return d?.inMilliseconds ?? 0;
    } catch (_) {
      return 0;
    } finally {
      await player.dispose();
    }
  }
}