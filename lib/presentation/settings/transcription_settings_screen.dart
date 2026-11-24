import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/transcription_settings.dart';
import '../../providers.dart';
import '../../core/utils/toast.dart';

class TranscriptionSettingsScreen extends ConsumerStatefulWidget {
  const TranscriptionSettingsScreen({super.key});

  @override
  ConsumerState<TranscriptionSettingsScreen> createState() =>
      _TranscriptionSettingsScreenState();
}

class _TranscriptionSettingsScreenState
    extends ConsumerState<TranscriptionSettingsScreen> {
  final _keyController = TextEditingController();
  final _modelController = TextEditingController();
  SttProvider _provider = SttProvider.groq;
  bool _consent = false;
  bool _hideKey = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = await ref.read(transcriptionSettingsStoreProvider).load();
    if (!mounted) return;
    setState(() {
      _provider = s.provider;
      _consent = s.consent;
      _keyController.text = s.apiKey;
      _modelController.text = s.summaryModel;
      _loaded = true;
    });
  }

  /// Chaque service a sa propre clé et son propre modèle de résumé.
  Future<void> _changeProvider(SttProvider p) async {
    final store = ref.read(transcriptionSettingsStoreProvider);
    final key = await store.loadKey(p);
    final model = await store.loadSummaryModel(p);
    if (!mounted) return;
    setState(() {
      _provider = p;
      _keyController.text = key;
      _modelController.text = model;
    });
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (_consent && key.isEmpty) {
      AppToast.show('Collez votre clé API', type: ToastType.warning);
      return;
    }
    await ref.read(transcriptionSettingsStoreProvider).save(TranscriptionSettings(
      provider: _provider,
      consent: _consent,
      apiKey: key,
      summaryModel: _modelController.text.trim(),
    ));
    ref.invalidate(transcriptionSettingsProvider);
    if (!mounted) return;
    AppToast.show('Réglages enregistrés', type: ToastType.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transcription')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transcription')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Service', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<SttProvider>(
          segments: [
            for (final p in SttProvider.values)
              ButtonSegment(value: p, label: Text(p.label)),
          ],
          selected: {_provider},
          onSelectionChanged: (s) => _changeProvider(s.first),
        ),
        const SizedBox(height: 10),
        Text(_provider.description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 18),
        TextField(
          controller: _keyController,
          obscureText: _hideKey,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Clé API ${_provider.label}',
            suffixIcon: IconButton(
              icon: Icon(_hideKey ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _hideKey = !_hideKey),
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _modelController,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Modèle de résumé',
            hintText: _provider.defaultSummaryModel,
            helperText: 'Laissez vide pour le modèle par défaut. À changer seulement '
                'si le service retire ce modèle (liste sur son site).',
            helperMaxLines: 3,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: SwitchListTile(
            value: _consent,
            onChanged: (v) => setState(() => _consent = v),
            title: const Text('Autoriser l\'envoi de l\'audio'),
            subtitle: Text(
                'L\'audio de vos réunions est envoyé à ${_provider.label} pour être transcrit. '
                    'Sans cet accord, rien ne quitte votre téléphone.'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ces services sont facturés par leurs éditeurs : vérifiez leurs tarifs. '
              'Votre clé est conservée dans le coffre sécurisé du téléphone.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _save, child: const Text('Enregistrer')),
      ]),
    );
  }
}