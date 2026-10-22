import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';

/// Kartica za izbor pola na početnom ekranu.
///
/// Ako postoje fotografije assets/images/male.jpg i assets/images/female.jpg,
/// one se prikazuju; u suprotnom se crta jednostavna ilustracija.
class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.gender,
    required this.label,
    required this.onTap,
  });

  final Gender gender;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    return AspectRatio(
      aspectRatio: 0.64,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/${gender.name}.jpg',
                    fit: BoxFit.cover,
                    // Ilustracija se vidi dok se slika učitava ili ako je nema.
                    frameBuilder: (context, child, frame, wasSync) =>
                        frame == null && !wasSync
                            ? CustomPaint(painter: _PersonPainter(gender))
                            : child,
                    errorBuilder: (context, error, stack) => CustomPaint(
                      painter: _PersonPainter(gender),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 12,
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.only(left: 18, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                label,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.blue, size: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  _PersonPainter(this.gender);

  final Gender gender;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isMale = gender == Gender.male;

    // Nebo
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyTop, AppColors.skyBottom],
        ).createShader(rect),
    );
    // Sunčev odsjaj
    canvas.drawCircle(
      Offset(w * (isMale ? 0.85 : 0.15), h * 0.1),
      w * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(
          center: Offset(w * (isMale ? 0.85 : 0.15), h * 0.1),
          radius: w * 0.55,
        )),
    );

    final skin = Paint()
      ..color = isMale ? const Color(0xFFE2AE8C) : const Color(0xFFEDC0A2);
    final skinShade = Paint()
      ..color = isMale ? const Color(0xFFCF9A78) : const Color(0xFFDDAA8B);
    final hair = Paint()
      ..color = isMale ? const Color(0xFF4A3426) : const Color(0xFF7A4B32);
    final shirt = Paint()..color = const Color(0xFFF8F5EF);
    final shirtShade = Paint()..color = const Color(0xFFE9E4DA);

    final cx = w / 2;
    final headCenter = Offset(cx, h * 0.40);
    final headW = w * 0.30;
    final headH = h * 0.235;

    // Duga kosa iza glave (žena)
    if (!isMale) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(cx - headW * 0.78, h * 0.27, cx + headW * 0.78, h * 0.74),
          topLeft: Radius.circular(w * 0.2),
          topRight: Radius.circular(w * 0.2),
          bottomLeft: Radius.circular(w * 0.08),
          bottomRight: Radius.circular(w * 0.08),
        ),
        hair,
      );
    }

    // Vrat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, h * 0.585), width: w * 0.17, height: h * 0.14),
        Radius.circular(w * 0.05),
      ),
      skinShade,
    );

    // Majica / ramena
    final shoulders = Rect.fromLTRB(-w * 0.12, h * 0.64, w * 1.12, h * 1.25);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        shoulders,
        topLeft: Radius.circular(w * 0.4),
        topRight: Radius.circular(w * 0.4),
      ),
      shirt,
    );
    // Izrez
    final neckline = Path();
    if (isMale) {
      neckline.addOval(Rect.fromCenter(
          center: Offset(cx, h * 0.645), width: w * 0.22, height: h * 0.05));
    } else {
      neckline
        ..moveTo(cx - w * 0.11, h * 0.63)
        ..lineTo(cx, h * 0.73)
        ..lineTo(cx + w * 0.11, h * 0.63)
        ..close();
    }
    canvas.drawPath(neckline, skinShade);
    // Senka nabora
    canvas.drawLine(
      Offset(w * 0.22, h * 0.82),
      Offset(w * 0.26, h * 0.98),
      shirtShade..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(w * 0.78, h * 0.82),
      Offset(w * 0.74, h * 0.98),
      shirtShade,
    );

    // Uši
    for (final dx in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + dx * headW * 0.5, headCenter.dy + headH * 0.04),
          width: w * 0.06,
          height: h * 0.05,
        ),
        skinShade,
      );
    }

    // Glava
    final head = Rect.fromCenter(center: headCenter, width: headW, height: headH);
    canvas.drawOval(head, skin);

    // Kosa napred: kosa linija sa razdeljkom sa strane
    final hairline = Path()
      ..moveTo(0, 0)
      ..lineTo(0, headCenter.dy - headH * (isMale ? 0.02 : 0.08))
      ..lineTo(head.left + headW * 0.02, headCenter.dy - headH * (isMale ? 0.02 : 0.08))
      ..quadraticBezierTo(
        cx - headW * 0.15,
        head.top + headH * (isMale ? 0.14 : 0.30),
        head.right + w * 0.03,
        head.top + headH * (isMale ? 0.32 : 0.22),
      )
      ..lineTo(w, head.top + headH * (isMale ? 0.32 : 0.22))
      ..lineTo(w, 0)
      ..close();
    canvas.save();
    canvas.clipPath(hairline);
    canvas.drawOval(
        head.inflate(w * 0.02).shift(Offset(0, -h * 0.01)), hair);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) =>
      oldDelegate.gender != gender;
}
