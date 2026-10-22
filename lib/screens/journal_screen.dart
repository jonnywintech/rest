import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mood_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';
import '../widgets/mood_widgets.dart';
import 'journal_editor_screen.dart';
import 'mood_checkin_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dnevnik'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            tabs: [Tab(text: 'Raspoloženje'), Tab(text: 'Beleške')],
          ),
        ),
        body: const TabBarView(children: [_MoodTab(), _NotesTab()]),
      ),
    );
  }
}

// ───────────────────────── Raspoloženje ─────────────────────────

class _MoodTab extends ConsumerStatefulWidget {
  const _MoodTab();

  @override
  ConsumerState<_MoodTab> createState() => _MoodTabState();
}

class _MoodTabState extends ConsumerState<_MoodTab> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  void _showDay(DateTime day, List<MoodEntry> entries) {
    final dayEntries = entries.where((e) => isSameDay(e.date, day)).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(formatDate(day),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final e in dayEntries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MoodEntryTile(entry: e),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(moodProvider);
    final now = DateTime.now();
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;
    final monthEntries = entries
        .where((e) => e.date.year == _month.year && e.date.month == _month.month)
        .toList();
    final avg = averageMood(monthEntries);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'mood-fab',
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MoodCheckInScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Zabeleži'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(monthTitle(_month),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      onPressed: isCurrentMonth ? null : () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MoodCalendar(
                    month: _month,
                    entries: monthEntries,
                    onDayTap: (day) => _showDay(day, monthEntries),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final l in moodLevels)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: l.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(l.label,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (avg != null) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(moodLevel(avg).emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Prosek ovog meseca: ${moodLevel(avg).label.toLowerCase()} '
                      '(${monthEntries.length} ${plural(monthEntries.length, 'unos', 'unosa', 'unosa')})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const SectionTitle('Svi unosi'),
          if (entries.isEmpty)
            const EmptyState(
              emoji: '🌤️',
              title: 'Još nema unosa',
              text:
                  'Zabeleži kako se osećaš – vremenom ćeš videti obrasce i šta ti prija.',
            )
          else
            for (final e in entries.take(50))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MoodEntryTile(
                  entry: e,
                  onDelete: () =>
                      ref.read(moodProvider.notifier).delete(e.id),
                ),
              ),
        ],
      ),
    );
  }
}

// ───────────────────────── Beleške ─────────────────────────

class _NotesTab extends ConsumerWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'journal-fab',
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JournalEditorScreen())),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Nova beleška'),
      ),
      body: entries.isEmpty
          ? const Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  emoji: '📓',
                  title: 'Dnevnik je prazan',
                  text:
                      'Pisanje pomaže da misli postanu jasnije. Počni sa pitanjem dana ili piši slobodno.',
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = entries[i];
                return AppCard(
                  padding: const EdgeInsets.all(18),
                  radius: 20,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => JournalEditorScreen(entry: e))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${relativeDay(e.date)} · ${formatTime(e.date)}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                      if (e.prompt != null) ...[
                        const SizedBox(height: 6),
                        Text(e.prompt!,
                            style: const TextStyle(
                                color: AppColors.greenDark,
                                fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 6),
                      Text(e.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.45)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
