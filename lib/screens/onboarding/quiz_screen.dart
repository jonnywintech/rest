import 'package:flutter/material.dart';

import '../../data/quiz_data.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../utils/sr.dart';
import '../../widgets/common.dart';
import 'analysis_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.gender, this.retake = false});

  final Gender gender;

  /// Ponovna procena iz profila – bez pitanja o imenu.
  final bool retake;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizStep> _steps = widget.retake
      ? quizSteps.where((s) => s.kind != StepKind.name).toList()
      : quizSteps;
  late final Map<String, dynamic> _answers = {'gender': widget.gender.name};
  final _nameController = TextEditingController();
  int _index = 0;
  bool _advancing = false;

  QuizStep get _step => _steps[_index];
  String _t(String text) => gt(text, widget.gender);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index--);
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      return;
    }
    if (!widget.retake) _answers['name'] = _nameController.text.trim();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          gender: widget.gender,
          answers: Map.of(_answers),
          retake: widget.retake,
        ),
      ),
    );
  }

  Future<void> _pickAndAdvance(Object value) async {
    if (_advancing) return;
    setState(() {
      _answers[_step.id] = value;
      _advancing = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    _advancing = false;
    _next();
  }

  void _toggle(QuizOption option) {
    final current = listOf(_answers[_step.id]);
    if (current.contains(option.id)) {
      current.remove(option.id);
    } else if (option.exclusive) {
      current
        ..clear()
        ..add(option.id);
    } else {
      final exclusiveIds =
          _step.options.where((o) => o.exclusive).map((o) => o.id);
      current
        ..removeWhere(exclusiveIds.contains)
        ..add(option.id);
    }
    setState(() => _answers[_step.id] = current);
  }

  bool get _needsButton => switch (_step.kind) {
        StepKind.multi || StepKind.info || StepKind.name => true,
        _ => false,
      };

  bool get _canContinue => switch (_step.kind) {
        StepKind.multi => listOf(_answers[_step.id]).isNotEmpty,
        StepKind.name => _nameController.text.trim().isNotEmpty,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _steps.length;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(child: Center(child: Logo(size: 30))),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${_index + 1}/${_steps.length}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      color: AppColors.green,
                      backgroundColor: AppColors.line,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step.id),
                    child: _buildStep(),
                  ),
                ),
              ),
              if (_needsButton)
                BottomCta(
                  child: FilledButton(
                    onPressed: _canContinue ? _next : null,
                    child: Text(_index == _steps.length - 1
                        ? 'Pogledaj rezultat'
                        : 'Nastavi'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step.kind) {
      StepKind.single => _choiceList(multi: false),
      StepKind.multi => _choiceList(multi: true),
      StepKind.scale => _scale(),
      StepKind.info => _info(),
      StepKind.name => _name(),
    };
  }

  Widget _header(String title, [String? subtitle]) {
    return Column(
      children: [
        Text(
          _t(title),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            _t(subtitle),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  Widget _choiceList({required bool multi}) {
    final selected = multi ? listOf(_answers[_step.id]) : [_answers[_step.id]];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      children: [
        _header(_step.title, _step.subtitle),
        const SizedBox(height: 28),
        for (final o in _step.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OptionTile(
              label: _t(o.label),
              emoji: o.emoji,
              multi: multi,
              selected: selected.contains(o.id),
              onTap: () => multi ? _toggle(o) : _pickAndAdvance(o.id),
            ),
          ),
      ],
    );
  }

  Widget _scale() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('“',
                  style: TextStyle(
                      fontSize: 56, height: 1, color: AppColors.green)),
              Text(
                _t(_step.title),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          scaleQuestion,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        for (final o in scaleOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OptionTile(
              label: o.label,
              emoji: o.emoji,
              selected: _answers[_step.id] == o.value,
              onTap: () => _pickAndAdvance(o.value),
            ),
          ),
      ],
    );
  }

  Widget _info() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: Text(_step.emoji ?? '💡', style: const TextStyle(fontSize: 52)),
          ),
        ),
        const SizedBox(height: 28),
        _header(_step.title),
        const SizedBox(height: 16),
        Text(
          _t(_step.subtitle ?? ''),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, height: 1.55),
        ),
      ],
    );
  }

  Widget _name() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      children: [
        const Center(child: MiraAvatar(size: 72)),
        const SizedBox(height: 24),
        _header(_step.title, _step.subtitle),
        const SizedBox(height: 28),
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: 'Tvoje ime'),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_canContinue) _next();
          },
        ),
      ],
    );
  }
}
