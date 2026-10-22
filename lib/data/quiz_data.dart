// Pitanja kviza. Tekst može da sadrži rodne oblike u formatu {muški|ženski},
// koje razrešava funkcija gt() iz utils/sr.dart.

enum StepKind { single, multi, scale, info, name }

class QuizOption {
  const QuizOption(this.id, this.label,
      {this.emoji, this.exclusive = false, this.value = 0});

  final String id;
  final String label;
  final String? emoji;

  /// Ako je izabrana, poništava sve ostale (npr. „Ništa od navedenog“).
  final bool exclusive;

  /// Vrednost za pitanja na skali.
  final int value;
}

class QuizStep {
  const QuizStep({
    required this.id,
    required this.kind,
    required this.title,
    this.subtitle,
    this.options = const [],
    this.emoji,
  });

  final String id;
  final StepKind kind;
  final String title;

  /// Za info ekrane ovo je glavni tekst.
  final String? subtitle;
  final List<QuizOption> options;
  final String? emoji;
}

const scaleOptions = [
  QuizOption('0', 'Nikad', emoji: '😌', value: 0),
  QuizOption('1', 'Retko', emoji: '🙂', value: 1),
  QuizOption('2', 'Ponekad', emoji: '😐', value: 2),
  QuizOption('3', 'Često', emoji: '😟', value: 3),
  QuizOption('4', 'Skoro uvek', emoji: '😫', value: 4),
];

const scaleQuestion = 'Koliko često se ovo odnosi na tebe?';

const scaleIds = [
  's_tired',
  's_detach',
  's_joy',
  's_irritable',
  's_enough',
  's_focus',
];

