import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/foundation.dart' show ValueNotifier;

import '../../core/utils/formatters.dart';
import '../database/app_database.dart';
import 'llm_client.dart';
import 'summary_data.dart';
import 'transcription_settings.dart';

class _Chunk {
  _Chunk(this.startMs) : endMs = startMs;
  final int startMs;
  int endMs;
  final StringBuffer text = StringBuffer();
}

/// Moteur 3 : résumé. Pour une réunion longue : on résume chaque partie,
/// puis on fusionne les résumés (en plusieurs passes si nécessaire).
class SummaryService {
  SummaryService(this._db, this._llm, this._settings);

  final AppDatabase _db;
  final LlmClient _llm;
  final TranscriptionSettingsStore _settings;

  static const _maxChunkChars = 14000; // environ 4 000 mots par partie
  static const _maxMergeChars = 16000;

  /// meetingId -> message de progression. Présent = génération en cours.
  final ValueNotifier<Map<String, String>> progress = ValueNotifier({});

  /// Résumés de parties déjà obtenus : si la génération échoue en route,
  /// la nouvelle tentative reprend là où elle s'est arrêtée (tant que
  /// l'application reste ouverte).
  final Map<String, Map<String, dynamic>> _partialCache = {};

  bool isRunning(String meetingId) => progress.value.containsKey(meetingId);

  void _setProgress(String meetingId, String? message) {
    final map = {...progress.value};
    if (message == null) {
      map.remove(meetingId);
    } else {
      map[meetingId] = message;
    }
    progress.value = map;
  }

  static const _system =
      'Tu es un assistant qui rédige des comptes rendus de réunion. '
      'Tu réponds UNIQUEMENT par un objet JSON valide, sans texte autour. '
      'Tu n\'inventes rien : tout doit provenir du texte fourni. '
      'Si un responsable ou une échéance n\'est pas dit, écris "Non précisé". '
      'Rédige en français, même si la réunion contient de l\'anglais ; '
      'garde tels quels les noms propres, chiffres, montants et sigles. '
      'La transcription est automatique et peut contenir des erreurs : '
      'ne tire aucune conclusion d\'un passage douteux.';

  static const _format = '''
Format JSON attendu (toutes les clés, listes vides si rien) :
{
  "summary": "résumé en quelques phrases",
  "key_points": ["..."],
  "decisions": ["..."],
  "actions": [{"action": "...", "owner": "...", "due": "..."}],
  "open_questions": ["..."],
  "topics": ["..."]
}
Contraintes : sois concis (summary : 3 à 6 phrases ; au plus 8 éléments par liste).''';

