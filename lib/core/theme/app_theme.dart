import 'package:flutter/material.dart';

/// Palette tirée du logo VoiceNote : bleu profond + turquoise.
/// Le rouge est réservé à l'enregistrement, aux erreurs et aux actions destructives.
class AppColors {
  static const blue = Color(0xFF1565E0);
  static const deepBlue = Color(0xFF0A2A6B);
  static const turquoise = Color(0xFF14D1C7);
  static const lightGrey = Color(0xFFF3F6FA);
  static const recordRed = Color(0xFFE53935);
  static const done = Color(0xFF2EA66A);
  static const processing = Color(0xFFF59E0B);
  static const waiting = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      secondary: AppColors.turquoise,
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
      b == Brightness.light ? AppColors.lightGrey : const Color(0xFF0B1220),
      cardTheme: CardThemeData(
        elevation: 0,
        color: b == Brightness.light ? Colors.white : const Color(0xFF16203A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52), // boutons larges, faciles à toucher
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}