import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mood_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({super.key, this.entry, this.prompt});

  /// Postojeća beleška za izmenu.
  final JournalEntry? entry;

  /// Početno pitanje za novu belešku.
  final String? prompt;

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final _controller = TextEditingController(text: widget.entry?.text ?? '');
  late String? _prompt = widget.entry?.prompt ?? widget.prompt;

  bool get _isEditing => widget.entry != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shufflePrompt() {
    final gender = ref.read(genderProvider);
    final options =
        journalPrompts.map((p) => gt(p, gender)).where((p) => p != _prompt).toList();
    setState(() => _prompt = options[Random().nextInt(options.length)]);
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(journalProvider.notifier).upsert(JournalEntry(
          id: widget.entry?.id ?? newId(),
          date: widget.entry?.date ?? DateTime.now(),
          text: text,
          prompt: _prompt,
        ));
    Navigator.of(context).pop();
    showSnack(context, 'Beleška je sačuvana ✍️');
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obrisati belešku?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Otkaži')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Obriši',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(journalProvider.notifier).delete(widget.entry!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? formatDate(widget.entry!.date)
            : 'Nova beleška'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Obriši',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (_prompt != null || !_isEditing)
                  AppCard(
                    color: AppColors.greenLight,
                    padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _prompt ?? 'Piši slobodno ili izaberi pitanje →',
                            style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                height: 1.4),
                          ),
                        ),
                        if (!_isEditing)
                          IconButton(
                            tooltip: 'Drugo pitanje',
                            onPressed: _shufflePrompt,
                            icon: const Icon(Icons.shuffle_rounded,
                                color: AppColors.greenDark),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: !_isEditing,
                  minLines: 12,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16.5, height: 1.5),
                  decoration: const InputDecoration(
                      hintText: 'Šta ti je na umu?'),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          BottomCta(
            child: FilledButton(
              onPressed: _controller.text.trim().isEmpty ? null : _save,
              child: const Text('Sačuvaj'),
            ),
          ),
        ],
      ),
    );
  }
}
