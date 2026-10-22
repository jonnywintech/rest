import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/person_card.dart';
import 'quiz_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _start(BuildContext context, Gender gender) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(gender: gender)),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('O Predahu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 12),
            Text(
              'Predah je aplikacija za samopomoć: kratak kviz procenjuje nivo izgaranja, a zatim te 28 dana vodi kroz male, svakodnevne korake – lekcije, zadatke, praćenje raspoloženja, dnevnik i razgovor sa AI saputnicom Mirom.\n\nSvi podaci ostaju na tvom uređaju. Predah nije zamena za stručnu pomoć.',
              style: TextStyle(height: 1.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const SizedBox(width: 48),
                const Expanded(child: Center(child: Logo(size: 42))),
                IconButton(
                  onPressed: () => _showAbout(context),
                  icon: const Icon(Icons.menu_rounded, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, color: AppColors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Kviz od 3 minuta',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '28-dnevni izazov\nprotiv izgaranja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: PersonCard(
                    gender: Gender.male,
                    label: 'Muškarac',
                    onTap: () => _start(context, Gender.male),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PersonCard(
                    gender: Gender.female,
                    label: 'Žena',
                    onTap: () => _start(context, Gender.female),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Odgovori iz kviza ostaju samo na tvom uređaju.\nPredah nije zamena za savet lekara ili psihologa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
