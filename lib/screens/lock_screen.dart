import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';

/// Šifra pri pokretanju. Pri prvom pokretanju korisnik je postavlja,
/// kasnije je unosi. Pogrešna šifra otvara prazan profil.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  static const _minLength = 4;

  final _controller = TextEditingController();
  late final bool _setup;
  String? _first;
  String? _error;
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _setup = !ref.read(sessionProvider.notifier).hasPasscode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text;
    final notifier = ref.read(sessionProvider.notifier);
    if (code.length < _minLength) {
      setState(() => _error = 'Šifra mora imati bar $_minLength karaktera.');
      return;
    }
    if (!_setup) {
      await notifier.unlock(code);
      return;
    }
    if (_first == null) {
      setState(() {
        _first = code;
        _error = null;
        _controller.clear();
      });
    } else if (_first == code) {
      notifier.setPasscode(code);
    } else {
      setState(() {
        _first = null;
        _error = 'Šifre se ne poklapaju. Pokušaj ponovo.';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = !_setup
        ? 'Unesi šifru'
        : _first == null
            ? 'Postavi šifru'
            : 'Potvrdi šifru';
    final subtitle = _setup
        ? 'Štiti tvoj profil pri svakom pokretanju aplikacije.'
        : 'Dobrodošao nazad.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: AppColors.green),
                const SizedBox(height: 20),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 28),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: _hidden,
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(32)],
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Šifra',
                    errorText: _error,
                    suffixIcon: IconButton(
                      icon: Icon(_hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submit,
                  child: Text(_setup && _first == null ? 'Dalje' : 'Otključaj'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
