import 'package:flutter/material.dart';

class MoodLevel {
  const MoodLevel(this.value, this.emoji, this.label, this.color);

  final int value;
  final String emoji;
  final String label;
  final Color color;
}

const moodLevels = [
  MoodLevel(1, '😣', 'Užasno', Color(0xFFE5533D)),
  MoodLevel(2, '😔', 'Loše', Color(0xFFF2994A)),
  MoodLevel(3, '😐', 'Okej', Color(0xFFF2C94C)),
  MoodLevel(4, '🙂', 'Dobro', Color(0xFF8BC34A)),
  MoodLevel(5, '😄', 'Odlično', Color(0xFF4CAF50)),
];

MoodLevel moodLevel(num value) => moodLevels[value.round().clamp(1, 5) - 1];

const positiveEmotions = [
  'Radost', 'Mir', 'Zahvalnost', 'Ponos', 'Nada',
  'Uzbuđenje', 'Ljubav', 'Opuštenost', 'Motivacija',
];

const negativeEmotions = [
  'Umor', 'Stres', 'Anksioznost', 'Tuga', 'Bes', 'Frustracija',
  'Usamljenost', 'Krivica', 'Preplavljenost', 'Praznina', 'Dosada',
];

const moodTriggers = [
  '💼 Posao', '👨‍👩‍👧 Porodica', '❤️ Partner', '👥 Prijatelji', '😴 San',
  '🩺 Zdravlje', '💸 Novac', '🍽️ Hrana', '🏃 Aktivnost', '📱 Telefon',
  '🌦️ Vreme', '🏠 Kuća', '🎓 Učenje',
];

/// Pitanja za dnevnik. Rodni oblici: {muški|ženski}.
const journalPrompts = [
  'Šta mi je danas dalo energiju, a šta mi ju je oduzelo?',
  'Za šta sam danas zahval{an|na}?',
  'Koja misao mi se danas najčešće vraćala?',
  'Šta bih reka{o|la} prijatelju koji se oseća kao ja sada?',
  'Kada sam se danas oseti{o|la} najmirnije?',
  'Šta mogu sutra da uradim malo drugačije?',
  'Šta me trenutno najviše brine i šta od toga mogu da kontrolišem?',
  'Na šta sam danas ponos{an|na}, makar i malo?',
  'Kome bih vole{o|la} da se javim i zašto?',
  'Šta mi je potrebno ove nedelje da bih se oseća{o|la} bolje?',
  'Gde sam danas reka{o|la} „da“, a hte{o|la} sam „ne“?',
  'Opiši jedan lep trenutak iz današnjeg dana.',
  'Šta bi mi sada najviše prijalo?',
  'Koja stvar mi oduzima previše vremena, a ne donosi mi ništa?',
  'Kako izgleda moj idealan odmoran dan?',
  'Šta sam danas nauči{o|la} o sebi?',
  'Koje osećanje danas najviše nosim i gde ga osećam u telu?',
  'Čega mogu danas da se oslobodim?',
];

String promptOfTheDay(DateTime now) {
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return journalPrompts[dayOfYear % journalPrompts.length];
}
