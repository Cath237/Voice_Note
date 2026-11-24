import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../providers.dart';
import 'recording_screen.dart';
import '../../data/services/app_settings.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMeetingScreen extends ConsumerStatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  ConsumerState<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends ConsumerState<NewMeetingScreen> {
  static const _categories = [
    'Réunion professionnelle',
    'Réunion de direction',
    'Réunion client',
    'Entretien',
    'Formation',
    'Conférence',
    'Autre',
  ];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _participants = TextEditingController();
  final _dictionary = TextEditingController();
  final _dateField = TextEditingController();

  DateTime _date = DateTime.now();
  String _language = 'auto';
  String _category = _categories.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _language = ref.read(appSettingsProvider).defaultLanguage;
    _dateField.text = DateFormat('d MMMM y', 'fr').format(_date);
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _location, _participants, _dictionary, _dateField]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _split(String text) =>
      text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateField.text = DateFormat('d MMMM y', 'fr').format(picked);
      });
    }
  }

  /// Explique pourquoi, puis demande le micro. Retourne true si on peut enregistrer.
  Future<bool> _ensureMicrophone() async {
    if (await Permission.microphone.isGranted) return true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Accès au microphone'),
        content: const Text(
            'VoiceNote enregistre l\'audio de la réunion sur votre téléphone. '
                'Sans le microphone, l\'enregistrement est impossible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    final status = await Permission.microphone.request();
    // Notification de l'enregistrement en cours (Android 13+), non bloquante.
    await Permission.notification.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied && mounted) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Microphone refusé'),
          content: const Text(
              'Autorisez le microphone dans les réglages du téléphone pour enregistrer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Fermer')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
              onPressed: () {
                openAppSettings();
                Navigator.pop(c);
              },
              child: const Text('Ouvrir les réglages'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _ensureMicrophone() || !mounted) return;
    await _offerBatteryExemption();
    if (!mounted) return;

    setState(() => _saving = true);
    final id = const Uuid().v4();
    await ref.read(dbProvider).createMeeting(
      id: id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      location: _location.text.trim(),
      category: _category,
      language: _language,
      date: _date,
      participantNames: _split(_participants.text),
      dictionary: _split(_dictionary.text),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RecordingScreen(meetingId: id)),
    );
  }

  /// Une seule fois : propose de ne pas limiter l'application, car l'économie
  /// d'énergie peut couper un long enregistrement écran verrouillé.
  Future<void> _offerBatteryExemption() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('battery_prompted') == true) return;
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await prefs.setBool('battery_prompted', true);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Enregistrements longs'),
        content: const Text(
            'Pour qu\'une réunion de plusieurs heures ne soit pas coupée quand l\'écran '
                'est verrouillé, autorisez VoiceNote à ne pas être limitée par l\'économie '
                'd\'énergie. Vous pourrez le changer dans Paramètres, Permissions et fiabilité.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Plus tard')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
    await prefs.setBool('battery_prompted', true);
    if (ok == true) await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle réunion')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Titre *', hintText: 'Réunion de direction'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Donnez un titre à la réunion' : null,
            ),
            gap,
            TextFormField(
              controller: _description,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Description', hintText: 'Point sur le projet et planning'),
            ),
            gap,
            TextFormField(
              controller: _dateField,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                  labelText: 'Date', suffixIcon: Icon(Icons.calendar_today_outlined)),
            ),
            gap,
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                  labelText: 'Lieu', hintText: 'Salle de conférence'),
            ),
            gap,
            TextFormField(
              controller: _participants,
              decoration: const InputDecoration(
                  labelText: 'Participants',
                  hintText: 'Noms séparés par des virgules',
                  suffixIcon: Icon(Icons.group_outlined)),
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Langue'),
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Français / English (auto)')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => setState(() => _language = v!),
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: [
                for (final c in _categories) DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            gap,
            TextFormField(
              controller: _dictionary,
              decoration: const InputDecoration(
                labelText: 'Dictionnaire de la réunion',
                hintText: 'Kloe Shipping, ComptaFlow, SYSCOHADA',
                helperText: 'Noms, entreprises, acronymes : améliore la précision',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _start,
              child: _saving
                  ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Commencer l\'enregistrement'),
            ),
          ],
        ),
      ),
    );
  }
}