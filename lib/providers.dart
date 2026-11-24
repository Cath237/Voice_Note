import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/app_database.dart';
import 'data/services/background_recording_service.dart';
import 'data/services/segmented_recorder_service.dart';

import 'data/services/context_manager_service.dart';
import 'data/services/openai_compatible_transcription_service.dart';
import 'data/services/transcript_merge_service.dart';
import 'data/services/transcription_queue_service.dart';
import 'data/services/transcription_settings.dart';
import 'domain/transcription_service.dart';

import 'data/services/document_service.dart';
import 'data/services/pdf_export_service.dart';
import 'data/services/share_service.dart';
import 'data/services/word_export_service.dart';

import 'data/services/llm_client.dart';
import 'data/services/summary_service.dart';
import 'data/services/recording_recovery_service.dart';
import 'data/services/trash_service.dart';

/// Une seule base de données pour toute l'application.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Flux des réunions : l'écran se met à jour tout seul à chaque changement.
final meetingsProvider = StreamProvider<List<Meeting>>(
      (ref) => ref.watch(dbProvider).watchMeetings(),
);


/// Thème de l'application : clair par défaut.
/// Le réglage « Mode sombre » des Paramètres le modifiera plus tard.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);


/// Un seul enregistreur pour toute l'application : il continue même si
/// l'écran d'enregistrement n'est plus affiché.
final recorderProvider = Provider<SegmentedRecorderService>((ref) {
  final recorder = SegmentedRecorderService(ref.watch(dbProvider));
  ref.onDispose(recorder.dispose);
  return recorder;
});

final backgroundServiceProvider =
Provider<BackgroundRecordingService>((ref) => BackgroundRecordingService()..init());


// ---------- Page d'une réunion ----------

final meetingProvider = StreamProvider.autoDispose.family<Meeting, String>(
      (ref, id) => ref.watch(dbProvider).watchMeeting(id),
);

final segmentsProvider = StreamProvider.autoDispose.family<List<AudioSegment>, String>(
      (ref, id) => ref.watch(dbProvider).watchSegments(id),
);

final notesProvider = StreamProvider.autoDispose.family<List<MeetingNote>, String>(
      (ref, id) => ref.watch(dbProvider).watchNotes(id),
);

final participantsProvider = StreamProvider.autoDispose.family<List<Participant>, String>(
      (ref, id) => ref.watch(dbProvider).watchParticipants(id),
);

final meetingContextProvider = FutureProvider.autoDispose.family<MeetingContext?, String>(
      (ref, id) => ref.watch(dbProvider).getContext(id),
);


// ---------- Transcription ----------

final transcriptionSettingsStoreProvider =
Provider<TranscriptionSettingsStore>((ref) => TranscriptionSettingsStore());

/// Pour changer de fournisseur un jour : retourner une autre implémentation ici.
final transcriptionServiceProvider = Provider<TranscriptionService>(
      (ref) => OpenAiCompatibleTranscriptionService(
      ref.watch(transcriptionSettingsStoreProvider)),
);

final transcriptionSettingsProvider = FutureProvider.autoDispose<TranscriptionSettings>(
      (ref) => ref.watch(transcriptionSettingsStoreProvider).load(),
);

final contextManagerProvider =
Provider<ContextManagerService>((ref) => ContextManagerService(ref.watch(dbProvider)));

final queueProvider = Provider<TranscriptionQueueService>((ref) => TranscriptionQueueService(
  db: ref.watch(dbProvider),
  stt: ref.watch(transcriptionServiceProvider),
  context: ref.watch(contextManagerProvider),
  merge: TranscriptMergeService(),
));

final transcriptProvider = StreamProvider.autoDispose.family<List<TranscriptSegment>, String>(
      (ref, id) => ref.watch(dbProvider).watchTranscript(id),
);


// ---------- Documents ----------

final shareProvider = Provider<ShareService>((ref) => ShareService());

final documentServiceProvider = Provider<DocumentService>(
      (ref) => DocumentService(ref.watch(dbProvider), WordExportService(), PdfExportService()),
);


// ---------- Résumé ----------

final llmClientProvider = Provider<LlmClient>(
      (ref) => LlmClient(ref.watch(transcriptionSettingsStoreProvider)),
);

final summaryServiceProvider = Provider<SummaryService>((ref) => SummaryService(
  ref.watch(dbProvider),
  ref.watch(llmClientProvider),
  ref.watch(transcriptionSettingsStoreProvider),
));


// ---------- Navigation, historique, corbeille ----------

/// Onglet affiché dans la barre du bas : 0 Accueil, 1 Réunions, 2 Documents, 3 Paramètres.
final navIndexProvider = StateProvider<int>((ref) => 0);

final transcriptionProgressProvider = StreamProvider<Map<String, double>>(
      (ref) => ref.watch(dbProvider).watchTranscriptionProgress(),
);

final trashProvider = StreamProvider.autoDispose<List<Meeting>>(
      (ref) => ref.watch(dbProvider).watchTrash(),
);

final trashServiceProvider =
Provider<TrashService>((ref) => TrashService(ref.watch(dbProvider)));

final recordingRecoveryProvider = Provider<RecordingRecoveryService>(
      (ref) => RecordingRecoveryService(ref.watch(dbProvider)),
);