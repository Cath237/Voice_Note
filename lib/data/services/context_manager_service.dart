import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Mémoire de la réunion : dictionnaire saisi par l'utilisateur + termes
/// repérés dans le texte + fin du texte précédent. Elle sert à construire
/// l'indice envoyé au moteur pour le segment suivant.
class ContextManagerService {
  ContextManagerService(this.db);
  final AppDatabase db;

  static const _maxPromptChars = 600; // Whisper tronque autour de 224 tokens

  Future<MeetingContext?> _get(String meetingId) => db.getContext(meetingId);

  Future<void> ensure(String meetingId) async {
    if (await _get(meetingId) == null) {
      await db.into(db.meetingContexts)
          .insert(MeetingContextsCompanion.insert(meetingId: meetingId));
    }
  }

  Future<String> buildPrompt(String meetingId) async {
    final ctx = await _get(meetingId);
    final dictionary =
    ctx == null ? <String>[] : List<String>.from(jsonDecode(ctx.dictionaryJson));
    final entities =
    ctx == null ? <String>[] : List<String>.from(jsonDecode(ctx.entitiesJson));

    final last = await (db.select(db.transcriptSegments)
      ..where((t) => t.meetingId.equals(meetingId))
      ..orderBy([(t) => OrderingTerm.desc(t.startMs)])
      ..limit(3))
        .get();
    final tail = last.reversed.map((t) => t.content).join(' ');

    // Le dictionnaire de l'utilisateur passe avant les termes détectés.
    final terms = {...dictionary, ...entities}.take(40).join(', ');
    final prompt = [if (terms.isNotEmpty) 'Termes : $terms.', tail].join(' ').trim();
    return prompt.length <= _maxPromptChars
        ? prompt
        : prompt.substring(prompt.length - _maxPromptChars);
  }

  /// Appelée après chaque segment. Extraction locale volontairement simple :
  /// sigles, noms propres en milieu de phrase, montants.
  Future<void> updateFromText(String meetingId, String text) async {
    if (text.trim().isEmpty) return;
    await ensure(meetingId);
    final ctx = (await _get(meetingId))!;
    final known = List<String>.from(jsonDecode(ctx.entitiesJson)).toSet();

    known.addAll(RegExp(r'\b[A-Z]{2,}[A-Za-z0-9]*\b').allMatches(text).map((m) => m.group(0)!));
    known.addAll(RegExp(r'(?<=[a-zà-ÿ,] )[A-ZÀ-Ý]\p{L}{2,}', unicode: true)
        .allMatches(text)
        .map((m) => m.group(0)!));
    known.addAll(RegExp(r'\d[\d\s.,]*\s?(?:FCFA|XAF|€|\$|%)')
        .allMatches(text)
        .map((m) => m.group(0)!.trim()));

    await (db.update(db.meetingContexts)..where((c) => c.meetingId.equals(meetingId)))
        .write(MeetingContextsCompanion(
      entitiesJson: Value(jsonEncode(known.take(200).toList())),
    ));
  }
}