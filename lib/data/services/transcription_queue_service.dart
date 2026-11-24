import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../domain/transcription_service.dart';
import '../database/app_database.dart';
import 'context_manager_service.dart';
import 'transcript_merge_service.dart';

enum _Outcome { ok, retry, permanent }

/// Moteur 2. L'état de la file vit dans la base (pas en mémoire) :
/// fermer l'application ne fait perdre aucun segment, et on reprend au
/// dernier segment non traité, jamais depuis le début.
class TranscriptionQueueService {
  TranscriptionQueueService({
    required this.db,
    required this.stt,
    required this.context,
    required this.merge,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final AppDatabase db;
  final TranscriptionService stt;
  final ContextManagerService context;
  final TranscriptMergeService merge;
  final Connectivity _connectivity;
  final _uuid = const Uuid();

  /// Observés par l'écran.
  final ValueNotifier<Set<String>> running = ValueNotifier({});
  final ValueNotifier<bool> waitingForNetwork = ValueNotifier(false);

  /// À appeler au démarrage de l'application.
  Future<void> recoverAfterCrash() => db.resetStuckSegments();

  /// Bouton « Reprendre » : remet les échecs à zéro puis relance.
  Future<void> retry(String meetingId) async {
    await db.resetFailedSegments(meetingId);
    await run(meetingId);
  }

  Future<bool> _online() async {
    final r = await _connectivity.checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  Future<void> run(String meetingId) async {
    if (running.value.contains(meetingId)) return; // déjà en cours
    running.value = {...running.value, meetingId};
    try {
      final meeting = await db.getMeeting(meetingId);
      if (meeting == null) return;
      if (meeting.status == 'recording' || meeting.status == 'paused') return;

      final languageHint = meeting.language == 'auto' ? null : meeting.language;
      await context.ensure(meetingId);
      await db.setMeetingStatus(meetingId, 'transcribing');

      while (true) {
        // Pas de réseau : l'enregistrement n'est pas concerné, on attend ici.
        if (stt.sendsAudioToExternalService && !await _online()) {
          waitingForNetwork.value = true;
          await _connectivity.onConnectivityChanged
              .firstWhere((r) => !r.contains(ConnectivityResult.none));
          waitingForNetwork.value = false;
        }

        final seg = await db.nextSegmentToProcess(meetingId);
        if (seg == null) break;

        final outcome = await _process(seg, languageHint);
        if (outcome == _Outcome.retry) {
          // Attente croissante : 4, 8, 16, 32 secondes...
          await Future.delayed(Duration(seconds: 2 << seg.retryCount.clamp(0, 5)));
        }
      }
      await _finalize(meetingId);
    } finally {
      waitingForNetwork.value = false;
      running.value = {...running.value}..remove(meetingId);
    }
  }

  Future<_Outcome> _process(AudioSegment seg, String? languageHint) async {
    await db.updateSegmentStatus(seg.id, 'processing', touch: true);
    try {
      final prompt = await context.buildPrompt(seg.meetingId);
      final result = await stt.transcribeSegment(
        seg.filePath,
        TranscriptionHints(languageHint: languageHint, prompt: prompt),
      );

      final previous = await db.lastTranscriptBefore(seg.meetingId, seg.startMs);
      var tail = previous?.content ?? '';
      final rows = <TranscriptSegmentsCompanion>[];
      final allText = StringBuffer();
      String? mergeIntoId;
      String? mergedText;
      int? mergedEndMs;
      var first = true;

      for (final c in result.chunks) {
        if (c.isLikelySilence) continue;
        final text = merge.removeOverlap(tail, c.text);
        if (text.isEmpty) continue;

        final start = seg.startMs + c.startMs; // temps absolu = lien avec l'audio
        final end = seg.startMs + c.endMs;
        allText.write('$text ');

        // Phrase coupée entre deux segments : on la recolle.
        if (first &&
            previous != null &&
            !previous.edited &&
            merge.isContinuation(previous.content, text)) {
          mergeIntoId = previous.id;
          mergedText = '${previous.content.trimRight()} $text';
          mergedEndMs = end;
          tail = mergedText;
        } else {
          rows.add(TranscriptSegmentsCompanion.insert(
            id: _uuid.v4(),
            meetingId: seg.meetingId,
            audioSegmentId: seg.id,
            startMs: start,
            endMs: end,
            content: text,
            speakerId: Value(c.speakerId),
            language: Value(c.language),
          ));
          tail = text;
        }
        first = false;
      }

      await db.saveSegmentTranscript(
        audioSegmentId: seg.id,
        rows: rows,
        mergeIntoId: mergeIntoId,
        mergedText: mergedText,
        mergedEndMs: mergedEndMs,
      );
      await context.updateFromText(seg.meetingId, allText.toString());
      await db.updateSegmentStatus(seg.id, 'completed');
      return _Outcome.ok;
    } on TranscriptionException catch (e) {
      return _fail(seg, e.message, retryable: e.retryable);
    } catch (e) {
      return _fail(seg, e.toString(), retryable: true);
    }
  }

  Future<_Outcome> _fail(AudioSegment seg, String message, {required bool retryable}) async {
    final attempts = seg.retryCount + 1;
    final permanent = !retryable || attempts >= kMaxRetries;
    await db.updateSegmentStatus(
      seg.id,
      permanent ? 'failed' : 'retrying',
      retryCount: attempts,
      errorMessage: message,
      touch: true,
    );
    return permanent ? _Outcome.permanent : _Outcome.retry;
  }

  Future<void> _finalize(String meetingId) async {
    final segments = await (db.select(db.audioSegments)
      ..where((s) => s.meetingId.equals(meetingId)))
        .get();
    final allDone = segments.isNotEmpty && segments.every((s) => s.status == 'completed');
    final anyFailed = segments.any((s) => s.status == 'failed');
    await db.setMeetingStatus(
        meetingId, allDone ? 'completed' : (anyFailed ? 'error' : 'recorded'));
  }
}