  Future<void> generate(String meetingId) async {
    if (isRunning(meetingId)) return;
    _setProgress(meetingId, 'Préparation...');
    try {
      final settings = await _settings.load();
      final meeting = await _db.getMeeting(meetingId);
      if (meeting == null) throw const SummaryException('Réunion introuvable');

      final rows = await (_db.select(_db.transcriptSegments)
        ..where((t) => t.meetingId.equals(meetingId))
        ..orderBy([(t) => OrderingTerm.asc(t.startMs)]))
          .get();
      if (rows.isEmpty) throw const SummaryException('Aucune transcription à résumer');

      final people = await _db.getParticipants(meetingId);
      final names = {
        for (final p in people)
          if (p.speakerIdentifier != null) p.speakerIdentifier!: p.name,
      };
      final notes = await (_db.select(_db.meetingNotes)
        ..where((n) => n.meetingId.equals(meetingId))
        ..orderBy([(n) => OrderingTerm.asc(n.timestampMs)]))
          .get();
      final ctx = await _db.getContext(meetingId);
      final dictionary =
      ctx == null ? <String>[] : List<String>.from(jsonDecode(ctx.dictionaryJson));

      final chunks = _split(rows, names);
      final header = StringBuffer('Réunion : « ${meeting.title} ».');
      if (people.isNotEmpty) {
        header.write(' Participants : ${people.map((p) => p.name).join(', ')}.');
      }
      if (dictionary.isNotEmpty) {
        header.write(' Orthographe à respecter : ${dictionary.join(', ')}.');
      }

      // 1) Résumé de chaque partie.
      final partials = <Map<String, dynamic>>[];
      for (var i = 0; i < chunks.length; i++) {
        final label = chunks.length == 1 ? 'Analyse' : 'Partie ${i + 1}/${chunks.length}';
        _setProgress(meetingId, chunks.length == 1
            ? 'Analyse de la réunion...'
            : 'Analyse de la partie ${i + 1} / ${chunks.length}...');

        final from = chunks[i].startMs;
        final to = i + 1 < chunks.length ? chunks[i + 1].startMs : 1 << 40;
        final markers = notes
            .where((n) => (i == 0 || n.timestampMs >= from) && n.timestampMs < to)
            .map((n) =>
        '- ${_label(n.type)} à ${formatDuration(n.timestampMs)}${n.content.isEmpty ? '' : ' : ${n.content}'}')
            .join('\n');

        // Déjà résumée lors d'une tentative précédente ? On la réutilise.
        final cacheKey = '$meetingId:$i:${chunks[i].text.toString().hashCode}:${markers.hashCode}';
        final cached = _partialCache[cacheKey];
        if (cached != null) {
          partials.add(cached);
          continue;
        }

        final user = '''
$header
${chunks.length > 1 ? 'Extrait ${i + 1} sur ${chunks.length} de la réunion.' : ''}
${markers.isEmpty ? '' : "Repères posés par l'utilisateur pendant la réunion (fiables, donne-leur la priorité) :\n$markers\n"}
$_format

TRANSCRIPTION :
${chunks[i].text}''';

        final result = await _callJson(user,
            maxTokens: chunks.length == 1 ? 4500 : 3500, label: label);
        _partialCache[cacheKey] = result;
        partials.add(result);
      }

      // 2) Fusion (en plusieurs passes si les résumés partiels sont nombreux).
      var parts = partials;
      var pass = 1;
      while (parts.length > 1) {
        final groups = _group(parts.map(jsonEncode).toList(), _maxMergeChars);
        final merged = <Map<String, dynamic>>[];
        for (var g = 0; g < groups.length; g++) {
          _setProgress(meetingId,
              'Fusion des résultats (passe $pass, ${g + 1} / ${groups.length})...');
          final user = '''
$header
Voici les résumés partiels, dans l'ordre chronologique, de parties successives de la même réunion.
Fusionne-les en un seul compte rendu cohérent : supprime les doublons, garde l'ordre,
n'ajoute rien. Le champ "summary" fait 5 à 8 phrases.
$_format

RÉSUMÉS PARTIELS :
${groups[g].join('\n')}''';
          merged.add(await _callJson(user,
              maxTokens: 6000, label: 'Fusion (passe $pass, ${g + 1}/${groups.length})'));
        }
        // Sécurité : si la fusion ne réduit pas le nombre de parties, on s'arrête.
        if (merged.length >= parts.length) {
          parts = [merged.first];
          break;
        }
        parts = merged;
        pass++;
      }

      final data = SummaryData.fromJson(
        parts.first,
        generatedAt: DateTime.now(),
        model: settings.chatModel,
      );
      await _db.saveSummaryJson(meetingId, jsonEncode(data.toJson()));
      _partialCache.removeWhere((key, _) => key.startsWith('$meetingId:'));
    } finally {
      _setProgress(meetingId, null);
    }
  }

  // ---------------------------------------------------------------- utilitaires

  List<_Chunk> _split(List<TranscriptSegment> rows, Map<String, String> names) {
    final chunks = <_Chunk>[];
    _Chunk? current;
    for (final r in rows) {
      final who = names[r.speakerId];
      final line = who == null ? r.content : '$who : ${r.content}';
      if (current == null || current.text.length + line.length > _maxChunkChars) {
        current = _Chunk(r.startMs);
        chunks.add(current);
      }
      current.text.writeln(line);
      current.endMs = r.endMs;
    }
    return chunks;
  }

  List<List<String>> _group(List<String> items, int maxChars) {
    final groups = <List<String>>[];
    var size = 0;
    for (final item in items) {
      if (groups.isEmpty || size + item.length > maxChars) {
        groups.add([]);
        size = 0;
      }
      groups.last.add(item);
      size += item.length;
    }
    return groups;
  }

  String _label(String type) => switch (type) {
    'important' => 'Important',
    'decision' => 'Décision',
    'verify' => 'À vérifier',
    'action' => 'Action',
    'question' => 'Question',
    _ => 'Note',
  };

  /// Un modèle renvoie parfois un JSON invalide : on redemande une fois.
  /// En cas d'échec, le message indique l'étape concernée.
  Future<Map<String, dynamic>> _callJson(
      String user, {
        required int maxTokens,
        required String label,
      }) async {
    try {
      for (var attempt = 1; attempt <= 2; attempt++) {
        final raw = await _llm.completeJson(system: _system, user: user, maxTokens: maxTokens);
        final parsed = _parse(raw);
        if (parsed != null) return parsed;
      }
      throw const SummaryException('réponse du service illisible');
    } on SummaryException catch (e) {
      throw SummaryException('$label : ${e.message}');
    }
  }

  Map<String, dynamic>? _parse(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
    final a = cleaned.indexOf('{');
    final b = cleaned.lastIndexOf('}');
    if (a < 0 || b <= a) return null;
    try {
      return jsonDecode(cleaned.substring(a, b + 1)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}