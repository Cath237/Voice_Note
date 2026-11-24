import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/transcription_service.dart';
import 'transcription_settings.dart';

/// Fonctionne avec toute API au format « audio/transcriptions » :
/// Groq, OpenAI, ou un serveur Whisper que vous hébergez.
/// On demande verbose_json pour obtenir les horodatages par phrase
/// et la langue détectée.
class OpenAiCompatibleTranscriptionService implements TranscriptionService {
  OpenAiCompatibleTranscriptionService(this._settings, {Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 3),
      ));

  final TranscriptionSettingsStore _settings;
  final Dio _dio;

  @override
  bool get supportsDiarization => false;

  @override
  bool get sendsAudioToExternalService => true;

  static const _languageCodes = {
    'french': 'fr',
    'english': 'en',
    'fr': 'fr',
    'en': 'en',
  };

  @override
  Future<TranscriptResult> transcribeSegment(
      String audioFilePath, TranscriptionHints hints) async {
    final s = await _settings.load();
    if (!s.consent) {
      throw const TranscriptionException(
          'Envoi de l\'audio non autorisé : voir Paramètres de transcription',
          retryable: false);
    }
    if (s.apiKey.isEmpty) {
      throw const TranscriptionException('Clé API manquante', retryable: false);
    }
    if (!File(audioFilePath).existsSync()) {
      throw const TranscriptionException('Fichier audio introuvable', retryable: false);
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(audioFilePath),
      'model': s.provider.model,
      'response_format': 'verbose_json',
      'temperature': '0',
      if (hints.languageHint != null) 'language': hints.languageHint,
      if (hints.prompt.isNotEmpty) 'prompt': hints.prompt,
    });

    try {
      final res = await _dio.post(
        '${s.provider.baseUrl}/audio/transcriptions',
        data: form,
        options: Options(headers: {'Authorization': 'Bearer ${s.apiKey}'}),
      );
      return _parse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  TranscriptResult _parse(Map<String, dynamic> data) {
    final raw = (data['language'] as String? ?? '').toLowerCase();
    final language = _languageCodes[raw] ?? 'unknown';

    final segments = data['segments'] as List? ?? [];
    final chunks = <TranscriptChunk>[];
    for (final s in segments) {
      final text = (s['text'] as String? ?? '').trim();
      if (text.isEmpty) continue;
      chunks.add(TranscriptChunk(
        startMs: ((s['start'] as num) * 1000).round(),
        endMs: ((s['end'] as num) * 1000).round(),
        text: text,
        language: language,
        noSpeechProb: (s['no_speech_prob'] as num?)?.toDouble(),
        avgLogprob: (s['avg_logprob'] as num?)?.toDouble(),
      ));
    }

    // Certains modèles ne renvoient pas de segments : un seul bloc.
    if (chunks.isEmpty) {
      final text = (data['text'] as String? ?? '').trim();
      if (text.isNotEmpty) {
        chunks.add(TranscriptChunk(
          startMs: 0,
          endMs: (((data['duration'] as num?) ?? 0) * 1000).round(),
          text: text,
          language: language,
        ));
      }
    }
    return TranscriptResult(chunks, language);
  }

  TranscriptionException _toException(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    var detail = '';
    if (body is Map && body['error'] is Map) {
      detail = ' : ${(body['error'] as Map)['message']}';
    }
    if (code == 401 || code == 403) {
      return TranscriptionException('Clé API refusée par le service$detail', retryable: false);
    }
    if (code == 413) {
      return TranscriptionException('Fichier audio trop volumineux$detail', retryable: false);
    }
    if (code != null && code >= 400 && code < 500 && code != 408 && code != 429) {
      return TranscriptionException('Requête refusée (HTTP $code)$detail', retryable: false);
    }
    // Réseau, délai dépassé, 429 (trop de requêtes), 5xx : on réessaiera.
    return TranscriptionException(
        code == null ? 'Connexion impossible' : 'Service indisponible (HTTP $code)$detail');
  }
}