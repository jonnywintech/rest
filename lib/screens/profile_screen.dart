import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_data.dart';
import '../data/courses_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/scoring.dart';
import '../theme.dart';
import '../utils/sr.dart';
import '../widgets/common.dart';
import '../widgets/mood_widgets.dart';
import 'ai_settings_screen.dart';
import 'onboarding/quiz_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tvoje ime'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(fillColor: AppColors.bg),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Otkaži')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Sačuvaj')),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      ref.read(profileProvider.notifier).rename(name.trim());
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obrisati sve podatke?'),
        content: const Text(
            'Brišu se odgovori iz kviza, napredak kroz izazov, raspoloženja, beleške i razgovor sa Mirom. API ključ ostaje. Ovo ne može da se poništi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Otkaži')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Obriši sve',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await resetAllData(ref);
  }

  void _showCrisisHelp(BuildContext context, Gender gender) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Text('🆘', style: TextStyle(fontSize: 44)),
        title: const Text('Pomoć u krizi'),
        content: Text(
          gt(
            'Ako si u neposrednoj opasnosti ili razmišljaš o tome da sebi naudiš, odmah potraži pomoć:\n\n'
            '• Hitna pomoć: 194\n'
            '• Centar Srce – emotivna podrška: 0800 300 303 (besplatno, svaki dan 14–23h) ili čet na centarsrce.org\n'
            '• Javi se nekome kome veruješ ili svom lekaru.\n\n'
            'Nisi sam{|a} u ovome.',
            gender,
          ),
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Razumem'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O aplikaciji'),
        content: const Text(
          'Predah je lična aplikacija za samopomoć kod stresa i izgaranja.\n\n'
          'Sadržaj je informativan i ne zamenjuje savet lekara, psihologa ili psihoterapeuta. Procena iz kviza je orijentaciona i nije dijagnoza.\n\n'
          'Svi podaci se čuvaju samo na ovom uređaju. Poruke Miri se šalju Google Gemini API-ju.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final challenge = ref.watch(challengeProvider);
    final moods = ref.watch(moodProvider);
    final journal = ref.watch(journalProvider);
    final lessons = ref.watch(lessonsProvider);
    final streak = ref.watch(streakProvider);
    final latest = profile.latest;
    final first = profile.first;

    final emotionCounts = <String, int>{};
    final triggerCounts = <String, int>{};
    for (final m in moods) {
      for (final e in m.emotions) {
        emotionCounts[e] = (emotionCounts[e] ?? 0) + 1;
      }
      for (final t in m.triggers) {
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
    }
    List<MapEntry<String, int>> top(Map<String, int> counts) =>
        (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Zaglavlje
          AppCard(
            onTap: () => _rename(context, ref, profile.name),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    profile.name.isEmpty ? '🙂' : profile.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name.isEmpty ? 'Bez imena' : profile.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      if (profile.startedAt != null)
                        Text('U izazovu od ${formatDate(profile.startedAt!)}',
                            style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Statistika
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatTile('🏁', '${challenge.completedCount}/$challengeLength',
                  'završenih dana'),
              _StatTile('🔥', '$streak',
                  '${plural(streak, 'dan', 'dana', 'dana')} zaredom'),
              _StatTile('😊', '${moods.length}', 'unosa raspoloženja'),
              _StatTile('✍️', '${journal.length}',
                  plural(journal.length, 'beleška', 'beleške', 'beležaka')),
              _StatTile('📚', '${lessons.length}/$totalLessons', 'lekcija'),
              _StatTile('💬', '${ref.watch(chatProvider).messages.where((m) => m.isUser).length}',
                  'poruka Miri'),
            ],
          ),
          const SizedBox(height: 16),

          // Raspoloženje
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Raspoloženje – poslednjih 14 dana',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                MoodBarsChart(entries: moods),
                if (emotionCounts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Najčešća osećanja',
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final e in top(emotionCounts))
                      Pill('${e.key} · ${e.value}', color: AppColors.bg),
                  ]),
                ],
                if (triggerCounts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Najčešći okidači',
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final e in top(triggerCounts))
                      Pill('${e.key} · ${e.value}', color: AppColors.bg),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Procena izgaranja
          if (latest != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Procena izgaranja',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Poslednja: ${formatDate(latest.date)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(levelFor(latest.score).label,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: levelFor(latest.score).color)),
                      const Spacer(),
                      Text('${latest.score}/100',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BurnoutGauge(score: latest.score),
                  if (first != null && profile.assessments.length > 1) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Na početku: ${first.score} → sada: ${latest.score}'
                      '${latest.score < first.score ? '  (−${first.score - latest.score}) 🎉' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(gender: profile.gender, retake: true),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Ponovi procenu'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Podešavanja
          const SectionTitle('Podešavanja'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🌿', style: TextStyle(fontSize: 22)),
                  title: const Text('Mira (AI)'),
                  subtitle: Text(settings.hasKey
                      ? 'Povezano · ${settings.model}'
                      : 'Dodaj Gemini API ključ'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AiSettingsScreen())),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: const Text('🔓', style: TextStyle(fontSize: 22)),
                  title: const Text('Bez čekanja'),
                  subtitle: const Text(
                      'Sledeći dan izazova se otključava odmah, a ne sutradan'),
                  value: settings.unlockAll,
                  activeThumbColor: AppColors.green,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .update(settings.copyWith(unlockAll: v)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Text('🆘', style: TextStyle(fontSize: 22)),
                  title: const Text('Pomoć u krizi'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showCrisisHelp(context, profile.gender),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Text('ℹ️', style: TextStyle(fontSize: 22)),
                  title: const Text('O aplikaciji'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAbout(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: AppColors.danger),
                  title: const Text('Obriši sve podatke',
                      style: TextStyle(color: AppColors.danger)),
                  onTap: () => _reset(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.emoji, this.value, this.label);

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}
