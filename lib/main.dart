import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/services/app_settings.dart';
import 'presentation/shell/home_shell.dart';
import 'providers.dart';
import 'core/utils/toast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await initializeDateFormatting('fr'); // dates en français
  final settings = await AppSettingsStore.load();
  runApp(ProviderScope(
    overrides: [initialSettingsProvider.overrideWithValue(settings)],
    child: const VoiceNoteApp(),
  ));
}

class VoiceNoteApp extends ConsumerStatefulWidget {
  const VoiceNoteApp({super.key});

  @override
  ConsumerState<VoiceNoteApp> createState() => _VoiceNoteAppState();
}

class _VoiceNoteAppState extends ConsumerState<VoiceNoteApp> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: 'VoiceNote',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // La taille choisie s'ajoute à celle du réglage d'accessibilité Android.
      builder: (context, child) {
        final system = MediaQuery.textScalerOf(context).scale(1.0);
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(system * settings.textScale)),
          child: child!,
        );
      },
      home: const HomeShell(),
    );
  }
}