enum Gender { male, female }

Gender genderFromName(String? name) =>
    name == Gender.female.name ? Gender.female : Gender.male;

/// Bezbedno pretvara JSON vrednost (`List<dynamic>`) u listu stringova.
List<String> listOf(dynamic value) =>
    value is List ? value.map((e) => e.toString()).toList() : <String>[];

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

class Assessment {
  const Assessment({
    required this.date,
    required this.score,
    required this.exhaustion,
    required this.stress,
    required this.motivation,
  });

  final DateTime date;

  /// Ukupan rezultat 0–100 (više = izraženije izgaranje).
  final int score;
  final int exhaustion;
  final int stress;
  final int motivation;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'exhaustion': exhaustion,
        'stress': stress,
        'motivation': motivation,
      };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        date: DateTime.parse(json['date'] as String),
        score: json['score'] as int,
        exhaustion: json['exhaustion'] as int,
        stress: json['stress'] as int,
        motivation: json['motivation'] as int,
      );
}

class Profile {
  const Profile({
    this.onboarded = false,
    this.name = '',
    this.gender = Gender.male,
    this.answers = const {},
    this.startedAt,
    this.assessments = const [],
  });

  final bool onboarded;
  final String name;
  final Gender gender;
  final Map<String, dynamic> answers;
  final DateTime? startedAt;
  final List<Assessment> assessments;

  Assessment? get latest => assessments.isEmpty ? null : assessments.last;
  Assessment? get first => assessments.isEmpty ? null : assessments.first;

  Profile copyWith({
    bool? onboarded,
    String? name,
    Gender? gender,
    Map<String, dynamic>? answers,
    DateTime? startedAt,
    List<Assessment>? assessments,
  }) =>
      Profile(
        onboarded: onboarded ?? this.onboarded,
        name: name ?? this.name,
        gender: gender ?? this.gender,
        answers: answers ?? this.answers,
        startedAt: startedAt ?? this.startedAt,
        assessments: assessments ?? this.assessments,
      );

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'name': name,
        'gender': gender.name,
        'answers': answers,
        'startedAt': startedAt?.toIso8601String(),
        'assessments': assessments.map((a) => a.toJson()).toList(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        onboarded: json['onboarded'] as bool? ?? false,
        name: json['name'] as String? ?? '',
        gender: genderFromName(json['gender'] as String?),
        answers: Map<String, dynamic>.from(json['answers'] as Map? ?? {}),
        startedAt: json['startedAt'] == null
            ? null
            : DateTime.parse(json['startedAt'] as String),
        assessments: (json['assessments'] as List? ?? [])
            .map((e) => Assessment.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class AppSettings {
  const AppSettings({
    this.apiKey = '',
    this.model = defaultModel,
    this.unlockAll = false,
  });

  static const defaultModel =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-3.8-flash');
  static const envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  final String apiKey;
  final String model;
  final bool unlockAll;

  /// Ključ iz podešavanja ima prednost; inače se koristi --dart-define.
  String get effectiveKey => apiKey.isNotEmpty ? apiKey : envApiKey;
  bool get hasKey => effectiveKey.isNotEmpty;

  AppSettings copyWith({String? apiKey, String? model, bool? unlockAll}) =>
      AppSettings(
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        unlockAll: unlockAll ?? this.unlockAll,
      );

  Map<String, dynamic> toJson() =>
      {'apiKey': apiKey, 'model': model, 'unlockAll': unlockAll};

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? defaultModel,
        unlockAll: json['unlockAll'] as bool? ?? false,
      );
}

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.emotions = const [],
    this.triggers = const [],
    this.note = '',
  });

  final String id;
  final DateTime date;

  /// 1 (užasno) – 5 (odlično)
  final int mood;
  final List<String> emotions;
  final List<String> triggers;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood,
        'emotions': emotions,
        'triggers': triggers,
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as int,
        emotions: listOf(json['emotions']),
        triggers: listOf(json['triggers']),
        note: json['note'] as String? ?? '',
      );
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    this.prompt,
  });

  final String id;
  final DateTime date;
  final String text;
  final String? prompt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        'prompt': prompt,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        text: json['text'] as String? ?? '',
        prompt: json['prompt'] as String?,
      );
}

class ChatMessage {
  const ChatMessage({required this.role, required this.text, required this.date});

  /// 'user' ili 'model' (kao u Gemini API-ju)
  final String role;
  final String text;
  final DateTime date;

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() =>
      {'role': role, 'text': text, 'date': date.toIso8601String()};

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
