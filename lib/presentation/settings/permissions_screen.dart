import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';

/// État des permissions réellement nécessaires, avec un bouton pour chacune.
/// Le stockage n'a pas besoin de permission : les réunions sont dans l'espace
/// privé de l'application.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with WidgetsBindingObserver {
  bool? _mic;
  bool? _notif;
  bool? _battery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Au retour des réglages du téléphone, on relit l'état.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final mic = await Permission.microphone.isGranted;
    final notif = await Permission.notification.isGranted;
    final battery = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    if (!mounted) return;
    setState(() {
      _mic = mic;
      _notif = notif;
      _battery = battery;
    });
  }

  Future<void> _fixMic() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) await openAppSettings();
    await _refresh();
  }

  Future<void> _fixNotif() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) await openAppSettings();
    await _refresh();
  }

  Future<void> _fixBattery() async {
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    await _refresh();
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String why,
    required bool? ok,
    required VoidCallback onFix,
    String fixLabel = 'Autoriser',
  }) {
    final color = ok == true ? AppColors.done : AppColors.processing;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ok == null ? '...' : (ok ? 'Autorisé' : 'À autoriser'),
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(why, style: Theme.of(context).textTheme.bodySmall),
          if (ok == false) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onFix, child: Text(fixLabel)),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions et fiabilité')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _tile(
          icon: Icons.mic_none_rounded,
          title: 'Microphone',
          why: 'Indispensable pour enregistrer vos réunions. L\'audio reste sur votre téléphone.',
          ok: _mic,
          onFix: _fixMic,
        ),
        _tile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          why: 'Affichent « Réunion en cours » pendant l\'enregistrement. Sans elles, '
              'l\'enregistrement fonctionne, mais vous ne le voyez pas en dehors de l\'application.',
          ok: _notif,
          onFix: _fixNotif,
        ),
        _tile(
          icon: Icons.battery_charging_full_rounded,
          title: 'Économie d\'énergie',
          why: 'Pour une longue réunion, écran verrouillé, Android peut fermer une application '
              'qu\'il juge « gourmande ». Autorisez VoiceNote à ne pas être limitée.',
          ok: _battery,
          onFix: _fixBattery,
          fixLabel: 'Ne pas limiter VoiceNote',
        ),
        const SizedBox(height: 6),
        Card(
          color: AppColors.blue.withOpacity(0.06),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Sur certains téléphones (Tecno, Infinix, Xiaomi, Huawei...), il faut aussi '
                  'ouvrir les réglages de batterie ou de démarrage du téléphone et autoriser '
                  'VoiceNote à rester active en arrière-plan, ou la verrouiller dans la liste '
                  'des applications récentes. Les noms des menus changent d\'un modèle à l\'autre.',
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: openAppSettings,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Ouvrir les réglages de l\'application'),
        ),
      ]),
    );
  }
}