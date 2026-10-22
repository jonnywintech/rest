import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_data.dart';
import '../data/courses_data.dart';
import '../data/mood_data.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';
import 'course_screen.dart';
import 'day_detail_screen.dart';
import 'journal_editor_screen.dart';
import 'mood_checkin_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final gender = profile.gender;
    final streak = ref.watch(streakProvider);
    final moods = ref.watch(moodProvider);
    final now = DateTime.now();
    final todayMood =
        moods.where((m) => isSameDay(m.date, now)).firstOrNull;
    final prompt = gt(promptOfTheDay(now), gender);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isEmpty
                          ? '${greeting(now)}!'
                          : '${greeting(now)},\n${profile.name}!',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(formatLongDate(now),
                        style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              Tooltip(
                message: 'Uzastopni dani sa aktivnošću',
                child: Pill('🔥 $streak', color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _TodayChallengeCard(),
          const SizedBox(height: 16),

          // Raspoloženje
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kako se osećaš?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final level in moodLevels)
                      _MoodButton(
                        emoji: level.emoji,
                        label: level.label,
                        color: level.color,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MoodCheckInScreen(initialMood: level.value),
                          ),
                        ),
                      ),
                  ],
                ),
                if (todayMood != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Danas u ${formatTime(todayMood.date)}: '
                    '${moodLevel(todayMood.mood).emoji} ${moodLevel(todayMood.mood).label}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pitanje dana
          AppCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JournalEditorScreen(prompt: prompt),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✍️ Pitanje dana',
                          style: TextStyle(
                              color: AppColors.greenDark,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(prompt,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.edit_note_rounded,
                    color: AppColors.blue, size: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mira
          AppCard(
            color: AppColors.blueLight,
            onTap: () => ref.read(tabIndexProvider.notifier).select(2),
            child: const Row(
              children: [
                MiraAvatar(size: 52),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Treba ti razgovor?',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text(
                        'Mira je tu da te sasluša i pomogne ti da sagledaš situaciju.',
                        style: TextStyle(color: AppColors.muted, height: 1.35),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.blue),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Kratki kursevi'),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _CourseCard(course: courses[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayChallengeCard extends ConsumerWidget {
  const _TodayChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(challengeProvider);
    final unlockAll = ref.watch(settingsProvider.select((s) => s.unlockAll));
    final gender = ref.watch(genderProvider);
    final current = challenge.currentDay;
    final finished = current > challengeLength;
    final unlocked =
        !finished && challenge.isUnlocked(current, unlockAll: unlockAll);

    const white = TextStyle(color: Colors.white);
    final String label;
    final String title;
    final String subtitle;
    if (finished) {
      label = 'IZAZOV ZAVRŠEN';
      title = gt('Uspe{o|la} si! 🎉', gender);
      subtitle = 'Svih 28 dana je iza tebe. Ponovi procenu u Profilu.';
    } else if (unlocked) {
      final day = dayContent(current);
      label = 'DAN $current OD $challengeLength';
      title = '${day.emoji} ${day.title}';
      subtitle = 'Nedelja ${weekOf(current).number} · ${weekOf(current).title} · ${day.minutes} min';
    } else {
      label = 'DANAŠNJI DAN JE ZAVRŠEN ✅';
      title = 'Svaka čast!';
      subtitle = 'Dan $current te čeka sutra. Do tada – zabeleži raspoloženje ili piši u dnevnik.';
    }

    return AppCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF62B83A), Color(0xFF3A8F1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: unlocked
          ? () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DayDetailScreen(day: current)))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: white.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Colors.white70)),
          const SizedBox(height: 8),
          Text(title,
              style: white.copyWith(
                  fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 6),
          Text(subtitle, style: white.copyWith(color: Colors.white, height: 1.35)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: challenge.completedCount / challengeLength,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text('${challenge.completedCount}/$challengeLength završeno',
              style: white.copyWith(fontSize: 13, color: Colors.white70)),
          if (unlocked) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.greenDark,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DayDetailScreen(day: current))),
              child: Text(current == 1 && challenge.completedCount == 0
                  ? 'Započni dan 1'
                  : 'Nastavi – dan $current'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(lessonsProvider);
    final count = course.lessons.where((l) => done.contains(l.id)).length;
    return SizedBox(
      width: 160,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseScreen(courseId: course.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: course.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(course.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 12),
            Text(course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, height: 1.25)),
            const Spacer(),
            Text(
              count == course.lessons.length
                  ? '✅ Završeno'
                  : '$count/${course.lessons.length} lekcije',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
