/// Résumé structuré d'une réunion. Le même format sert à la réponse du
/// service, à l'enregistrement en base et à l'affichage.

List<String> _strings(dynamic value) {
  if (value is String) return value.trim().isEmpty ? [] : [value.trim()];
  if (value is! List) return [];
  return value
      .map((e) => e is Map ? e.values.join(' ') : '$e')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

String _text(dynamic value, {String fallback = 'Non précisé'}) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty ? fallback : s;
}

class SummaryAction {
  final String action;
  final String owner;
  final String due;
  const SummaryAction(this.action, this.owner, this.due);

  factory SummaryAction.fromJson(dynamic json) {
    if (json is Map) {
      return SummaryAction(
        _text(json['action'] ?? json['task'], fallback: ''),
        _text(json['owner'] ?? json['responsable']),
        _text(json['due'] ?? json['deadline'] ?? json['echeance']),
      );
    }
    return SummaryAction(_text(json, fallback: ''), 'Non précisé', 'Non précisé');
  }

  Map<String, dynamic> toJson() => {'action': action, 'owner': owner, 'due': due};
}

class SummaryData {
  final String overview;
  final List<String> keyPoints;
  final List<String> decisions;
  final List<SummaryAction> actions;
  final List<String> openQuestions;
  final List<String> topics;
  final DateTime generatedAt;
  final String model;

  const SummaryData({
    required this.overview,
    required this.keyPoints,
    required this.decisions,
    required this.actions,
    required this.openQuestions,
    required this.topics,
    required this.generatedAt,
    required this.model,
  });

  factory SummaryData.fromJson(Map<String, dynamic> j, {DateTime? generatedAt, String? model}) {
    final rawActions = j['actions'];
    return SummaryData(
      overview: _text(j['summary'] ?? j['overview'], fallback: ''),
      keyPoints: _strings(j['key_points']),
      decisions: _strings(j['decisions']),
      actions: rawActions is List
          ? rawActions.map(SummaryAction.fromJson).where((a) => a.action.isNotEmpty).toList()
          : [],
      openQuestions: _strings(j['open_questions']),
      topics: _strings(j['topics']),
      generatedAt: DateTime.tryParse('${j['generated_at']}') ?? generatedAt ?? DateTime.now(),
      model: (j['model'] as String?) ?? model ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': overview,
    'key_points': keyPoints,
    'decisions': decisions,
    'actions': actions.map((a) => a.toJson()).toList(),
    'open_questions': openQuestions,
    'topics': topics,
    'generated_at': generatedAt.toIso8601String(),
    'model': model,
  };

  /// Texte pour les documents Word / PDF / TXT.
  /// Les lignes « ## ... » sont des intertitres, les « • ... » des puces.
  String toDocumentText() {
    final b = StringBuffer();
    if (overview.isNotEmpty) {
      b..writeln('## Résumé général')..writeln(overview);
    }
    void list(String title, List<String> items) {
      if (items.isEmpty) return;
      b.writeln('## $title');
      for (final i in items) {
        b.writeln('• $i');
      }
    }

    list('Points principaux', keyPoints);
    list('Décisions prises', decisions);
    if (actions.isNotEmpty) {
      b.writeln('## Actions à effectuer');
      for (final a in actions) {
        b.writeln('• ${a.action} (Responsable : ${a.owner} · Échéance : ${a.due})');
      }
    }
    list('Questions en suspens', openQuestions);
    list('Sujets abordés', topics);
    return b.toString().trimRight();
  }

  /// Texte à copier dans le presse-papiers.
  String toCopyText() => toDocumentText().replaceAll('## ', '\n').trim();
}