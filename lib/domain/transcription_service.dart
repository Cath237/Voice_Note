/// Contrat du moteur de transcription.
/// Ce fichier ne dépend ni de Flutter ni d'un fournisseur : pour changer de
/// service, on écrit une autre classe qui respecte ce contrat, rien d'autre.

class TranscriptChunk {
  /// Temps relatifs au DÉBUT DU SEGMENT audio (la file les convertit).
  final int startMs;
  final int endMs;
  final String text;
  final String language; // fr | en | unknown
  final String? speakerId; // speaker_01... si le fournisseur sait le faire
  final double? noSpeechProb;
  final double? avgLogprob;

  const TranscriptChunk({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.language = 'unknown',
    this.speakerId,
    this.noSpeechProb,
    this.avgLogprob,
  });

  /// Whisper invente parfois des phrases sur du silence
  /// (« Merci d'avoir regardé cette vidéo »). On les écarte.
  bool get isLikelySilence =>
      noSpeechProb != null &&
          noSpeechProb! > 0.6 &&
          (avgLogprob ?? -2.0) < -1.0;
}

class TranscriptResult {
  final List<TranscriptChunk> chunks;
  final String detectedLanguage;
  const TranscriptResult(this.chunks, this.detectedLanguage);
}

/// Indices envoyés au fournisseur pour améliorer noms propres et acronymes.
class TranscriptionHints {
  final String? languageHint; // null = détection automatique
  final String prompt; // dictionnaire + fin du texte précédent
  const TranscriptionHints({this.languageHint, this.prompt = ''});
}

class TranscriptionException implements Exception {
  final String message;

  /// true : la file réessaiera. false : inutile (clé refusée, fichier absent...).
  final bool retryable;
  const TranscriptionException(this.message, {this.retryable = true});

  @override
  String toString() => message;
}

abstract class TranscriptionService {
  /// Transcrit UN segment audio. Lève TranscriptionException en cas d'échec.
  Future<TranscriptResult> transcribeSegment(String audioFilePath, TranscriptionHints hints);

  bool get supportsDiarization;

  /// Vrai si l'audio quitte le téléphone (consentement et indicateur à l'écran).
  bool get sendsAudioToExternalService;
}