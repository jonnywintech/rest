import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/gemini_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

const _models = {
  'gemini-3.8-flash': 'Gemini 3.8 Flash – najpametniji Flash',
  'gemini-3.6-flash': 'Gemini 3.6 Flash – prethodna generacija',
  'gemini-3.5-flash-lite': 'Gemini 3.5 Flash-Lite – najbrži i najjeftiniji',
};

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  late final AppSettings _initial = ref.read(settingsProvider);
  late final _keyController = TextEditingController(text: _initial.apiKey);
  late final _modelController = TextEditingController(text: _initial.model);
  bool _obscure = true;
  bool _testing = false;

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  AppSettings get _draft => ref.read(settingsProvider).copyWith(
        apiKey: _keyController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? AppSettings.defaultModel
            : _modelController.text.trim(),
      );

  void _save() {
    ref.read(settingsProvider.notifier).update(_draft);
    Navigator.of(context).pop();
    showSnack(context, 'Podešavanja za Miru su sačuvana');
  }

  Future<void> _test() async {
    final draft = _draft;
    if (!draft.hasKey) {
      showSnack(context, 'Prvo unesi API ključ.');
      return;
    }
    setState(() => _testing = true);
    try {
      final reply = await GeminiService(
        apiKey: draft.effectiveKey,
        model: draft.model,
      ).generate(
        systemPrompt: 'Odgovaraj kratko, na srpskom jeziku, latinicom.',
        turns: const [ChatTurn('user', 'Pozdravi me u jednoj kratkoj rečenici.')],
      );
      if (mounted) showSnack(context, '✅ Radi! Mira kaže: $reply');
    } on GeminiException catch (e) {
      if (mounted) showSnack(context, '❌ ${e.message}');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mira (AI)')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const AppCard(
            color: AppColors.blueLight,
            child: Text(
              'Mira koristi Google Gemini. Besplatan ključ napravi na aistudio.google.com → „Get API key“ i nalepi ga ispod.\n\n'
              'Ključ se čuva samo na ovom uređaju. Poruke koje pišeš Miri, zajedno sa kratkim opisom tvog profila (rezultat kviza, ciljevi, poslednja raspoloženja), šalju se Google-u radi generisanja odgovora.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Gemini API ključ',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: AppSettings.envApiKey.isNotEmpty
                  ? 'Koristi se ključ iz --dart-define'
                  : 'AIza…',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Model', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _modelController,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: AppSettings.defaultModel),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _models.entries)
                ChoiceChip(
                  label: Text(entry.key),
                  tooltip: entry.value,
                  selected: _modelController.text.trim() == entry.key,
                  onSelected: (_) =>
                      setState(() => _modelController.text = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: _testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.bolt_rounded),
            label: const Text('Testiraj vezu'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Sačuvaj')),
        ],
      ),
    );
  }
}
