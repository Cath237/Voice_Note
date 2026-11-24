import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Service Android « au premier plan » : empêche le système de fermer
/// l'application pendant l'enregistrement (écran verrouillé, autre appli ouverte)
/// et affiche la notification persistante.
class BackgroundRecordingService {
  void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'voicenote_recording',
        channelName: 'Enregistrement de réunion',
        channelDescription: 'Affichée pendant un enregistrement',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true, // garde le processeur actif écran éteint
      ),
    );
  }

  Future<void> start(String title) async {
    await FlutterForegroundTask.startService(
      serviceId: 4201,
      notificationTitle: '🎙️ Réunion en cours',
      notificationText: title,
    );
  }

  Future<void> updateDuration(String title, String duration) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: '🎙️ Réunion en cours',
      notificationText: '$title : $duration',
    );
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}