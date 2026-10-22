import 'package:flutter/material.dart';

import '../data/mood_data.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/sr.dart';

double? averageMood(Iterable<MoodEntry> entries) {
  if (entries.isEmpty) return null;
  return entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
}

/// Mesečni kalendar raspoloženja (ponedeljak je prvi dan).
class MoodCalendar extends StatelessWidget {
  const MoodCalendar({
    super.key,
    required this.month,
    required this.entries,
    required this.onDayTap,
  });

  final DateTime month;
  final List<MoodEntry> entries;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday - 1;
    final today = dateOnly(DateTime.now());

    final byDay = <int, List<MoodEntry>>{};
    for (final e in entries) {
      if (e.date.year == month.year && e.date.month == month.month) {
        byDay.putIfAbsent(e.date.day, () => []).add(e);
      }
    }

    return Column(
      children: [
        Row(
          children: [
            for (final d in weekdayShort)
              Expanded(
                child: Center(
                  child: Text(d,
                      style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            for (var i = 0; i < offset; i++) const SizedBox(),
            for (var d = 1; d <= daysInMonth; d++)
              _DayCell(
                day: d,
                average: averageMood(byDay[d] ?? const []),
                isToday: DateTime(month.year, month.month, d) == today,
                onTap: byDay.containsKey(d)
                    ? () => onDayTap(DateTime(month.year, month.month, d))
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.average,
    required this.isToday,
    this.onTap,
  });

  final int day;
  final double? average;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = average == null ? null : moodLevel(average!).color;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? AppColors.bg,
          border: isToday ? Border.all(color: AppColors.ink, width: 2) : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color == null ? AppColors.muted : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Stubičasti prikaz prosečnog raspoloženja za poslednjih [days] dana.
class MoodBarsChart extends StatelessWidget {
  const MoodBarsChart({super.key, required this.entries, this.days = 14});

  final List<MoodEntry> entries;
  final int days;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final dates = [
      for (var i = days - 1; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];
    const maxBar = 90.0;

    return SizedBox(
      height: maxBar + 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in dates)
            Expanded(
              child: Builder(builder: (context) {
                final avg =
                    averageMood(entries.where((e) => isSameDay(e.date, d)));
                return Tooltip(
                  message: avg == null
                      ? '${formatShortDate(d)}: nema unosa'
                      : '${formatShortDate(d)}: ${moodLevel(avg).label}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: avg == null ? 4 : 14 + (avg - 1) / 4 * (maxBar - 14),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: avg == null ? AppColors.line : moodLevel(avg).color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weekdayShort[d.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          color: d == today ? AppColors.ink : AppColors.muted,
                          fontWeight:
                              d == today ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class MoodEntryTile extends StatelessWidget {
  const MoodEntryTile({super.key, required this.entry, this.onDelete});

  final MoodEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final level = moodLevel(entry.mood);
    final tags = [...entry.emotions, ...entry.triggers];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(level.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                Text('${relativeDay(entry.date)} u ${formatTime(entry.date)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(tags.join(' · '),
                      style: const TextStyle(fontSize: 13.5, height: 1.4)),
                ],
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('„${entry.note}“',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Obriši',
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}
