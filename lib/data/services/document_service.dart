import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'meeting_document.dart';
import 'pdf_export_service.dart';
import 'share_service.dart';
import 'summary_data.dart';
import 'word_export_service.dart';

enum ExportFormat { word, pdf, txt }

extension ExportFormatInfo on ExportFormat {
  String get extension => switch (this) {
    ExportFormat.word => 'docx',
    ExportFormat.pdf => 'pdf',
    ExportFormat.txt => 'txt',
  };
}

/// Moteur 3 : transforme les données de la réunion en documents.
/// Il ne modifie JAMAIS l'audio ni la transcription : il ne fait que lire.
class DocumentService {
  DocumentService(this._db, this._word, this._pdf);

  final AppDatabase _db;
  final WordExportService _word;
  final PdfExportService _pdf;

  Future<MeetingDocument> load(String meetingId, ExportOptions options) async {
    final meeting = await _db.getMeeting(meetingId);
    if (meeting == null) throw StateError('Réunion introuvable');

    final rows = options.includeTranscript
        ? await (_db.select(_db.transcriptSegments)
      ..where((t) => t.meetingId.equals(meetingId))
      ..orderBy([(t) => OrderingTerm.asc(t.startMs)]))
        .get()
        : <TranscriptSegment>[];

    final people = await _db.getParticipants(meetingId);
    final speakerNames = {
      for (final p in people)
        if (p.speakerIdentifier != null) p.speakerIdentifier!: p.name,
    };

    final noteRows = options.includeNotes
        ? await (_db.select(_db.meetingNotes)
      ..where((n) => n.meetingId.equals(meetingId))
      ..orderBy([(n) => OrderingTerm.asc(n.timestampMs)]))
        .get()
        : <MeetingNote>[];

    // Résumé : lu depuis la réunion, mis en forme pour les documents.
    String? summary;
    if (options.includeSummary && meeting.summaryJson != null) {
      try {
        summary = SummaryData.fromJson(jsonDecode(meeting.summaryJson!) as Map<String, dynamic>)
            .toDocumentText();
      } catch (_) {
        summary = null;
      }
    }

    // Langues réellement présentes dans le texte.
    final found = rows.map((r) => r.language).toSet();
    final languages = [
      if (found.contains('fr')) 'Français',
      if (found.contains('en')) 'English',
    ];

    return MeetingDocument(
      title: meeting.title,
      description: meeting.description,
      category: meeting.category,
      location: meeting.location,
      date: meeting.date,
      durationMs: meeting.durationMs,
      participants: people.map((p) => p.name).toList(),
      languages: languages.isNotEmpty
          ? languages.join(' / ')
          : switch (meeting.language) {
        'fr' => 'Français',
        'en' => 'English',
        _ => 'Français / English',
      },
      lines: [
        for (final r in rows)
          DocLine(
            r.startMs,
            options.includeSpeakers ? speakerNames[r.speakerId] : null,
            r.language,
            r.content,
          ),
      ],
      notes: [
        for (final n in noteRows) DocNote(n.timestampMs, noteTypeLabel(n.type), n.content),
      ],
      timestamps: options.includeTimestamps,
      summary: summary,
    );
  }

  Future<Directory> _exportDir(String meetingId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meetings', meetingId, 'exports'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<Uint8List> pdfBytes(String meetingId, ExportOptions options) async =>
      _pdf.build(await load(meetingId, options));

  /// Crée le fichier dans le dossier de la réunion et le retourne.
  Future<File> export(String meetingId, ExportFormat format, ExportOptions options) async {
    final doc = await load(meetingId, options);
    final dir = await _exportDir(meetingId);
    final file =
    File(p.join(dir.path, '${exportBaseName(doc.title, doc.date)}.${format.extension}'));

    switch (format) {
      case ExportFormat.txt:
        await file.writeAsString(doc.toPlainText());
      case ExportFormat.word:
        await file.writeAsBytes(_word.build(doc));
      case ExportFormat.pdf:
        await file.writeAsBytes(await _pdf.build(doc));
    }
    return file;
  }

  /// Les fichiers audio de la réunion, un par segment, nommés dans l'ordre.
  Future<List<ShareItem>> audioItems(String meetingId, String title, DateTime date) async {
    final segments = await (_db.select(_db.audioSegments)
      ..where((s) => s.meetingId.equals(meetingId))
      ..orderBy([(s) => OrderingTerm.asc(s.segmentNumber)]))
        .get();
    final usable =
    segments.where((s) => s.status != 'recording' && File(s.filePath).existsSync()).toList();
    final base = exportBaseName(title, date);
    return [
      for (var i = 0; i < usable.length; i++)
        ShareItem(
          usable[i].filePath,
          usable.length == 1
              ? '$base.m4a'
              : '${base}_partie_${(i + 1).toString().padLeft(2, '0')}.m4a',
        ),
    ];
  }
}