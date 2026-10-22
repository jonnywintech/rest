import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/challenge_data.dart';
import '../models/models.dart';
import '../services/ai_context.dart';
import '../services/gemini_service.dart';
import '../utils/sr.dart';

// ───────────────────────── Skladište ─────────────────────────

/// Postavlja se u main.dart preko overrideWithValue.
final prefsProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('prefsProvider mora biti postavljen u main()'),
);

class StoreKeys {
  static const profile = 'profile';
  static const settings = 'settings';
  static const challenge = 'challenge';
  static const moods = 'moods';
  static const journal = 'journal';
  static const chat = 'chat';
  static const lessons = 'lessons';

  /// Sve osim podešavanja (API ključ ostaje i posle brisanja podataka).
  static const userData = [profile, challenge, moods, journal, chat, lessons];
}

/// Prefiks ključeva aktivne sesije: '' za pravi profil, `decoy_` za prazan profil.
String _k(Ref ref, String key, {bool watch = true}) {
  final ns = watch ? ref.watch(sessionProvider) : ref.read(sessionProvider);
  return '${ns?.prefix ?? ''}$key';
}

T? _readJson<T>(SharedPreferences prefs, String key) {
  final raw = prefs.getString(key);
  if (raw == null) return null;
  try {
    return jsonDecode(raw) as T;
  } catch (_) {
    return null;
  }
}

void _writeJson(SharedPreferences prefs, String key, Object value) {
  prefs.setString(key, jsonEncode(value));
}

// ───────────────────────── Zaključavanje ─────────────────────────

enum Session {
  real(''),
  decoy('decoy_');

  const Session(this.prefix);
  final String prefix;
}

const _passcodeKey = 'passcode_hash';
const _passcodeSalt = 'predah.v1.';

String _hashPasscode(String code) =>
    sha256.convert(utf8.encode('$_passcodeSalt$code')).toString();

/// `null` dok je aplikacija zaključana.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  SharedPreferences get _prefs => ref.read(prefsProvider);

  bool get hasPasscode => _prefs.containsKey(_passcodeKey);

  /// Prvo postavljanje šifre; postojeći podaci ostaju u pravom profilu.
  void setPasscode(String code) {
    _prefs.setString(_passcodeKey, _hashPasscode(code));
    state = Session.real;
  }

  /// Tačna šifra otvara pravi profil, svaka druga prazan (lažni) profil.
  Future<void> unlock(String code) async {
    if (_prefs.getString(_passcodeKey) == _hashPasscode(code)) {
      state = Session.real;
      return;
    }
    // Lažni profil uvek počinje prazan.
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(Session.decoy.prefix)) await _prefs.remove(key);
    }
    state = Session.decoy;
  }

  void lock() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

// ───────────────────────── Navigacija ─────────────────────────

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);

// ───────────────────────── Profil ─────────────────────────

class ProfileNotifier extends Notifier<Profile> {
  SharedPreferences get _prefs => ref.read(prefsProvider);

  @override
  Profile build() {
    final json = _readJson<Map<String, dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.profile),
    );
    return json == null ? const Profile() : Profile.fromJson(json);
  }

  void _save(Profile p) {
    state = p;
    _writeJson(_prefs, _k(ref, StoreKeys.profile, watch: false), p.toJson());
  }

  void completeOnboarding({
    required String name,
    required Gender gender,
    required Map<String, dynamic> answers,
    required Assessment assessment,
  }) {
    _save(
      Profile(
        onboarded: true,
        name: name,
        gender: gender,
        answers: answers,
        startedAt: DateTime.now(),
        assessments: [assessment],
      ),
    );
  }

  void addAssessment(Assessment assessment, Map<String, dynamic> answers) {
    _save(
      state.copyWith(
        answers: {...answers, 'name': state.name},
        assessments: [...state.assessments, assessment],
      ),
    );
  }

  void rename(String name) => _save(state.copyWith(name: name));
}

final profileProvider = NotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);

final genderProvider = Provider<Gender>(
  (ref) => ref.watch(profileProvider.select((p) => p.gender)),
);

