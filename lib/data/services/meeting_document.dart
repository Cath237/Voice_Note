import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';

/// Ce que l'utilisateur veut voir dans le document.
class ExportOptions {
  final bool includeNotes;
  final bool includeTimestamps;
  final bool includeSpeakers;
  final bool includeSummary;
  final bool includeTranscript;
  const ExportOptions({
    this.includeNotes = true,
    this.includeTimestamps = true,
    this.includeSpeakers = true,
    this.includeSummary = true,
    this.includeTranscript = true,
  });
}

class DocLine {
  final int startMs;
  final String? speaker; // nom affiché, déjà résolu
  final String language;
  final String text;
  const DocLine(this.startMs, this.speaker, this.language, this.text);
}

class DocNote {
  final int ms;
  final String label; // Note, Décision, Action...
  final String content;
  const DocNote(this.ms, this.label, this.content);
}

/// Tout ce qu'il faut pour fabriquer un document. Les trois formats
/// (Word, PDF, texte) partent de ce même objet : ils restent identiques.
class MeetingDocument {
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final int durationMs;
  final List<String> participants;
  final String languages;
  final List<DocLine> lines;
  final List<DocNote> notes;
  final bool timestamps;

  /// Texte du résumé : les lignes « ## ... » sont des intertitres,
  /// les lignes « • ... » des puces.
  final String? summary;

  const MeetingDocument({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.durationMs,
    required this.participants,
    required this.languages,
    required this.lines,
    required this.notes,
    required this.timestamps,
    this.summary,
  });

  String get dateText => DateFormat('d MMMM y', 'fr').format(date);
  String get durationText => formatDuration(durationMs);

  bool get hasSummary => summary != null && summary!.trim().isNotEmpty;

  String toPlainText() {
    final b = StringBuffer()
      ..writeln(title.toUpperCase())
      ..writeln('$dateText · Durée : $durationText');
    if (category.isNotEmpty) b.writeln('Catégorie : $category');
    if (location.isNotEmpty) b.writeln('Lieu : $location');
    if (participants.isNotEmpty) b.writeln('Participants : ${participants.join(', ')}');
    b.writeln('Langues : $languages');
    if (description.isNotEmpty) b.writeln('\n$description');

    if (hasSummary) {
      b.writeln('\nRÉSUMÉ');
      for (final line in summary!.split('\n')) {
        b.writeln(line.startsWith('## ') ? '\n${line.substring(3)}' : line);
      }
    }

    if (notes.isNotEmpty) {
      b.writeln('\nNOTES ET MARQUEURS');
      for (final n in notes) {
        b.writeln('[${formatDuration(n.ms)}] ${n.label}${n.content.isEmpty ? '' : ' : ${n.content}'}');
      }
    }

    if (lines.isNotEmpty) {
      b.writeln('\nTRANSCRIPTION\n');
      for (final l in lines) {
        final time = timestamps ? '[${formatDuration(l.startMs)}] ' : '';
        final who = l.speaker == null ? '' : '${l.speaker} : ';
        b.writeln('$time$who${l.text}');
      }
    }
    return b.toString();
  }
}

String noteTypeLabel(String type) => switch (type) {
  'important' => 'Important',
  'decision' => 'Décision',
  'verify' => 'À vérifier',
  'action' => 'Action',
  'question' => 'Question',
  _ => 'Note',
};

/// « Réunion de direction » + date -> « reunion_de_direction_2026-10-09 »
/// (sans accents ni espaces : accepté partout, y compris WhatsApp).
String exportBaseName(String title, DateTime date) {
  var base = normalizeForSearch(title)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (base.isEmpty) base = 'reunion';
  if (base.length > 40) base = base.substring(0, 40);
  return '${base}_${DateFormat('yyyy-MM-dd').format(date)}';
}