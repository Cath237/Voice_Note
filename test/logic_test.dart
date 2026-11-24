import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:voicenote/core/utils/formatters.dart';
import 'package:voicenote/data/services/meeting_document.dart';
import 'package:voicenote/data/services/summary_data.dart';
import 'package:voicenote/data/services/transcript_merge_service.dart';
import 'package:voicenote/data/services/transcription_settings.dart';
import 'package:voicenote/data/services/word_export_service.dart';
import 'package:voicenote/domain/transcription_service.dart';

MeetingDocument _doc({
  List<DocLine> lines = const [],
  List<DocNote> notes = const [],
  String? summary,
  bool timestamps = true,
}) =>
    MeetingDocument(
      title: 'Réunion de direction',
      description: '',
      category: 'Réunion de direction',
      location: '',
      date: DateTime(2026, 10, 9),
      durationMs: 5025000,
      participants: const ['Marie', 'David'],
      languages: 'Français / English',
      lines: lines,
      notes: notes,
      timestamps: timestamps,
      summary: summary,
    );

void main() {
  setUpAll(() async => initializeDateFormatting('fr'));

  group('Fusion des segments', () {
    final merge = TranscriptMergeService();

    test('supprime le recouvrement entre deux segments', () {
      final out = merge.removeOverlap(
        'Nous devons maintenant discuter du budget',
        'discuter du budget prévisionnel de l\'année prochaine.',
      );
      expect(out, 'prévisionnel de l\'année prochaine.');
    });

    test('garde le texte quand il n\'y a pas de recouvrement', () {
      expect(
        merge.removeOverlap('On passe au point suivant.', 'The second point concerns the report.'),
        'The second point concerns the report.',
      );
    });

    test('ne supprime pas un simple mot répété', () {
      expect(merge.removeOverlap('merci beaucoup', 'beaucoup de choses'), 'beaucoup de choses');
    });

    test('reconnaît une phrase coupée entre deux segments', () {
      expect(merge.isContinuation('Nous devons discuter du budget', 'prévisionnel de l\'année.'), isTrue);
      expect(merge.isContinuation('C\'est terminé.', 'Passons à la suite.'), isFalse);
      expect(merge.isContinuation('Nous avons fini', 'Ensuite, le budget.'), isFalse);
    });
  });

  group('Transcription', () {
    test('un passage sans parole est écarté', () {
      const silence = TranscriptChunk(
          startMs: 0, endMs: 1000, text: 'Merci d\'avoir regardé', noSpeechProb: 0.9, avgLogprob: -1.5);
      const speech = TranscriptChunk(
          startMs: 0, endMs: 1000, text: 'Bonjour', noSpeechProb: 0.9, avgLogprob: -0.2);
      const plain = TranscriptChunk(startMs: 0, endMs: 1000, text: 'Bonjour');
      expect(silence.isLikelySilence, isTrue);
      expect(speech.isLikelySilence, isFalse);
      expect(plain.isLikelySilence, isFalse);
    });
  });

  group('Formats', () {
    test('durées', () {
      expect(formatDuration(5025000), '01:23:45');
      expect(formatDuration(5000), '00:00:05');
      expect(formatTotal(103500000), '28h 45');
    });

    test('recherche sans accents ni majuscules', () {
      expect(normalizeForSearch('Écoulé À Noël'), 'ecoule a noel');
    });

    test('nom de fichier d\'export', () {
      expect(exportBaseName('Réunion de direction', DateTime(2026, 10, 9)),
          'reunion_de_direction_2026-10-09');
      expect(exportBaseName('???', DateTime(2026, 10, 9)), 'reunion_2026-10-09');
      expect(exportBaseName('a' * 60, DateTime(2026, 10, 9)), '${'a' * 40}_2026-10-09');
    });
  });

  group('Résumé', () {
    test('lit un JSON de modèle, même incomplet', () {
      final s = SummaryData.fromJson({
        'summary': 'Résumé',
        'key_points': ['a', ' b '],
        'decisions': 'unique',
        'actions': [
          {'action': 'Faire X', 'owner': 'Marie'},
          'Appeler Y',
        ],
      });
      expect(s.keyPoints, ['a', 'b']);
      expect(s.decisions, ['unique']);
      expect(s.actions.length, 2);
      expect(s.actions[0].owner, 'Marie');
      expect(s.actions[0].due, 'Non précisé');
      expect(s.actions[1].action, 'Appeler Y');
      expect(s.openQuestions, isEmpty);
    });

    test('texte de document avec intertitres et puces', () {
      final s = SummaryData.fromJson({
        'summary': 'Résumé',
        'key_points': ['a'],
        'actions': [
          {'action': 'Faire X', 'owner': 'Marie', 'due': 'Vendredi'}
        ],
      });
      final text = s.toDocumentText();
      expect(text, contains('## Résumé général'));
      expect(text, contains('• a'));
      expect(text, contains('• Faire X (Responsable : Marie · Échéance : Vendredi)'));
    });

    test('enregistrement puis relecture donnent le même résumé', () {
      final s = SummaryData.fromJson({
        'summary': 'R',
        'decisions': ['d'],
        'topics': ['t'],
      });
      final back = SummaryData.fromJson(s.toJson());
      expect(back.overview, 'R');
      expect(back.decisions, ['d']);
      expect(back.topics, ['t']);
    });
  });

  group('Réglages', () {
    test('un service n\'est prêt qu\'avec clé ET autorisation', () {
      const ok = TranscriptionSettings(provider: SttProvider.groq, consent: true, apiKey: 'k');
      const noConsent = TranscriptionSettings(provider: SttProvider.groq, consent: false, apiKey: 'k');
      const noKey = TranscriptionSettings(provider: SttProvider.groq, consent: true, apiKey: '');
      expect(ok.isReady, isTrue);
      expect(noConsent.isReady, isFalse);
      expect(noKey.isReady, isFalse);
      expect(noKey.hasKey, isFalse);
    });

    test('le modèle de résumé par défaut et personnalisé', () {
      const byDefault = TranscriptionSettings(provider: SttProvider.groq, consent: true, apiKey: 'k');
      const custom = TranscriptionSettings(
          provider: SttProvider.groq, consent: true, apiKey: 'k', summaryModel: '  mon-modele ');
      expect(byDefault.chatModel, SttProvider.groq.defaultSummaryModel);
      expect(custom.chatModel, 'mon-modele');
    });
  });

  group('Documents', () {
    test('texte brut : en-tête, résumé, notes et transcription', () {
      final text = _doc(
        summary: '## Points principaux\n• a',
        notes: const [DocNote(12000, 'Décision', 'Valider le budget')],
        lines: const [DocLine(5000, 'Directeur', 'fr', 'Bonjour')],
      ).toPlainText();

      expect(text, contains('RÉUNION DE DIRECTION'));
      expect(text, contains('9 octobre 2026'));
      expect(text, contains('Durée : 01:23:45'));
      expect(text, contains('Participants : Marie, David'));
      expect(text, contains('Points principaux'));
      expect(text, isNot(contains('## ')));
      expect(text, contains('• a'));
      expect(text, contains('[00:00:12] Décision : Valider le budget'));
      expect(text, contains('[00:00:05] Directeur : Bonjour'));
    });

    test('sans horodatage ni locuteur, et sans transcription', () {
      final noTime = _doc(
        timestamps: false,
        lines: const [DocLine(5000, null, 'fr', 'Bonjour')],
      ).toPlainText();
      expect(noTime, contains('Bonjour'));
      expect(noTime, isNot(contains('[00:00:05]')));

      final summaryOnly = _doc(summary: '## Résumé général\nTexte').toPlainText();
      expect(summaryOnly, isNot(contains('TRANSCRIPTION')));
      expect(summaryOnly, contains('RÉSUMÉ'));
    });

    test('Word : fichier valide, résumé présent, caractères spéciaux protégés', () {
      final bytes = WordExportService().build(_doc(
        summary: '## Points principaux\n• a',
        lines: const [DocLine(5000, 'Directeur', 'fr', 'A & B <c> ok\u0001ok')],
      ));
      final archive = ZipDecoder().decodeBytes(bytes);

      expect(archive.findFile('[Content_Types].xml'), isNotNull);
      expect(archive.findFile('_rels/.rels'), isNotNull);
      final xml = utf8.decode(archive.findFile('word/document.xml')!.content as List<int>);

      expect(xml, contains('Points principaux'));
      expect(xml, contains('A &amp; B &lt;c&gt; okok'));
      expect(xml, contains('00:00:05'));
      expect(xml, contains('Directeur'));
    });
  });
}