import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SttProvider { groq, openai }

extension SttProviderInfo on SttProvider {
  String get label => switch (this) {
    SttProvider.groq => 'Groq',
    SttProvider.openai => 'OpenAI',
  };

  String get baseUrl => switch (this) {
    SttProvider.groq => 'https://api.groq.com/openai/v1',
    SttProvider.openai => 'https://api.openai.com/v1',
  };

  /// Modèle de transcription audio.
  String get model => switch (this) {
    SttProvider.groq => 'whisper-large-v3-turbo',
    SttProvider.openai => 'whisper-1',
  };

  /// Modèle de langage utilisé pour le résumé (modifiable dans les réglages).
  String get defaultSummaryModel => switch (this) {
    SttProvider.groq => 'openai/gpt-oss-120b',
    SttProvider.openai => 'gpt-4o-mini',
  };

  String get description => switch (this) {
    SttProvider.groq =>
    'Transcription : $model. Créez votre clé sur console.groq.com.',
    SttProvider.openai =>
    'Transcription : $model. Créez votre clé sur platform.openai.com.',
  };
}

class TranscriptionSettings {
  final SttProvider provider;
  final bool consent; // accord pour envoyer l'AUDIO au service
  final String apiKey;
  final String summaryModel; // vide = modèle par défaut du service

  const TranscriptionSettings({
    required this.provider,
    required this.consent,
    required this.apiKey,
    this.summaryModel = '',
  });

  /// La transcription ne démarre que si tout est en place.
  bool get isReady => consent && apiKey.isNotEmpty;

  bool get hasKey => apiKey.isNotEmpty;

  String get chatModel =>
      summaryModel.trim().isEmpty ? provider.defaultSummaryModel : summaryModel.trim();
}

/// La clé API va dans le coffre sécurisé d'Android ; le reste dans les préférences.
class TranscriptionSettingsStore {
  static const _secure = FlutterSecureStorage();
  static const _kProvider = 'stt_provider';
  static const _kConsent = 'stt_consent';
  static String _kKey(SttProvider p) => 'stt_api_key_${p.name}';
  static String _kModel(SttProvider p) => 'stt_summary_model_${p.name}';

  Future<String> loadKey(SttProvider provider) async =>
      await _secure.read(key: _kKey(provider)) ?? '';

  Future<String> loadSummaryModel(SttProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kModel(provider)) ?? '';
  }

  Future<TranscriptionSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kProvider);
    final provider = SttProvider.values
        .firstWhere((p) => p.name == name, orElse: () => SttProvider.groq);
    return TranscriptionSettings(
      provider: provider,
      consent: prefs.getBool(_kConsent) ?? false,
      apiKey: await loadKey(provider),
      summaryModel: prefs.getString(_kModel(provider)) ?? '',
    );
  }

  Future<void> save(TranscriptionSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProvider, s.provider.name);
    await prefs.setBool(_kConsent, s.consent);
    await prefs.setString(_kModel(s.provider), s.summaryModel.trim());
    await _secure.write(key: _kKey(s.provider), value: s.apiKey);
  }
}