import 'dart:math';

import 'package:flutter/material.dart';

import '../data/quiz_data.dart';
import '../models/models.dart';

class BurnoutLevel {
  const BurnoutLevel(this.label, this.color, this.description);

  final String label;
  final Color color;
  final String description;
}

const _low = BurnoutLevel(
  'Nizak',
  Color(0xFF4CAF50),
  'Uglavnom se dobro nosiš sa obavezama. Izazov će ti pomoći da sačuvaš energiju i izgradiš navike koje te štite od izgaranja.',
);
const _moderate = BurnoutLevel(
  'Umeren',
  Color(0xFFE0A800),
  'Primećuju se prvi znaci iscrpljenosti. Ovo je pravi trenutak da uvedeš male promene, pre nego što se stres nagomila.',
);
const _high = BurnoutLevel(
  'Visok',
  Color(0xFFF2994A),
  'Tvoje telo i um šalju jasne signale da im treba predah. 28 dana malih koraka pomoći će ti da povratiš energiju i postaviš granice.',
);
const _veryHigh = BurnoutLevel(
  'Vrlo visok',
  Color(0xFFE5533D),
  'Tvoji odgovori ukazuju na izraženu iscrpljenost. Izazov može da pomogne, ali ti preporučujemo i razgovor sa lekarom ili psihologom – zaslužuješ podršku.',
);

const burnoutLevels = [_low, _moderate, _high, _veryHigh];

BurnoutLevel levelFor(int score) {
  if (score < 30) return _low;
  if (score < 55) return _moderate;
  if (score < 75) return _high;
  return _veryHigh;
}

const _sleepLoad = {'lt5': 4, '5_6': 3, '7_8': 0, '8plus': 1};
const _dayEndLoad = {'exhausted': 4, 'stressed': 3, 'numb': 3, 'good': 0};

/// Računa procenu iz odgovora kviza. Rezultat je 0–100, gde više znači
/// izraženije izgaranje. Ovo je orijentaciona procena, ne dijagnoza.
Assessment computeAssessment(Map<String, dynamic> answers, {DateTime? now}) {
  int scale(String id) => ((answers[id] as num?) ?? 0).toInt().clamp(0, 4);

  final sleep = _sleepLoad[answers['sleep']] ?? 0;
  final dayEnd = _dayEndLoad[answers['day_end']] ?? 0;
  final symptoms =
      listOf(answers['symptoms']).where((s) => s != 'none').length;
  final scaleSum = scaleIds.fold<int>(0, (sum, id) => sum + scale(id));

  final score = 100 *
      (0.6 * scaleSum / 24 +
          0.1 * sleep / 4 +
          0.1 * dayEnd / 4 +
          0.2 * min(symptoms, 5) / 5);

  final exhaustion =
      100 * (0.7 * (scale('s_tired') + scale('s_focus')) / 8 + 0.3 * sleep / 4);
  final stress = 100 *
      (0.7 * (scale('s_detach') + scale('s_irritable')) / 8 + 0.3 * dayEnd / 4);
  final motivation = 100 * (scale('s_joy') + scale('s_enough')) / 8;

  return Assessment(
    date: now ?? DateTime.now(),
    score: score.round(),
    exhaustion: exhaustion.round(),
    stress: stress.round(),
    motivation: motivation.round(),
  );
}
