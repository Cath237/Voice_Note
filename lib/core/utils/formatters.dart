import 'package:intl/intl.dart';

/// 5 025 000 ms -> "01:23:45"
String formatDuration(int ms) {
  final d = Duration(milliseconds: ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

/// 103 500 000 ms -> "28h 45"
String formatTotal(int ms) {
  final d = Duration(milliseconds: ms);
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  return '${d.inHours}h $m';
}

/// "Aujourd'hui", "Hier" ou "5 oct. 2026"
String formatDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return "Aujourd'hui";
  if (diff == 1) return 'Hier';
  return DateFormat('d MMM y', 'fr').format(date);
}


const _accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœ';
const _plain = 'aaaaaaceeeeiiiinooooouuuuyyo';

/// Minuscules et sans accents, en gardant la même longueur de texte :
/// « Écoulé » et « ecoule » se retrouvent mutuellement.
String normalizeForSearch(String text) {
  final buffer = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    final i = _accented.indexOf(ch);
    buffer.write(i >= 0 ? _plain[i] : ch);
  }
  return buffer.toString();
}