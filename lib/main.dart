import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'screens/lock_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/landing_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const PredahApp(),
    ),
  );
}

class PredahApp extends StatelessWidget {
  const PredahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predah',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Na webu/tabletu aplikacija ostaje u „telefonskoj“ širini.
      builder: (context, child) => ColoredBox(
        color: AppColors.bg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
      home: const RootGate(),
    );
  }
}

/// Prikazuje kviz dok korisnik ne završi onboarding, a zatim glavnu aplikaciju.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session == null) return const LockScreen();
    final onboarded = ref.watch(profileProvider.select((p) => p.onboarded));
    return onboarded ? const MainShell() : const LandingScreen();
  }
}
