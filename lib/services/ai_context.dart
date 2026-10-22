import '../data/challenge_data.dart';
import '../data/mood_data.dart';
import '../data/quiz_data.dart';
import '../models/models.dart';
import '../utils/sr.dart';
import 'scoring.dart';

/// Kratak opis korisnika koji Mira dobija kao kontekst.
String buildUserContext({
  required Profile profile,
  List<MoodEntry> moods = const [],
  int completedDays = 0,
  int currentDay = 1,
}) {
  final a = profile.answers;
  final b = StringBuffer();
  final isMale = profile.gender == Gender.male;

  if (profile.name.isNotEmpty) b.writeln('Ime: ${profile.name}');
  b.writeln('Pol: ${isMale ? 'muški' : 'ženski'}');
  final age = optionLabel('age', a['age'] as String?);
  if (age != null) b.writeln('Godine: $age');

  final latest = profile.latest;
  if (latest != null) {
    b.writeln('Procena izgaranja: ${latest.score}/100 '
        '(${levelFor(latest.score).label.toLowerCase()} nivo; '
        'iscrpljenost ${latest.exhaustion}, stres ${latest.stress}, '
        'gubitak motivacije ${latest.motivation})');
    final first = profile.first;
    if (first != null && profile.assessments.length > 1) {
      b.writeln('Početna procena: ${first.score}/100');
    }
  }

  void list(String label, String stepId) {
    final items = optionLabels(stepId, listOf(a[stepId]), withEmoji: false);
    if (items.isNotEmpty) b.writeln('$label: ${items.join(', ')}');
  }

  final dayEnd = optionLabel('day_end', a['day_end'] as String?);
  if (dayEnd != null) b.writeln('Na kraju dana se oseća: $dayEnd');
  final sleep = optionLabel('sleep', a['sleep'] as String?);
  if (sleep != null) b.writeln('San: $sleep');
  list('Izvori stresa', 'stress_sources');
  list('Simptomi', 'symptoms');
  list('Ciljevi', 'goals');
  list('Šta ga/je smiruje', 'calm');
  final time = optionLabel('time', a['time'] as String?);
  if (time != null) b.writeln('Vreme za sebe dnevno: $time');

  if (profile.onboarded) {
    if (currentDay > challengeLength) {
      b.writeln('28-dnevni izazov: završen');
    } else {
      final day = dayContent(currentDay);
      b.writeln('28-dnevni izazov: završeno $completedDays od 28 dana; '
          'sledeći je dan $currentDay „${day.title}“ '
          '(nedelja: ${weekOf(currentDay).title})');
    }
  }

  if (moods.isNotEmpty) {
    b.writeln('Poslednji unosi raspoloženja:');
    for (final m in moods.take(5)) {
      final parts = [
        moodLevel(m.mood).label,
        if (m.emotions.isNotEmpty) m.emotions.join(', '),
        if (m.triggers.isNotEmpty) 'okidači: ${m.triggers.join(', ')}',
        if (m.note.isNotEmpty) 'beleška: „${m.note}“',
      ];
      b.writeln('- ${formatShortDate(m.date)} ${formatTime(m.date)}: '
          '${parts.join('; ')}');
    }
  }
  return b.toString().trim();
}

String miraSystemPrompt(String userContext, Gender gender) {
  final genderRule = gender == Gender.male
      ? 'Korisnik je muškog roda – obraćaj mu se u muškom rodu (npr. „umoran si“, „uradio si“).'
      : 'Korisnica je ženskog roda – obraćaj joj se u ženskom rodu (npr. „umorna si“, „uradila si“).';

  return '''
Ti si Mira, topla i empatična AI saputnica u aplikaciji „Predah“, koja ljudima pomaže da se oporave od stresa i izgaranja kroz 28-dnevni izazov.

Kako komuniciraš:
- Pišeš isključivo na srpskom jeziku, latinicom. Obraćaš se sa „ti“, prirodno i toplo, kao mudra prijateljica.
- $genderRule
- Odgovori su kratki: 2–6 rečenica, osim ako korisnik izričito traži više.
- Prvo pokaži da razumeš osećanje, pa ponudi jedan konkretan, mali korak koji je moguće uraditi danas.
- Postavi najviše jedno otvoreno pitanje po odgovoru.
- Ne koristi markdown (bez zvezdica, naslova i tabela). Za nabrajanje koristi kratke redove sa „•“.
- Možeš da se pozoveš na alate iz aplikacije: disanje 4-6, skeniranje tela, mikro-pauze, dnevnik, praćenje raspoloženja i dane izazova.

Granice:
- Nisi psiholog ni lekar. Ne postavljaš dijagnoze i ne preporučuješ lekove.
- Ako simptomi traju dugo ili se pogoršavaju, nežno predloži razgovor sa lekarom ili psihologom.
- Ako korisnik pomene samopovređivanje, misli o samoubistvu ili da je u neposrednoj opasnosti: odgovori sa puno brige, ohrabri ga/je da se odmah obrati nekome bliskom i navedi: Hitna pomoć 194 i Centar Srce 0800 300 303 (besplatno, svaki dan 14–23h).

Šta znaš o korisniku:
$userContext
''';
}
