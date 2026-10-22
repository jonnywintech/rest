import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/scoring.dart';
import '../theme.dart';

/// Logo „predah“ u zelenom rukopisnom stilu.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF7ACB4C), Color(0xFF3E9B2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      // Padding drži i rep slova „p“ unutar maske, pa je ceo logo zelen.
      child: Padding(
        padding: EdgeInsets.only(bottom: size * 0.25),
        child: Text(
          'predah',
          style: GoogleFonts.pacifico(
              fontSize: size, height: 1.3, color: AppColors.green),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    this.gradient,
    this.onTap,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Opcija u kvizu (jedan ili više izbora).
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.multi = false,
  });

  final String label;
  final String? emoji;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.greenLight : Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: selected ? AppColors.green : Colors.transparent,
          width: 2,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                if (multi)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: selected ? AppColors.green : AppColors.line,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  )
                else
                  Icon(
                    selected ? Icons.check_circle : Icons.chevron_right_rounded,
                    color: selected ? AppColors.green : AppColors.blue,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dugme pričvršćeno za dno ekrana.
class BottomCta extends StatelessWidget {
  const BottomCta({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: child,
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = Colors.white, this.textColor});

  final String text;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.ink,
        ),
      ),
    );
  }
}

/// Horizontalna traka 0–100 sa bojom prema nivou.
class IndicatorBar extends StatelessWidget {
  const IndicatorBar({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = levelFor(value).color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('$value%',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 10,
              color: color,
              backgroundColor: AppColors.bg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skala izgaranja sa markerom na trenutnom rezultatu.
class BurnoutGauge extends StatelessWidget {
  const BurnoutGauge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final level = levelFor(score);
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          const marker = 24.0;
          final left =
              (score.clamp(0, 100) / 100 * width - marker / 2).clamp(0.0, width - marker);
          return SizedBox(
            height: marker,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: (marker - 12) / 2,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(colors: [
                        for (final l in burnoutLevels) l.color,
                      ]),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  left: left,
                  top: 0,
                  child: Container(
                    width: marker,
                    height: marker,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: level.color, width: 6),
                      boxShadow: AppColors.cardShadow,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final l in burnoutLevels)
              Text(
                l.label,
                style: TextStyle(
                  fontSize: 12,
                  color: l == level ? l.color : AppColors.muted,
                  fontWeight: l == level ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MiraAvatar extends StatelessWidget {
  const MiraAvatar({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF7ACB4C), Color(0xFF2BAA8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text('🌿', style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
    this.action,
  });

  final String emoji;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Lekcija/tekst sa pasusima, ujednačenog stila.
class Paragraphs extends StatelessWidget {
  const Paragraphs(this.paragraphs, {super.key});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(p, style: const TextStyle(fontSize: 16.5, height: 1.55)),
          ),
      ],
    );
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
