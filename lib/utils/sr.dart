import '../models/models.dart';

const _monthsGenitive = [
  'januara', 'februara', 'marta', 'aprila', 'maja', 'juna',
  'jula', 'avgusta', 'septembra', 'oktobra', 'novembra', 'decembra',
];
const _months = [
  'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Jun',
  'Jul', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar',
];
const _weekdays = [
  'Ponedeljak', 'Utorak', 'Sreda', 'Četvrtak', 'Petak', 'Subota', 'Nedelja',
];
const weekdayShort = ['P', 'U', 'S', 'Č', 'P', 'S', 'N'];

String two(int n) => n.toString().padLeft(2, '0');

/// „Sreda, 22. oktobra“
String formatLongDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day}. ${_monthsGenitive[d.month - 1]}';

/// „22. oktobra 2026.“
String formatDate(DateTime d) =>
    '${d.day}. ${_monthsGenitive[d.month - 1]} ${d.year}.';

/// „22. oktobra“
String formatShortDate(DateTime d) =>
    '${d.day}. ${_monthsGenitive[d.month - 1]}';

String formatTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

/// „Oktobar 2026.“
String monthTitle(DateTime d) => '${_months[d.month - 1]} ${d.year}.';

/// „Danas“, „Juče“ ili datum.
String relativeDay(DateTime d) {
  final today = dateOnly(DateTime.now());
  final day = dateOnly(d);
  if (day == today) return 'Danas';
  if (day == DateTime(today.year, today.month, today.day - 1)) return 'Juče';
  return formatShortDate(d);
}

String greeting(DateTime now) {
  final h = now.hour;
  if (h < 5) return 'Laku noć';
  if (h < 12) return 'Dobro jutro';
  if (h < 18) return 'Dobar dan';
  return 'Dobro veče';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Srpska množina: 1 dan, 2 dana, 5 dana, 21 dan...
String plural(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}

final _genderPattern = RegExp(r'\{([^|{}]*)\|([^|{}]*)\}');

/// Rodno prilagođen tekst: „umor{an|na}“ → „umoran“ / „umorna“.
String gt(String text, Gender gender) => text.replaceAllMapped(
      _genderPattern,
      (m) => gender == Gender.male ? m[1]! : m[2]!,
    );
