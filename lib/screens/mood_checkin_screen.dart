import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mood_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MoodCheckInScreen extends ConsumerStatefulWidget {
  const MoodCheckInScreen({super.key, this.initialMood});

  final int? initialMood;

  @override
  ConsumerState<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends ConsumerState<MoodCheckInScreen> {
  late int? _mood = widget.initialMood;
  final _emotions = <String>{};
  final _triggers = <String>{};
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(moodProvider.notifier).add(MoodEntry(
          id: newId(),
          date: DateTime.now(),
          mood: _mood!,
          emotions: _emotions.toList(),
          triggers: _triggers.toList(),
          note: _note.text.trim(),
        ));
    Navigator.of(context).pop();
    showSnack(context, 'Raspoloženje je zabeleženo ${moodLevel(_mood!).emoji}');
  }

  Widget _chips(List<String> items, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          FilterChip(
            label: Text(item),
            selected: selected.contains(item),
            showCheckmark: false,
            onSelected: (on) => setState(() {
              on ? selected.add(item) : selected.remove(item);
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pozitivne emocije prvo ako je raspoloženje dobro, inače negativne.
    final positiveFirst = (_mood ?? 3) >= 4;
    final emotionGroups = positiveFirst
        ? [('Prijatna osećanja', positiveEmotions), ('Teška osećanja', negativeEmotions)]
        : [('Teška osećanja', negativeEmotions), ('Prijatna osećanja', positiveEmotions)];

    return Scaffold(
      appBar: AppBar(title: const Text('Kako si?')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const Text('Kako se osećaš sada?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final level in moodLevels)
                      GestureDetector(
                        onTap: () => setState(() => _mood = level.value),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 58,
                              height: 58,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _mood == level.value
                                    ? level.color.withValues(alpha: 0.25)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _mood == level.value
                                      ? level.color
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Text(level.emoji,
                                  style: const TextStyle(fontSize: 30)),
                            ),
                            const SizedBox(height: 6),
                            Text(level.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _mood == level.value
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: _mood == level.value
                                      ? AppColors.ink
                                      : AppColors.muted,
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Šta tačno osećaš?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                for (final (title, items) in emotionGroups) ...[
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  _chips(items, _emotions),
                ],
                const SizedBox(height: 32),
                const Text('Šta je uticalo na to?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _chips(moodTriggers, _triggers),
                const SizedBox(height: 32),
                const Text('Beleška',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(
                  controller: _note,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      hintText: 'Šta se desilo? (opciono)'),
                ),
              ],
            ),
          ),
          BottomCta(
            child: FilledButton(
              onPressed: _mood == null ? null : _save,
              child: const Text('Sačuvaj'),
            ),
          ),
        ],
      ),
    );
  }
}
