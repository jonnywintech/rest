import 'package:flutter_test/flutter_test.dart';
import 'package:predah/data/challenge_data.dart';
import 'package:predah/data/courses_data.dart';
import 'package:predah/data/mood_data.dart';
import 'package:predah/data/quiz_data.dart';
import 'package:predah/models/models.dart';
import 'package:predah/providers/providers.dart';
import 'package:predah/services/scoring.dart';
import 'package:predah/utils/sr.dart';

void main() {
  group('gt (rodni oblici)', () {
    test('bira muški ili ženski oblik', () {
      const text = 'Umor{an|na} sam i nisam sam{|a}.';
      expect(gt(text, Gender.male), 'Umoran sam i nisam sam.');
      expect(gt(text, Gender.female), 'Umorna sam i nisam sama.');
    });

    test('sav sadržaj ima ispravne rodne šablone', () {
      final texts = [
        for (final s in quizSteps) ...[s.title, s.subtitle ?? ''],
        for (final d in challengeDays) ...[...d.lesson, d.task, d.reflection],
        for (final c in courses)
          for (final l in c.lessons) ...l.paragraphs,
        ...journalPrompts,
      ];
      for (final t in texts) {
        for (final g in Gender.values) {
          final out = gt(t, g);
          expect(out.contains('{'), isFalse, reason: t);
          expect(out.contains('|'), isFalse, reason: t);
        }
      }
    });
  });

  test('izazov ima 28 dana u ispravnom redosledu', () {
    expect(challengeDays.length, challengeLength);
    for (var i = 0; i < challengeDays.length; i++) {
      expect(challengeDays[i].day, i + 1);
    }
  });

  test('srpska množina', () {
    expect(plural(1, 'dan', 'dana', 'dana'), 'dan');
    expect(plural(3, 'beleška', 'beleške', 'beležaka'), 'beleške');
    expect(plural(11, 'beleška', 'beleške', 'beležaka'), 'beležaka');
    expect(plural(21, 'dan', 'dana', 'dana'), 'dan');
  });

  group('procena izgaranja', () {
    test('najblaži odgovori daju 0', () {
      final a = computeAssessment({
        for (final id in scaleIds) id: 0,
        'sleep': '7_8',
        'day_end': 'good',
        'symptoms': ['none'],
      });
      expect(a.score, 0);
      expect(levelFor(a.score).label, 'Nizak');
    });

    test('najteži odgovori daju 100', () {
      final a = computeAssessment({
        for (final id in scaleIds) id: 4,
        'sleep': 'lt5',
        'day_end': 'exhausted',
        'symptoms': ['headache', 'tension', 'sleep', 'appetite', 'emptiness'],
      });
      expect(a.score, 100);
      expect(levelFor(a.score).label, 'Vrlo visok');
    });
  });

  group('otključavanje dana', () {
    test('dan 1 je uvek otključan, dan 2 tek posle dana 1', () {
      const s = ChallengeState();
      expect(s.isUnlocked(1, unlockAll: false), isTrue);
      expect(s.isUnlocked(2, unlockAll: true), isFalse);
    });

    test('sledeći dan se otključava sutradan ili odmah uz opciju', () {
      final now = DateTime.now();
      final today = ChallengeState(completed: {1: now});
      expect(today.isUnlocked(2, unlockAll: false), isFalse);
      expect(today.isUnlocked(2, unlockAll: true), isTrue);

      final earlier = ChallengeState(
          completed: {1: DateTime(now.year, now.month, now.day - 1, 12)});
      expect(earlier.isUnlocked(2, unlockAll: false), isTrue);
      expect(earlier.currentDay, 2);
    });
  });
}
