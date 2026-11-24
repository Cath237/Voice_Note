import 'package:dio/dio.dart';

import 'transcription_settings.dart';

class SummaryException implements Exception {
  final String message;
  const SummaryException(this.message);

  @override
  String toString() => message;
}

/// Appelle l'API « chat » du service choisi (Groq ou OpenAI), avec la même clé
/// que la transcription. Gère l'attente quand le service limite le débit.
class LlmClient {
  LlmClient(this._settings, {Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 3),
      ));

  final TranscriptionSettingsStore _settings;
  final Dio _dio;

  static const _tokenCeiling = 16000;

  Map<String, dynamic> _body(
      TranscriptionSettings s,
      String system,
      String user,
      int tokens,
      bool jsonMode,
      ) {
    final model = s.chatModel;
    final isGptOss = model.contains('gpt-oss');
    // Les modèles de raisonnement d'OpenAI n'acceptent pas de température.
    final noTemperature = RegExp(r'^(o\d|gpt-5)').hasMatch(model);

    return {
      'model': model,
      if (!noTemperature) 'temperature': 0.2,
      // Limite de la réponse. Pour un modèle à raisonnement, les « réflexions »
      // comptent dans cette limite : elle doit être large.
      'max_completion_tokens': tokens,
      if (isGptOss) ...{
        'reasoning_effort': 'low',
        'include_reasoning': false,
      },
      if (jsonMode) 'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': '$system\n'
              'Retourne un objet JSON valide uniquement. '
              'Respecte exactement les clés et les types demandés. '
              'N\'ajoute aucun commentaire avant ou après le JSON.',
        },
        {'role': 'user', 'content': user},
      ],
    };
  }

  /// Retourne le texte brut de la réponse (un objet JSON demandé au modèle).
  Future<String> completeJson({
    required String system,
    required String user,
    int maxTokens = 4000,
  }) async {
    final s = await _settings.load();
    if (!s.hasKey) {
      throw const SummaryException('Clé API manquante : voir les réglages de transcription');
    }

    var tokens = maxTokens;
    var jsonMode = true;
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        final res = await _dio.post(
          '${s.provider.baseUrl}/chat/completions',
          data: _body(s, system, user, tokens, jsonMode),
          options: Options(headers: {'Authorization': 'Bearer ${s.apiKey}'}),
        );

        final choice = (res.data['choices'] as List?)?.first;
        final content = (choice?['message']?['content'] as String?) ?? '';
        final finish = choice?['finish_reason'];

        // Réponse coupée ou vide (le raisonnement a tout consommé) : on élargit.
        final cut = finish == 'length' || content.trim().isEmpty;
        if (cut && tokens < _tokenCeiling) {
          tokens = (tokens * 2).clamp(0, _tokenCeiling);
          continue;
        }
        return content;
      } on DioException catch (e) {
        // Le service a refusé le JSON produit : on redemande sans le « mode JSON »
        // et l'application extrait elle-même le JSON de la réponse.
        if (jsonMode && _isJsonValidationError(e)) {
          jsonMode = false;
          tokens = (tokens * 2).clamp(0, _tokenCeiling);
          continue;
        }

        final code = e.response?.statusCode;
        final retryable = code == null || code == 408 || code == 429 || code >= 500;
        if (!retryable || attempt >= 5) throw SummaryException(_message(e, s));

        // Le service indique parfois combien de temps attendre.
        final header = e.response?.headers.value('retry-after');
        final seconds = double.tryParse(header ?? '') ?? (5.0 * attempt);
        await Future.delayed(Duration(seconds: seconds.ceil().clamp(2, 60)));
      }
    }
  }

  bool _isJsonValidationError(DioException e) {
    if (e.response?.statusCode != 400) return false;
    final data = e.response?.data;
    if (data is! Map || data['error'] is! Map) return false;
    final err = data['error'] as Map;
    final text = '${err['code']} ${err['message']}'.toLowerCase();
    return text.contains('json_validate_failed') ||
        text.contains('validate json') ||
        text.contains('failed_generation');
  }

  String _message(DioException e, TranscriptionSettings s) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    var detail = '';
    if (data is Map && data['error'] is Map) {
      detail = '${(data['error'] as Map)['message']}';
    }
    if (code == 401 || code == 403) return 'Clé API refusée par le service';
    if (code == 404 || (code == 400 && detail.toLowerCase().contains('model'))) {
      return 'Modèle « ${s.chatModel} » introuvable ou refusé. '
          'Changez le modèle de résumé dans les réglages. ($detail)';
    }
    if (code == 413) {
      return 'Requête trop volumineuse pour la limite du service. $detail';
    }
    if (code == 429) {
      return 'Limite d\'utilisation du service atteinte : réessayez dans quelques minutes. $detail';
    }
    if (code == null) return 'Connexion impossible : vérifiez Internet';
    return 'Erreur du service (HTTP $code) $detail';
  }
}