// ───────────────────────── Podešavanja ─────────────────────────

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final json = _readJson<Map<String, dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.settings),
    );
    return json == null ? const AppSettings() : AppSettings.fromJson(json);
  }

  void update(AppSettings settings) {
    state = settings;
    _writeJson(
      ref.read(prefsProvider),
      _k(ref, StoreKeys.settings, watch: false),
      settings.toJson(),
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ───────────────────────── 28-dnevni izazov ─────────────────────────

class ChallengeState {
  const ChallengeState({
    this.completed = const {},
    this.reflections = const {},
  });

  /// Dan → vreme završetka
  final Map<int, DateTime> completed;

  /// Dan → odgovor na pitanje za razmišljanje
  final Map<int, String> reflections;

  int get completedCount => completed.length;
  bool isDone(int day) => completed.containsKey(day);

  /// Prvi nezavršeni dan (29 kada je izazov završen).
  int get currentDay {
    for (var d = 1; d <= challengeLength; d++) {
      if (!isDone(d)) return d;
    }
    return challengeLength + 1;
  }

  /// Dan se otključava dan posle završetka prethodnog (ili odmah, uz opciju).
  bool isUnlocked(int day, {required bool unlockAll, DateTime? now}) {
    if (day == 1 || isDone(day)) return true;
    final previous = completed[day - 1];
    if (previous == null) return false;
    if (unlockAll) return true;
    return dateOnly(previous).isBefore(dateOnly(now ?? DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
    'completed': completed.map(
      (k, v) => MapEntry(k.toString(), v.toIso8601String()),
    ),
    'reflections': reflections.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory ChallengeState.fromJson(Map<String, dynamic> json) => ChallengeState(
    completed: (json['completed'] as Map? ?? {}).map(
      (k, v) => MapEntry(int.parse(k as String), DateTime.parse(v as String)),
    ),
    reflections: (json['reflections'] as Map? ?? {}).map(
      (k, v) => MapEntry(int.parse(k as String), v as String),
    ),
  );
}

class ChallengeNotifier extends Notifier<ChallengeState> {
  @override
  ChallengeState build() {
    final json = _readJson<Map<String, dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.challenge),
    );
    return json == null
        ? const ChallengeState()
        : ChallengeState.fromJson(json);
  }

  void _save(ChallengeState s) {
    state = s;
    _writeJson(
      ref.read(prefsProvider),
      _k(ref, StoreKeys.challenge, watch: false),
      s.toJson(),
    );
  }

  void complete(int day, String reflection) => _save(
    ChallengeState(
      completed: {
        ...state.completed,
        day: state.completed[day] ?? DateTime.now(),
      },
      reflections: {...state.reflections, day: reflection},
    ),
  );

  void saveReflection(int day, String reflection) => _save(
    ChallengeState(
      completed: state.completed,
      reflections: {...state.reflections, day: reflection},
    ),
  );
}

final challengeProvider = NotifierProvider<ChallengeNotifier, ChallengeState>(
  ChallengeNotifier.new,
);

// ───────────────────────── Raspoloženje ─────────────────────────

class MoodNotifier extends Notifier<List<MoodEntry>> {
  @override
  List<MoodEntry> build() {
    final json = _readJson<List<dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.moods),
    );
    final list =
        (json ?? [])
            .map((e) => MoodEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _save(List<MoodEntry> list) {
    state = list;
    _writeJson(
      ref.read(prefsProvider),
      _k(ref, StoreKeys.moods, watch: false),
      list.map((e) => e.toJson()).toList(),
    );
  }

  void add(MoodEntry entry) =>
      _save([entry, ...state]..sort((a, b) => b.date.compareTo(a.date)));

  void delete(String id) => _save(state.where((e) => e.id != id).toList());
}

final moodProvider = NotifierProvider<MoodNotifier, List<MoodEntry>>(
  MoodNotifier.new,
);

// ───────────────────────── Dnevnik ─────────────────────────

class JournalNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() {
    final json = _readJson<List<dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.journal),
    );
    return (json ?? [])
        .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _save(List<JournalEntry> list) {
    state = list;
    _writeJson(
      ref.read(prefsProvider),
      _k(ref, StoreKeys.journal, watch: false),
      list.map((e) => e.toJson()).toList(),
    );
  }

  /// Dodaje novu ili menja postojeću belešku (isti id).
  void upsert(JournalEntry entry) => _save(
    [entry, ...state.where((e) => e.id != entry.id)]
      ..sort((a, b) => b.date.compareTo(a.date)),
  );

  void delete(String id) => _save(state.where((e) => e.id != id).toList());
}

final journalProvider = NotifierProvider<JournalNotifier, List<JournalEntry>>(
  JournalNotifier.new,
);

// ───────────────────────── Kursevi ─────────────────────────

class LessonsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref
          .watch(prefsProvider)
          .getStringList(_k(ref, StoreKeys.lessons))
          ?.toSet() ??
      {};

  void complete(String lessonId) {
    state = {...state, lessonId};
    ref
        .read(prefsProvider)
        .setStringList(
          _k(ref, StoreKeys.lessons, watch: false),
          state.toList(),
        );
  }
}

