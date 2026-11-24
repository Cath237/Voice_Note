import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Une réunion = une ligne. Les segments audio et la transcription
/// sont dans leurs propres tables, liés par meetingId.
class Meetings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category =>
      text().withDefault(const Constant('Réunion professionnelle'))();
  TextColumn get location => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get language => text().withDefault(const Constant('auto'))();
  // recording | paused | recorded | transcribing | completed | error
  TextColumn get status => text().withDefault(const Constant('recording'))();
  TextColumn get summaryJson => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // corbeille
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Participants extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(Meetings, #id)();
  TextColumn get name => text()();
  TextColumn get speakerIdentifier => text().nullable()(); // ex : speaker_02

  @override
  Set<Column> get primaryKey => {id};
}

class AudioSegments extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(Meetings, #id)();
  IntColumn get segmentNumber => integer()();
  IntColumn get startMs => integer()(); // position dans la réunion
  IntColumn get endMs => integer()();
  TextColumn get filePath => text()();
  // pending | processing | completed | failed | retrying
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TranscriptSegments extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(Meetings, #id)();
  TextColumn get audioSegmentId => text().references(AudioSegments, #id)();
  TextColumn get speakerId => text().nullable()();
  IntColumn get startMs => integer()(); // lien vers l'audio original
  IntColumn get endMs => integer()();
  TextColumn get language => text().withDefault(const Constant('unknown'))();
  TextColumn get content => text()();
  BoolColumn get edited => boolean().withDefault(const Constant(false))();
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MeetingContexts extends Table {
  TextColumn get meetingId => text().references(Meetings, #id)();
  TextColumn get dictionaryJson => text().withDefault(const Constant('[]'))();
  TextColumn get entitiesJson => text().withDefault(const Constant('[]'))();
  TextColumn get topicsJson => text().withDefault(const Constant('[]'))();
  TextColumn get decisionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get contextSummary => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {meetingId};
}

class MeetingNotes extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(Meetings, #id)();
  IntColumn get timestampMs => integer()();
  TextColumn get content => text().withDefault(const Constant(''))();
  // note | important | decision | verify | action | question
  TextColumn get type => text().withDefault(const Constant('note'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Meetings,
  Participants,
  AudioSegments,
  TranscriptSegments,
  MeetingContexts,
  MeetingNotes,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'voicenote'));

  @override
  int get schemaVersion => 1;

  // ---------- Réunions ----------

  /// Réunions non supprimées, la plus récente en premier.
  Stream<List<Meeting>> watchMeetings() => (select(meetings)
    ..where((m) => m.deletedAt.isNull())
    ..orderBy([(m) => OrderingTerm.desc(m.date)]))
      .watch();

  Stream<List<Meeting>> watchTrash() =>
      (select(meetings)..where((m) => m.deletedAt.isNotNull())).watch();

  /// Envoie à la corbeille (rien n'est effacé).
  Future<void> moveToTrash(String id) =>
      (update(meetings)..where((m) => m.id.equals(id)))
          .write(MeetingsCompanion(deletedAt: Value(DateTime.now())));

  Future<void> restore(String id) =>
      (update(meetings)..where((m) => m.id.equals(id)))
          .write(const MeetingsCompanion(deletedAt: Value(null)));

  Future<void> insertMeeting(MeetingsCompanion meeting) =>
      into(meetings).insert(meeting);

  /// Crée la réunion, ses participants et son dictionnaire en une seule opération :
  /// tout est enregistré, ou rien.
  Future<void> createMeeting({
    required String id,
    required String title,
    required String description,
    required String location,
    required String category,
    required String language,
    required DateTime date,
    required List<String> participantNames,
    required List<String> dictionary,
  }) =>
      transaction(() async {
        final now = DateTime.now();
        await into(meetings).insert(MeetingsCompanion.insert(
          id: id,
          title: title,
          date: date,
          createdAt: now,
          updatedAt: now,
          description: Value(description),
          location: Value(location),
          category: Value(category),
          language: Value(language),
        ));
        for (final name in participantNames) {
          await into(participants).insert(ParticipantsCompanion.insert(
            id: const Uuid().v4(),
            meetingId: id,
            name: name,
          ));
        }
        await into(meetingContexts).insert(MeetingContextsCompanion.insert(
          meetingId: id,
          dictionaryJson: Value(jsonEncode(dictionary)),
        ));
      });

  Future<void> setMeetingStatus(String id, String status) =>
      (update(meetings)..where((m) => m.id.equals(id))).write(
          MeetingsCompanion(status: Value(status), updatedAt: Value(DateTime.now())));

  // ---------- Enregistrement ----------

  Future<void> addAudioSegment(AudioSegmentsCompanion segment) =>
      into(audioSegments).insert(segment);

  /// Segment terminé : on note sa fin et on le met en file pour la transcription.
  Future<void> closeAudioSegment(String id, int endMs) =>
      (update(audioSegments)..where((s) => s.id.equals(id))).write(
          AudioSegmentsCompanion(endMs: Value(endMs), status: const Value('pending')));

  Future<void> updateMeetingDuration(String id, int ms) =>
      (update(meetings)..where((m) => m.id.equals(id)))
          .write(MeetingsCompanion(durationMs: Value(ms)));

  Future<void> finishRecording(String id, int totalMs) =>
      (update(meetings)..where((m) => m.id.equals(id))).write(MeetingsCompanion(
        durationMs: Value(totalMs),
        status: const Value('recorded'),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> addNote({
    required String meetingId,
    required int timestampMs,
    required String type,
    String content = '',
  }) =>
      into(meetingNotes).insert(MeetingNotesCompanion.insert(
        id: const Uuid().v4(),
        meetingId: meetingId,
        timestampMs: timestampMs,
        content: Value(content),
        type: Value(type),
      ));

  /// À appeler au démarrage de l'application : si elle a été fermée ou a planté
  /// pendant un enregistrement, les segments déjà sur le disque sont conservés
  /// et la réunion passe à « En attente ».
  Future<void> recoverInterruptedRecordings() => transaction(() async {
    await (update(audioSegments)..where((s) => s.status.equals('recording')))
        .write(const AudioSegmentsCompanion(status: Value('pending')));
    await (update(meetings)..where((m) => m.status.isIn(['recording', 'paused'])))
        .write(const MeetingsCompanion(status: Value('recorded')));
  });

  // ---------- Lecture ----------

  Stream<Meeting> watchMeeting(String id) =>
      (select(meetings)..where((m) => m.id.equals(id))).watchSingle();

  Stream<List<AudioSegment>> watchSegments(String meetingId) =>
      (select(audioSegments)
        ..where((s) => s.meetingId.equals(meetingId))
        ..orderBy([(s) => OrderingTerm.asc(s.segmentNumber)]))
          .watch();

  Stream<List<MeetingNote>> watchNotes(String meetingId) => (select(meetingNotes)
    ..where((n) => n.meetingId.equals(meetingId))
    ..orderBy([(n) => OrderingTerm.asc(n.timestampMs)]))
      .watch();

  Future<List<Participant>> getParticipants(String meetingId) =>
      (select(participants)..where((p) => p.meetingId.equals(meetingId))).get();

  Future<MeetingContext?> getContext(String meetingId) =>
      (select(meetingContexts)..where((c) => c.meetingId.equals(meetingId)))
          .getSingleOrNull();

  Future<void> deleteNote(String id) =>
      (delete(meetingNotes)..where((n) => n.id.equals(id))).go();

  // ---------- File de transcription ----------

  Future<Meeting?> getMeeting(String id) =>
      (select(meetings)..where((m) => m.id.equals(id))).getSingleOrNull();

  /// Prochain segment à traiter, TOUJOURS dans l'ordre : le contexte du
  /// segment N dépend du texte du segment N-1.
  Future<AudioSegment?> nextSegmentToProcess(String meetingId) =>
      (select(audioSegments)
        ..where((s) =>
        s.meetingId.equals(meetingId) &
        s.status.isIn(['pending', 'retrying']))
        ..orderBy([(s) => OrderingTerm.asc(s.segmentNumber)])
        ..limit(1))
          .getSingleOrNull();

  Future<void> updateSegmentStatus(
      String id,
      String status, {
        int? retryCount,
        String? errorMessage,
        bool touch = false,
      }) =>
      (update(audioSegments)..where((s) => s.id.equals(id))).write(
        AudioSegmentsCompanion(
          status: Value(status),
          retryCount: retryCount == null ? const Value.absent() : Value(retryCount),
          errorMessage: Value(errorMessage), // null efface l'ancien message
          lastAttempt: touch ? Value(DateTime.now()) : const Value.absent(),
        ),
      );

  /// Bouton « Reprendre » : les segments en échec repartent à zéro.
  Future<void> resetFailedSegments(String meetingId) => (update(audioSegments)
    ..where((s) =>
    s.meetingId.equals(meetingId) & s.status.isIn(['failed', 'retrying'])))
      .write(const AudioSegmentsCompanion(
    status: Value('pending'),
    retryCount: Value(0),
    errorMessage: Value(null),
  ));

  /// Après un plantage : un segment « processing » n'est plus réellement en cours.
  Future<void> resetStuckSegments() =>
      (update(audioSegments)..where((s) => s.status.equals('processing')))
          .write(const AudioSegmentsCompanion(status: Value('pending')));

  Stream<List<TranscriptSegment>> watchTranscript(String meetingId) =>
      (select(transcriptSegments)
        ..where((t) => t.meetingId.equals(meetingId))
        ..orderBy([(t) => OrderingTerm.asc(t.startMs)]))
          .watch();

  /// Nombre de lignes de transcription d'une réunion (sans les charger).
  Future<int> transcriptLineCount(String meetingId) async {
    final count = transcriptSegments.id.count();
    final query = selectOnly(transcriptSegments)
      ..addColumns([count])
      ..where(transcriptSegments.meetingId.equals(meetingId));
    return (await query.map((row) => row.read(count)).getSingle()) ?? 0;
  }

  /// Enregistre (ou efface, avec null) le résumé d'une réunion.
  Future<void> saveSummaryJson(String meetingId, String? json) =>
      (update(meetings)..where((m) => m.id.equals(meetingId))).write(
        MeetingsCompanion(summaryJson: Value(json), updatedAt: Value(DateTime.now())),
      );

  // ---------- Historique et corbeille ----------

  Future<List<Meeting>> getTrash() =>
      (select(meetings)..where((m) => m.deletedAt.isNotNull())).get();

  /// Progression de la transcription par réunion, de 0.0 à 1.0.
  Stream<Map<String, double>> watchTranscriptionProgress() =>
      select(audioSegments).watch().map((rows) {
        final total = <String, int>{};
        final done = <String, int>{};
        for (final s in rows) {
          total[s.meetingId] = (total[s.meetingId] ?? 0) + 1;
          if (s.status == 'completed') done[s.meetingId] = (done[s.meetingId] ?? 0) + 1;
        }
        return {
          for (final e in total.entries) e.key: (done[e.key] ?? 0) / e.value,
        };
      });

  /// Réunions dont le titre, la description, le lieu, un participant ou la
  /// transcription contiennent [query].
  Future<Set<String>> meetingIdsMatching(String query) async {
    final clean = query.replaceAll('%', '').replaceAll('_', '');
    if (clean.isEmpty) return {};
    final like = '%$clean%';
    final ids = <String>{};

    final meta = await (select(meetings)
      ..where((m) => m.title.like(like) | m.description.like(like) | m.location.like(like)))
        .get();
    ids.addAll(meta.map((m) => m.id));

    final people = await (select(participants)..where((p) => p.name.like(like))).get();
    ids.addAll(people.map((p) => p.meetingId));

    final text = await (selectOnly(transcriptSegments, distinct: true)
      ..addColumns([transcriptSegments.meetingId])
      ..where(transcriptSegments.content.like(like)))
        .map((row) => row.read(transcriptSegments.meetingId)!)
        .get();
    ids.addAll(text);
    return ids;
  }

  // ---------- Reprise après interruption ----------

  Future<List<AudioSegment>> interruptedSegments() =>
      (select(audioSegments)..where((s) => s.status.equals('recording'))).get();

  Future<void> deleteAudioSegment(String id) =>
      (delete(audioSegments)..where((s) => s.id.equals(id))).go();

  Future<List<Meeting>> interruptedMeetings() =>
      (select(meetings)..where((m) => m.status.isIn(['recording', 'paused']))).get();

  /// Durée réellement enregistrée = fin du dernier segment.
  Future<int> recordedDurationMs(String meetingId) async {
    final segs = await (select(audioSegments)
      ..where((s) => s.meetingId.equals(meetingId)))
        .get();
    return segs.fold<int>(0, (best, s) => s.endMs > best ? s.endMs : best);
  }

  /// Transcriptions déjà commencées mais pas terminées.
  Future<List<IncompleteTranscription>> incompleteTranscriptions() async {
    final result = <IncompleteTranscription>[];
    final list = await (select(meetings)
      ..where((m) =>
      m.deletedAt.isNull() & m.status.isIn(['transcribing', 'recorded', 'error'])))
        .get();
    for (final m in list) {
      final segs = await (select(audioSegments)
        ..where((s) => s.meetingId.equals(m.id))
        ..orderBy([(s) => OrderingTerm.asc(s.segmentNumber)]))
          .get();
      if (segs.isEmpty) continue;
      final done = segs.where((s) => s.status == 'completed').toList();
      if (done.length == segs.length) continue; // tout est transcrit
      if (done.isEmpty && m.status != 'transcribing') continue; // jamais lancée : pas « incomplète »
      result.add(IncompleteTranscription(
        meeting: m,
        done: done.length,
        total: segs.length,
        lastDoneNumber: done.isEmpty ? null : done.last.segmentNumber,
      ));
    }
    return result;
  }

  /// Dernière ligne de texte située AVANT la position donnée.
  Future<TranscriptSegment?> lastTranscriptBefore(String meetingId, int ms) =>
      (select(transcriptSegments)
        ..where((t) => t.meetingId.equals(meetingId) & t.startMs.isSmallerThanValue(ms))
        ..orderBy([(t) => OrderingTerm.desc(t.startMs)])
        ..limit(1))
          .getSingleOrNull();

  /// Enregistre le texte d'un segment audio en une seule opération :
  /// tout est écrit, ou rien. Rejouer un segment remplace son ancien texte,
  /// donc aucun doublon possible.
  Future<void> saveSegmentTranscript({
    required String audioSegmentId,
    required List<TranscriptSegmentsCompanion> rows,
    String? mergeIntoId,
    String? mergedText,
    int? mergedEndMs,
  }) =>
      transaction(() async {
        await (delete(transcriptSegments)
          ..where((t) => t.audioSegmentId.equals(audioSegmentId)))
            .go();
        if (mergeIntoId != null) {
          await (update(transcriptSegments)..where((t) => t.id.equals(mergeIntoId)))
              .write(TranscriptSegmentsCompanion(
            content: Value(mergedText!),
            endMs: Value(mergedEndMs!),
          ));
        }
        await batch((b) => b.insertAll(transcriptSegments, rows));
      });

  // ---------- Édition de la transcription ----------
  // Aucune de ces méthodes ne touche à startMs / audioSegmentId :
  // le lien avec l'audio original est conservé.

  Future<void> updateTranscriptContent(String id, String content) =>
      (update(transcriptSegments)..where((t) => t.id.equals(id))).write(
          TranscriptSegmentsCompanion(content: Value(content), edited: const Value(true)));

  Future<void> updateTranscriptLanguage(String id, String language) =>
      (update(transcriptSegments)..where((t) => t.id.equals(id))).write(
          TranscriptSegmentsCompanion(language: Value(language), edited: const Value(true)));

  Future<void> updateTranscriptSpeaker(String id, String? speakerId) =>
      (update(transcriptSegments)..where((t) => t.id.equals(id)))
          .write(TranscriptSegmentsCompanion(speakerId: Value(speakerId)));

  Future<void> deleteTranscriptLine(String id) =>
      (delete(transcriptSegments)..where((t) => t.id.equals(id))).go();

  /// Recolle deux lignes : le texte de la seconde est ajouté à la première.
  Future<void> mergeTranscriptLines(TranscriptSegment first, TranscriptSegment second) =>
      transaction(() async {
        await (update(transcriptSegments)..where((t) => t.id.equals(first.id))).write(
          TranscriptSegmentsCompanion(
            content: Value('${first.content.trimRight()} ${second.content.trimLeft()}'),
            endMs: Value(second.endMs),
            edited: const Value(true),
          ),
        );
        await (delete(transcriptSegments)..where((t) => t.id.equals(second.id))).go();
      });

  /// Coupe une ligne en deux à la position [at] de [fullText].
  /// L'heure de coupure est estimée proportionnellement à la longueur du texte.
  Future<void> splitTranscriptLine(TranscriptSegment line, String fullText, int at) =>
      transaction(() async {
        final head = fullText.substring(0, at).trim();
        final tail = fullText.substring(at).trim();
        if (head.isEmpty || tail.isEmpty) return;
        final ratio = at / fullText.length;
        final cut = line.startMs + ((line.endMs - line.startMs) * ratio).round();

        await (update(transcriptSegments)..where((t) => t.id.equals(line.id))).write(
          TranscriptSegmentsCompanion(
              content: Value(head), endMs: Value(cut), edited: const Value(true)),
        );
        await into(transcriptSegments).insert(TranscriptSegmentsCompanion.insert(
          id: const Uuid().v4(),
          meetingId: line.meetingId,
          audioSegmentId: line.audioSegmentId,
          startMs: cut,
          endMs: line.endMs,
          content: tail,
          speakerId: Value(line.speakerId),
          language: Value(line.language),
          edited: const Value(true),
        ));
      });

  // ---------- Locuteurs ----------

  Stream<List<Participant>> watchParticipants(String meetingId) =>
      (select(participants)..where((p) => p.meetingId.equals(meetingId))).watch();

  String _nextSpeakerId(List<Participant> existing) {
    final used = existing.map((p) => p.speakerIdentifier).whereType<String>().toSet();
    var n = 1;
    while (used.contains('speaker_${n.toString().padLeft(2, '0')}')) {
      n++;
    }
    return 'speaker_${n.toString().padLeft(2, '0')}';
  }

  /// Crée un locuteur et retourne son identifiant (speaker_01, speaker_02...).
  Future<String> addSpeaker(String meetingId, String name) async {
    final speakerId = _nextSpeakerId(await getParticipants(meetingId));
    await into(participants).insert(ParticipantsCompanion.insert(
      id: const Uuid().v4(),
      meetingId: meetingId,
      name: name,
      speakerIdentifier: Value(speakerId),
    ));
    return speakerId;
  }

  /// Un participant saisi à la création de la réunion devient attribuable
  /// à une ligne : on lui donne un identifiant de locuteur.
  Future<String> ensureSpeakerId(Participant p) async {
    if (p.speakerIdentifier != null) return p.speakerIdentifier!;
    final speakerId = _nextSpeakerId(await getParticipants(p.meetingId));
    await (update(participants)..where((x) => x.id.equals(p.id)))
        .write(ParticipantsCompanion(speakerIdentifier: Value(speakerId)));
    return speakerId;
  }

  /// Renommer UN participant change le nom partout : les lignes ne stockent
  /// que l'identifiant du locuteur.
  Future<void> renameParticipant(String id, String name) =>
      (update(participants)..where((p) => p.id.equals(id)))
          .write(ParticipantsCompanion(name: Value(name)));

  /// Suppression définitive en base. Les fichiers (audio, exports) devront
  /// être supprimés AVANT d'appeler cette méthode.
  Future<void> purgeMeeting(String id) => transaction(() async {
    await (delete(meetingNotes)..where((t) => t.meetingId.equals(id))).go();
    await (delete(transcriptSegments)..where((t) => t.meetingId.equals(id)))
        .go();
    await (delete(audioSegments)..where((t) => t.meetingId.equals(id))).go();
    await (delete(meetingContexts)..where((t) => t.meetingId.equals(id)))
        .go();
    await (delete(participants)..where((t) => t.meetingId.equals(id))).go();
    await (delete(meetings)..where((t) => t.id.equals(id))).go();
  });
}


class IncompleteTranscription {
  final Meeting meeting;
  final int done;
  final int total;
  final int? lastDoneNumber;
  const IncompleteTranscription({
    required this.meeting,
    required this.done,
    required this.total,
    required this.lastDoneNumber,
  });
}