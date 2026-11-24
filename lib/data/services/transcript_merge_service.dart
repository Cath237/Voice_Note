/// Cohérence entre segments : supprime les répétitions et reconnaît
/// une phrase coupée au milieu entre deux segments.
class TranscriptMergeService {
  static String _normalize(String w) =>
      w.toLowerCase().replaceAll(RegExp(r"[^\p{L}\p{N}']", unicode: true), '');

  /// Retire du début de [next] les mots déjà présents à la fin de [previousTail]
  /// (recouvrement de 2 à [maxOverlapWords] mots).
  String removeOverlap(String previousTail, String next, {int maxOverlapWords = 12}) {
    final prev = previousTail.trim().split(RegExp(r'\s+'));
    final cur = next.trim().split(RegExp(r'\s+'));
    if (prev.isEmpty || cur.isEmpty || prev.first.isEmpty) return next.trim();

    final maxK = [maxOverlapWords, prev.length, cur.length].reduce((a, b) => a < b ? a : b);
    for (var k = maxK; k >= 2; k--) {
      var same = true;
      for (var i = 0; i < k; i++) {
        if (_normalize(prev[prev.length - k + i]) != _normalize(cur[i])) {
          same = false;
          break;
        }
      }
      if (same) return cur.skip(k).join(' ');
    }
    return next.trim();
  }

  /// Vrai si le texte précédent s'arrête au milieu d'une phrase et que le
  /// suivant la continue (pas de point final, minuscule au début).
  bool isContinuation(String previousText, String nextText) {
    final p = previousText.trimRight();
    final n = nextText.trimLeft();
    if (p.isEmpty || n.isEmpty) return false;
    final endsSentence = RegExp(r'[.!?…:]["»)]?$').hasMatch(p);
    final startsLower = RegExp(r'^\p{Ll}', unicode: true).hasMatch(n);
    return !endsSentence && startsLower;
  }
}