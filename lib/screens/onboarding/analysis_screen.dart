import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/scoring.dart';
import '../../theme.dart';
import '../../utils/sr.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.gender,
    required this.answers,
    this.retake = false,
  });

  final Gender gender;
  final Map<String, dynamic> answers;
  final bool retake;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    'Analiziramo nivo energije',
    'Procenjujemo izvore stresa',
    'Prilagođavamo plan tvojim ciljevima',
    'Pripremamo tvoj 28-dnevni izazov',
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )
      ..addStatusListener(_onStatus)
      ..forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => ResultScreen(
          gender: widget.gender,
          answers: widget.answers,
          assessment: computeAssessment(widget.answers),
          retake: widget.retake,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = Curves.easeInOut.transform(_controller.value);
              final percent = (value * 100).round();
              final active = (value * _steps.length).floor();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Logo(size: 30),
                    const Spacer(),
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                            color: AppColors.green,
                            backgroundColor: AppColors.line,
                          ),
                          Center(
                            child: Text(
                              '$percent%',
                              style: const TextStyle(
                                  fontSize: 44, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      gt('Pravimo tvoj lični plan…', widget.gender),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 28),
                    for (var i = 0; i < _steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: i < active
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: AppColors.green, size: 28)
                                  : i == active
                                      ? const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: AppColors.blue),
                                        )
                                      : const Icon(Icons.circle_outlined,
                                          color: AppColors.line, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _steps[i],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: i <= active
                                      ? AppColors.ink
                                      : AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    const AppCard(
                      color: AppColors.blueLight,
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Text('🌬️', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Dok čekaš: udahni na nos brojeći do 4, pa polako izdahni brojeći do 6.',
                              style: TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