const quizSteps = <QuizStep>[
  QuizStep(
    id: 'age',
    kind: StepKind.single,
    title: 'Koliko imaš godina?',
    subtitle: 'Prilagodićemo plan tvojoj životnoj fazi.',
    options: [
      QuizOption('18_24', '18–24'),
      QuizOption('25_34', '25–34'),
      QuizOption('35_44', '35–44'),
      QuizOption('45_54', '45–54'),
      QuizOption('55plus', '55+'),
    ],
  ),
  QuizStep(
    id: 'day_end',
    kind: StepKind.single,
    title: 'Kako se najčešće osećaš na kraju dana?',
    options: [
      QuizOption('exhausted', 'Iscrpljeno, bez trunke energije', emoji: '😩'),
      QuizOption('stressed', 'Napeto i pod stresom', emoji: '😤'),
      QuizOption('numb', 'Prazno i ravnodušno', emoji: '😶'),
      QuizOption('good', 'Uglavnom dobro', emoji: '🙂'),
    ],
  ),
  QuizStep(
    id: 's_tired',
    kind: StepKind.scale,
    title: 'Ujutru se budim umor{an|na}, čak i kada spavam dovoljno.',
  ),
  QuizStep(
    id: 's_detach',
    kind: StepKind.scale,
    title: 'Teško mi je da se isključim od obaveza, čak i u slobodno vreme.',
  ),
  QuizStep(
    id: 'info_who',
    kind: StepKind.info,
    emoji: '💡',
    title: 'Nisi jedin{i|a} u ovome',
    subtitle:
        'Svetska zdravstvena organizacija je 2019. godine uvrstila izgaranje (burnout) u Međunarodnu klasifikaciju bolesti kao fenomen povezan sa poslom.\n\nIzgaranje nastaje kada hronični stres traje predugo bez dovoljno oporavka. To nije znak slabosti, već signal da je nešto potrebno promeniti.',
  ),
  QuizStep(
    id: 's_joy',
    kind: StepKind.scale,
    title: 'Stvari koje su me nekad radovale sada mi deluju kao obaveza.',
  ),
  QuizStep(
    id: 's_irritable',
    kind: StepKind.scale,
    title: 'Lako planem ili se iznerviram zbog sitnica.',
  ),
  QuizStep(
    id: 's_enough',
    kind: StepKind.scale,
    title: 'Imam osećaj da, koliko god da se trudim, nikad nije dovoljno.',
  ),
  QuizStep(
    id: 's_focus',
    kind: StepKind.scale,
    title: 'Teško mi je da se skoncentrišem i završim ono što započnem.',
  ),
  QuizStep(
    id: 'sleep',
    kind: StepKind.single,
    title: 'Koliko sati prosečno spavaš?',
    options: [
      QuizOption('lt5', 'Manje od 5 sati', emoji: '😵'),
      QuizOption('5_6', '5–6 sati', emoji: '🥱'),
      QuizOption('7_8', '7–8 sati', emoji: '😴'),
      QuizOption('8plus', 'Više od 8 sati', emoji: '🛌'),
    ],
  ),
  QuizStep(
    id: 'stress_sources',
    kind: StepKind.multi,
    title: 'Šta ti trenutno najviše oduzima energiju?',
    subtitle: 'Izaberi sve što važi.',
    options: [
      QuizOption('work', 'Posao', emoji: '💼'),
      QuizOption('money', 'Finansije', emoji: '💸'),
      QuizOption('family', 'Porodica', emoji: '👨‍👩‍👧'),
      QuizOption('partner', 'Partnerski odnos', emoji: '❤️'),
      QuizOption('study', 'Škola ili studije', emoji: '🎓'),
      QuizOption('health', 'Zdravlje', emoji: '🩺'),
      QuizOption('uncertainty', 'Neizvesnost', emoji: '🌫️'),
      QuizOption('screens', 'Previše ekrana i informacija', emoji: '📱'),
    ],
  ),
  QuizStep(
    id: 'symptoms',
    kind: StepKind.multi,
    title: 'Da li primećuješ nešto od ovoga?',
    subtitle: 'Izaberi sve što važi.',
    options: [
      QuizOption('headache', 'Česte glavobolje', emoji: '🤕'),
      QuizOption('tension', 'Napetost u vratu i ramenima', emoji: '🫨'),
      QuizOption('sleep', 'Problemi sa snom', emoji: '🌙'),
      QuizOption('appetite', 'Promene apetita', emoji: '🍫'),
      QuizOption('procrastination', 'Odlaganje obaveza', emoji: '⏳'),
      QuizOption('emptiness', 'Osećaj praznine', emoji: '🕳️'),
      QuizOption('none', 'Ništa od navedenog', emoji: '✅', exclusive: true),
    ],
  ),
  QuizStep(
    id: 'info_small_steps',
    kind: StepKind.info,
    emoji: '🌱',
    title: 'Male promene, veliki efekat',
    subtitle:
        'Oporavak od izgaranja ne zahteva velike žrtve. Kratke, svakodnevne navike – pauze, disanje, granice i pažnja prema sebi – zajedno prave razliku.\n\nZato je izazov podeljen na 28 malih koraka, po jedan za svaki dan.',
  ),
  QuizStep(
    id: 'goals',
    kind: StepKind.multi,
    title: 'Šta želiš da postigneš za 28 dana?',
    subtitle: 'Izaberi sve što važi.',
    options: [
      QuizOption('energy', 'Više energije', emoji: '⚡'),
      QuizOption('less_stress', 'Manje stresa', emoji: '🧘'),
      QuizOption('sleep', 'Bolji san', emoji: '😴'),
      QuizOption('boundaries', 'Zdrave granice', emoji: '🛡️'),
      QuizOption('focus', 'Bolji fokus', emoji: '🎯'),
      QuizOption('self_care', 'Više brige o sebi', emoji: '💛'),
      QuizOption('joy', 'Ponovo uživati u stvarima', emoji: '😊'),
    ],
  ),
  QuizStep(
    id: 'calm',
    kind: StepKind.multi,
    title: 'Šta te obično smiruje?',
    subtitle: 'Izaberi sve što važi.',
    options: [
      QuizOption('nature', 'Šetnja i priroda', emoji: '🌳'),
      QuizOption('music', 'Muzika', emoji: '🎧'),
      QuizOption('talk', 'Razgovor sa bliskim ljudima', emoji: '💬'),
      QuizOption('sport', 'Fizička aktivnost', emoji: '🏃'),
      QuizOption('reading', 'Čitanje', emoji: '📖'),
      QuizOption('creative', 'Kreativni hobiji', emoji: '🎨'),
      QuizOption('silence', 'Tišina i samoća', emoji: '🤫'),
    ],
  ),
  QuizStep(
    id: 'time',
    kind: StepKind.single,
    title: 'Koliko vremena dnevno možeš da odvojiš za sebe?',
    options: [
      QuizOption('5', '5 minuta', emoji: '⏱️'),
      QuizOption('10', '10 minuta', emoji: '☕'),
      QuizOption('15', '15 minuta', emoji: '🧘'),
      QuizOption('20', '20 minuta ili više', emoji: '🌿'),
    ],
  ),
  QuizStep(
    id: 'name',
    kind: StepKind.name,
    title: 'Kako da te zovem?',
    subtitle: 'Mira, tvoja AI saputnica, obraćaće ti se po imenu.',
  ),
];

QuizStep? stepById(String id) {
  for (final s in quizSteps) {
    if (s.id == id) return s;
  }
  return null;
}

/// Pretvara ID-jeve odgovora u čitljive nazive (sa emodžijem).
List<String> optionLabels(String stepId, List<String> ids,
    {bool withEmoji = true}) {
  final step = stepById(stepId);
  if (step == null) return ids;
  return [
    for (final o in step.options)
      if (ids.contains(o.id))
        withEmoji && o.emoji != null ? '${o.emoji} ${o.label}' : o.label,
  ];
}

String? optionLabel(String stepId, String? id) {
  if (id == null) return null;
  final labels = optionLabels(stepId, [id], withEmoji: false);
  return labels.isEmpty ? null : labels.first;
}
