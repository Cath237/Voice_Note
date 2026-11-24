import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';

class AppSettings {
  final ThemeMode themeMode; // clair par défaut
  final double textScale; // 0.9 petit, 1.0 normal, 1.15 grand
  final SegmentationMode segmentation;
  final bool highQuality;
  final String defaultLanguage; // auto | fr | en

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.textScale = 1.0,
    this.segmentation = SegmentationMode.auto,
    this.highQuality = false,
    this.defaultLanguage = 'auto',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? textScale,
    SegmentationMode? segmentation,
    bool? highQuality,
    String? defaultLanguage,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        textScale: textScale ?? this.textScale,
        segmentation: segmentation ?? this.segmentation,
        highQuality: highQuality ?? this.highQuality,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      );
}

class AppSettingsStore {
  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return AppSettings(
      themeMode: p.getBool('dark_mode') == true ? ThemeMode.dark : ThemeMode.light,
      textScale: p.getDouble('text_scale') ?? 1.0,
      segmentation: SegmentationMode.values.firstWhere(
            (m) => m.name == p.getString('segmentation'),
        orElse: () => SegmentationMode.auto,
      ),
      highQuality: p.getBool('high_quality') ?? false,
      defaultLanguage: p.getString('default_language') ?? 'auto',
    );
  }

  static Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', s.themeMode == ThemeMode.dark);
    await p.setDouble('text_scale', s.textScale);
    await p.setString('segmentation', s.segmentation.name);
    await p.setBool('high_quality', s.highQuality);
    await p.setString('default_language', s.defaultLanguage);
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(super.initial);

  void change(AppSettings Function(AppSettings current) update) {
    state = update(state);
    AppSettingsStore.save(state);
  }
}

/// Chargés AVANT l'affichage (voir main.dart) : pas de flash en mode clair
/// quand l'utilisateur a choisi le mode sombre.
final initialSettingsProvider =
Provider<AppSettings>((ref) => throw UnimplementedError('Réglages non chargés'));

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(ref.watch(initialSettingsProvider)),
);