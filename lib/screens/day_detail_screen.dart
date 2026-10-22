import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';

class DayDetailScreen extends ConsumerStatefulWidget {
  const DayDetailScreen({super.key, required this.day});

  final int day;

  @override
  ConsumerState<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends ConsumerState<DayDetailScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(challengeProvider).reflections[widget.day] ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveToJournal(String reflection, Gender gender) {
    if (reflection.isEmpty) return;
    final day = dayContent(widget.day);
    ref.read(journalProvider.notifier).upsert(JournalEntry(
          id: 'day-${widget.day}',
          date: DateTime.now(),
          prompt: 'Dan ${widget.day} · ${gt(day.reflection, gender)}',
          text: reflection,
        ));
  }

  Future<void> _complete(Gender gender) async {
    final text = _controller.text.trim();
    ref.read(challengeProvider.notifier).complete(widget.day, text);
    _saveToJournal(text, gender);

    final unlockAll = ref.read(settingsProvider).unlockAll;
    final isLast = widget.day == challengeLength;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Text(isLast ? '🏆' : '🎉', style: const TextStyle(fontSize: 56)),
        title: Text('Dan ${widget.day} je završen!', textAlign: TextAlign.center),
        content: Text(
          isLast
              ? gt('Završi{o|la} si ceo izazov. Ponosi se sobom – i ponovi procenu u Profilu da vidiš napredak.', gender)
              : unlockAll
                  ? 'Svaka čast! Sledeći dan je otključan.'
                  : 'Svaka čast! Sledeći korak te čeka sutra. Mali koraci, veliki efekat.',
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.45),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Super'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _saveReflection(Gender gender) {
    final text = _controller.text.trim();
    ref.read(challengeProvider.notifier).saveReflection(widget.day, text);
    _saveToJournal(text, gender);
    FocusScope.of(context).unfocus();
    showSnack(context, 'Sačuvano u dnevnik ✍️');
  }

  @override
  Widget build(BuildContext context) {
    final day = dayContent(widget.day);
    final week = weekOf(widget.day);
    final gender = ref.watch(genderProvider);
    final completedAt = ref.watch(challengeProvider).completed[widget.day];

    return Scaffold(
      appBar: AppBar(title: Text('Dan ${widget.day}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(day.emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill('Nedelja ${week.number} · ${week.title}',
                        color: AppColors.greenLight,
                        textColor: AppColors.greenDark),
                    Pill('⏱️ ${day.minutes} min'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(day.title,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 20),
                Paragraphs([for (final p in day.lesson) gt(p, gender)]),
                const SizedBox(height: 8),
                AppCard(
                  color: AppColors.greenLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯 Zadatak za danas',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(gt(day.task, gender),
                          style: const TextStyle(fontSize: 16, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💭 Za razmišljanje',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(gt(day.reflection, gender),
                          style: const TextStyle(
                              fontSize: 16, height: 1.45, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _controller,
                        minLines: 4,
                        maxLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Zapiši svoje misli… (čuva se i u Dnevniku)',
                          fillColor: AppColors.bg,
                        ),
                      ),
                    ],
                  ),
                ),
                if (completedAt != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '✅ Završeno ${formatDate(completedAt)}',
                      style: const TextStyle(
                          color: AppColors.greenDark, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          BottomCta(
            child: completedAt == null
                ? FilledButton(
                    onPressed: () => _complete(gender),
                    child: Text('Završi dan ${widget.day}'),
                  )
                : OutlinedButton(
                    onPressed: () => _saveReflection(gender),
                    child: const Text('Sačuvaj odgovor'),
                  ),
          ),
        ],
      ),
    );
  }
}
