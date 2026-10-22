import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/challenge_data.dart';
import '../../data/quiz_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/ai_context.dart';
import '../../services/gemini_service.dart';
import '../../services/scoring.dart';
import '../../theme.dart';
import '../../utils/sr.dart';
import '../../widgets/common.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.gender,
    required this.answers,
    required this.assessment,
    this.retake = false,
  });

  final Gender gender;
  final Map<String, dynamic> answers;
  final Assessment assessment;
  final bool retake;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  String? _aiMessage;
  bool _aiLoading = false;
  late final Assessment? _previous = ref.read(profileProvider).latest;

  String get _name => widget.retake
      ? ref.read(profileProvider).name
      : (widget.answers['name'] as String? ?? '');

  String _t(String text) => gt(text, widget.gender);

  @override
  void initState() {
    super.initState();
    if (ref.read(settingsProvider).hasKey) {
      _aiLoading = true;
      _loadAiMessage();
    }
  }

  Future<void> _loadAiMessage() async {
    final settings = ref.read(settingsProvider);
    try {
      final profile = Profile(
        name: _name,
        gender: widget.gender,
        answers: widget.answers,
        assessments: [widget.assessment],
      );
      final text = await GeminiService(
        apiKey: settings.effectiveKey,
        model: settings.model,
      ).generate(
        systemPrompt:
            miraSystemPrompt(buildUserContext(profile: profile), widget.gender),
        turns: [
          ChatTurn(
            'user',
            _t('Upravo sam završi{o|la} kviz o izgaranju. Na osnovu mog profila napiši mi kratku, toplu i ličnu poruku (3–4 rečenice): šta primećuješ u mojim odgovorima i na šta da obratim pažnju u narednih 28 dana. Bez naslova i bez nabrajanja.'),
          ),
        ],
      );
      if (mounted) setState(() => _aiMessage = text);
    } catch (_) {
      // AI poruka je dodatak – ako ne uspe, ekran radi i bez nje.
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  void _finish() {
    final notifier = ref.read(profileProvider.notifier);
    if (widget.retake) {
      notifier.addAssessment(widget.assessment, widget.answers);
    } else {
      notifier.completeOnboarding(
        name: _name,
        gender: widget.gender,
        answers: widget.answers,
        assessment: widget.assessment,
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    final level = levelFor(a.score);
    final sources = optionLabels('stress_sources', listOf(widget.answers['stress_sources']));
    final goals = optionLabels('goals', listOf(widget.answers['goals']));
    final time = optionLabel('time', widget.answers['time'] as String?);
    final previous = _previous;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  const Center(child: Logo(size: 30)),
                  const SizedBox(height: 20),
                  Text(
                    _name.isEmpty ? 'Tvoj rezultat' : '$_name, ovo je tvoj rezultat',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
                  ),
                  const SizedBox(height: 24),

                  // Nivo izgaranja
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nivo izgaranja',
                            style: TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(level.label,
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: level.color)),
                            ),
                            Text('${a.score}/100',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        BurnoutGauge(score: a.score),
                        const SizedBox(height: 18),
                        Text(level.description,
                            style: const TextStyle(height: 1.5, fontSize: 15.5)),
                        if (widget.retake && previous != null) ...[
                          const SizedBox(height: 14),
                          _ComparisonRow(
                            previous: previous.score,
                            current: a.score,
                            gender: widget.gender,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pokazatelji
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Šta pokazuju tvoji odgovori',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        IndicatorBar(label: 'Iscrpljenost', value: a.exhaustion),
                        IndicatorBar(label: 'Stres i napetost', value: a.stress),
                        IndicatorBar(
                            label: 'Gubitak motivacije', value: a.motivation),
                      ],
                    ),
                  ),

                  // Poruka od Mire (ako postoji API ključ)
                  if (_aiLoading || _aiMessage != null) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      color: AppColors.blueLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              MiraAvatar(size: 36),
                              SizedBox(width: 12),
                              Text('Poruka od Mire',
                                  style: TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_aiLoading)
                            const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Mira piše tvoju poruku…',
                                    style: TextStyle(color: AppColors.muted)),
                              ],
                            )
                          else
                            Text(_aiMessage!,
                                style: const TextStyle(height: 1.5, fontSize: 15.5)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Profil
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tvoj profil',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        if (sources.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text('Najviše energije ti oduzima',
                              style: TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in sources)
                                Pill(s, color: AppColors.bg),
                            ],
                          ),
                        ],
                        if (goals.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text('Tvoji ciljevi',
                              style: TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final g in goals)
                                Pill(g, color: AppColors.greenLight),
                            ],
                          ),
                        ],
                        if (time != null) ...[
                          const SizedBox(height: 14),
                          Text('⏱️ Vreme za sebe dnevno: $time',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plan
                  if (!widget.retake) ...[
                    const SectionTitle('Tvoj 28-dnevni plan'),
                    for (final w in challengeWeeks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.greenLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(w.emoji,
                                    style: const TextStyle(fontSize: 26)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nedelja ${w.number}',
                                        style: const TextStyle(
                                            color: AppColors.muted, fontSize: 13)),
                                    Text(w.title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                    Text(w.subtitle,
                                        style: const TextStyle(
                                            color: AppColors.muted, fontSize: 13.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Ova procena je orijentaciona i nije medicinska dijagnoza.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            BottomCta(
              child: FilledButton(
                onPressed: _finish,
                child: Text(widget.retake ? 'Sačuvaj rezultat' : 'Započni izazov'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.previous,
    required this.current,
    required this.gender,
  });

  final int previous;
  final int current;
  final Gender gender;

  @override
  Widget build(BuildContext context) {
    final diff = current - previous;
    final better = diff < 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: better ? AppColors.greenLight : AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        diff == 0
            ? 'Isto kao prošli put ($previous).'
            : better
                ? 'Prošli put: $previous → sada: $current (${diff.abs()} poena bolje) 🎉'
                : gt('Prošli put: $previous → sada: $current (+$diff). Budi blag{|a} prema sebi – oporavak nije prava linija.', gender),
        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
      ),
    );
  }
}
