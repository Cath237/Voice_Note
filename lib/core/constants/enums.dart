/// États possibles d'un segment audio dans la file de transcription.
enum SegmentStatus { pending, processing, completed, failed, retrying }

/// États possibles d'une réunion.
enum MeetingStatus { recording, paused, recorded, transcribing, completed, error }

/// Types de notes et de marqueurs ajoutés pendant la réunion.
enum MarkerType { note, important, decision, verify, action, question }

/// Découpage de l'enregistrement en segments.
enum SegmentationMode { auto, fiveMinutes, tenMinutes }

extension SegmentationDuration on SegmentationMode {
  /// "Automatique" = 5 minutes (bon compromis taille / contexte / reprise).
  Duration get duration => switch (this) {
    SegmentationMode.auto => const Duration(minutes: 5),
    SegmentationMode.fiveMinutes => const Duration(minutes: 5),
    SegmentationMode.tenMinutes => const Duration(minutes: 10),
  };
}

/// Nombre maximal de tentatives pour transcrire un segment.
const kMaxRetries = 5;