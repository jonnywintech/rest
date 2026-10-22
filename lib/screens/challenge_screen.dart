import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_data.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';
import 'day_detail_screen.dart';

enum _DayStatus { done, open, locked }

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(challengeProvider);
    final unlockAll = ref.watch(settingsProvider.select((s) => s.unlockAll));
    final gender = ref.watch(genderProvider);
    final done = challenge.completedCount;

    _DayStatus statusOf(int day) {
      if (challenge.isDone(day)) return _DayStatus.done;
      if (challenge.isUnlocked(day, unlockAll: unlockAll)) return _DayStatus.open;
      return _DayStatus.locked;
    }

    void open(int day) {
      final status = statusOf(day);
      if (status == _DayStatus.locked) {
        final previousDone = challenge.isDone(day - 1);
        showSnack(
          context,
          previousDone
              ? 'Dan $day se otključava sutra 🌙'
              : gt('Prvo završi dan ${challenge.currentDay} da bi otključa{o|la} sledeće.', gender),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DayDetailScreen(day: day)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('28-dnevni izazov')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: done / challengeLength,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        color: AppColors.green,
                        backgroundColor: AppColors.bg,
                      ),
                      Center(
                        child: Text('$done',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$done od $challengeLength ${plural(done, 'dan', 'dana', 'dana')}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        done == challengeLength
                            ? 'Izazov je završen. Bravo!'
                            : 'Jedan mali korak dnevno. Bez žurbe.',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final week in challengeWeeks) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                Text(week.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEDELJA ${week.number}',
                          style: const TextStyle(
                              color: AppColors.greenDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                      Text(week.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(week.subtitle, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            for (var d = (week.number - 1) * 7 + 1; d <= week.number * 7; d++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayRow(
                  day: dayContent(d),
                  status: statusOf(d),
                  isCurrent: d == challenge.currentDay,
                  onTap: () => open(d),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.status,
    required this.isCurrent,
    required this.onTap,
  });

  final ChallengeDay day;
  final _DayStatus status;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget leading = switch (status) {
      _DayStatus.done => Container(
          decoration: const BoxDecoration(
              color: AppColors.green, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white),
        ),
      _DayStatus.open => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blue, width: 2),
          ),
          child: Text('${day.day}',
              style: const TextStyle(
                  color: AppColors.blue, fontWeight: FontWeight.w800)),
        ),
      _DayStatus.locked => Container(
          decoration: const BoxDecoration(
              color: AppColors.bg, shape: BoxShape.circle),
          child: const Icon(Icons.lock_rounded, color: AppColors.muted, size: 18),
        ),
    };

    return Opacity(
      opacity: status == _DayStatus.locked ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        radius: 20,
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(width: 44, height: 44, child: leading),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dan ${day.day}${isCurrent && status == _DayStatus.open ? ' · danas' : ''}',
                      style: TextStyle(
                          fontSize: 13,
                          color: isCurrent && status == _DayStatus.open
                              ? AppColors.blue
                              : AppColors.muted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${day.emoji} ${day.title}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Text('${day.minutes} min',
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