final lessonsProvider = NotifierProvider<LessonsNotifier, Set<String>>(
  LessonsNotifier.new,
);

// ───────────────────────── Mira (AI chat) ─────────────────────────

class ChatState {
  const ChatState({this.messages = const [], this.sending = false, this.error});

  final List<ChatMessage> messages;
  final bool sending;
  final String? error;
}

class ChatNotifier extends Notifier<ChatState> {
  static const _historyLimit = 30;

  @override
  ChatState build() {
    final json = _readJson<List<dynamic>>(
      ref.watch(prefsProvider),
      _k(ref, StoreKeys.chat),
    );
    return ChatState(
      messages: (json ?? [])
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  void _persist() {
    _writeJson(
      ref.read(prefsProvider),
      _k(ref, StoreKeys.chat, watch: false),
      state.messages.map((m) => m.toJson()).toList(),
    );
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    state = ChatState(
      messages: [
        ...state.messages,
        ChatMessage(role: 'user', text: trimmed, date: DateTime.now()),
      ],
    );
    _persist();
    await _respond();
  }

  Future<void> retry() => _respond();

  Future<void> _respond() async {
    final settings = ref.read(settingsProvider);
    if (!settings.hasKey) {
      state = ChatState(
        messages: state.messages,
        error: 'Dodaj Gemini API ključ u Profil → Mira (AI).',
      );
      return;
    }
    state = ChatState(messages: state.messages, sending: true);

    try {
      final profile = ref.read(profileProvider);
      final challenge = ref.read(challengeProvider);
      final context = buildUserContext(
        profile: profile,
        moods: ref.read(moodProvider),
        completedDays: challenge.completedCount,
        currentDay: challenge.currentDay,
      );
      final history = state.messages.length > _historyLimit
          ? state.messages.sublist(state.messages.length - _historyLimit)
          : state.messages;

      final reply =
          await GeminiService(
            apiKey: settings.effectiveKey,
            model: settings.model,
          ).generate(
            systemPrompt: miraSystemPrompt(context, profile.gender),
            turns: [for (final m in history) ChatTurn(m.role, m.text)],
          );

      state = ChatState(
        messages: [
          ...state.messages,
          ChatMessage(role: 'model', text: reply, date: DateTime.now()),
        ],
      );
      _persist();
    } on GeminiException catch (e) {
      state = ChatState(messages: state.messages, error: e.message);
    } catch (e) {
      state = ChatState(messages: state.messages, error: 'Greška: $e');
    }
  }

  void clear() {
    state = const ChatState();
    _persist();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

// ───────────────────────── Statistika ─────────────────────────

/// Broj uzastopnih dana sa bilo kakvom aktivnošću (dan izazova,
/// raspoloženje ili beleška). Računa se do danas ili do juče.
final streakProvider = Provider<int>((ref) {
  final dates = <DateTime>{
    for (final d in ref.watch(challengeProvider).completed.values) dateOnly(d),
    for (final m in ref.watch(moodProvider)) dateOnly(m.date),
    for (final j in ref.watch(journalProvider)) dateOnly(j.date),
  };
  var day = dateOnly(DateTime.now());
  if (!dates.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
  var streak = 0;
  while (dates.contains(day)) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
});

/// Briše sve korisničke podatke (podešavanja i API ključ ostaju).
Future<void> resetAllData(WidgetRef ref) async {
  final prefs = ref.read(prefsProvider);
  final prefix = ref.read(sessionProvider)?.prefix ?? '';
  for (final key in StoreKeys.userData) {
    await prefs.remove('$prefix$key');
  }
  ref.invalidate(profileProvider);
  ref.invalidate(challengeProvider);
  ref.invalidate(moodProvider);
  ref.invalidate(journalProvider);
  ref.invalidate(lessonsProvider);
  ref.invalidate(chatProvider);
  ref.read(tabIndexProvider.notifier).select(0);
}
