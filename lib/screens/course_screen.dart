import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/courses_data.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';

class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = courseById(courseId);
    final done = ref.watch(lessonsProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(tabIndexProvider.notifier).select(0);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Početna'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: course.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(course.emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(course.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(course.description,
              style: const TextStyle(color: AppColors.muted, fontSize: 16)),
          const SizedBox(height: 24),
          for (var i = 0; i < course.lessons.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                radius: 20,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    course: course,
                    lesson: course.lessons[i],
                  ),
                )),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done.contains(course.lessons[i].id)
                            ? AppColors.green
                            : AppColors.bg,
                        shape: BoxShape.circle,
                      ),
                      child: done.contains(course.lessons[i].id)
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : Text('${i + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(course.lessons[i].title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    Text('${course.lessons[i].minutes} min',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(genderProvider);
    final done = ref.watch(lessonsProvider).contains(lesson.id);
    final index = course.lessons.indexOf(lesson);
    final next = index + 1 < course.lessons.length ? course.lessons[index + 1] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            tooltip: 'Početna',
            onPressed: () {
              ref.read(tabIndexProvider.notifier).select(0);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Pill('Lekcija ${index + 1} od ${course.lessons.length} · ${lesson.minutes} min',
                    color: course.color.withValues(alpha: 0.16)),
                const SizedBox(height: 14),
                Text(lesson.title,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 20),
                Paragraphs([for (final p in lesson.paragraphs) gt(p, gender)]),
              ],
            ),
          ),
          BottomCta(
            child: FilledButton(
              onPressed: () {
                ref.read(lessonsProvider.notifier).complete(lesson.id);
                if (next != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => LessonScreen(course: course, lesson: next),
                  ));
                } else {
                  Navigator.of(context).pop();
                  showSnack(context, 'Kurs „${course.title}“ je završen 🎉');
                }
              },
              child: Text(next != null
                  ? (done ? 'Sledeća lekcija' : 'Završi i nastavi')
                  : (done ? 'Nazad na kurs' : 'Završi kurs')),
            ),
          ),
        ],
      ),
    );
  }
}
