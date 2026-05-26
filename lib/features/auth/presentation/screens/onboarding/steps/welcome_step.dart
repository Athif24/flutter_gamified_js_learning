import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';

class WelcomeStep extends ConsumerWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rs(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: rs(56),
                  color: t.primary,
                ),
                SizedBox(height: rs(12)),
                Text(
                  'Selamat Datang, Developer Baru!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: rs(6)),
                Text(
                  'Siap-siap jadi master JavaScript bareng Bloom',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: rs(16),
                    color: t.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: rs(20)),
                ..._benefits.map(
                  (b) => _BenefitCard(
                    t: t,
                    icon: b.icon,
                    title: b.title,
                    desc: b.desc,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String desc;
  const _BenefitData(this.icon, this.title, this.desc);
}

const _benefits = [
  _BenefitData(
    Icons.code_rounded,
    'Belajar Interaktif',
    'Materi step-by-step dengan quiz seru dan tantangan coding',
  ),
  _BenefitData(
    Icons.military_tech_rounded,
    'Naik Level & Dapat Badge',
    'Kumpulkan XP, streaks, dan badge keren setiap progres',
  ),
  _BenefitData(
    Icons.diamond_rounded,
    'Tantangan Harian',
    'Jaga streak harian buat unlock reward spesial',
  ),
  _BenefitData(
    Icons.groups_rounded,
    'Komunitas Developer',
    'Bersaing di leaderboard dan belajar bareng teman',
  ),
];

class _BenefitCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String title;
  final String desc;
  const _BenefitCard({
    required this.t,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Padding(
      padding: EdgeInsets.only(bottom: rs(12)),
      child: Row(
        children: [
          Container(
            width: rs(44),
            height: rs(44),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: t.primary, size: rs(22)),
          ),
          SizedBox(width: rs(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: rs(14),
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.nunito(
                    fontSize: rs(12),
                    color: t.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}