import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class WelcomeStep extends ConsumerWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    double rs(double px) => S.scale(context, px);

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
                    fontSize: S.font(context, 22),
                    fontWeight: FontWeight.w900,
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: rs(6)),
                Text(
                  'Siap-siap jadi master JavaScript bareng Bloom',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: S.font(context, 16),
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
    double rs(double px) => S.scale(context, px);
    return Padding(
      padding: EdgeInsets.only(bottom: rs(12)),
      child: Row(
        children: [
          Container(
            width: rs(44),
            height: rs(44),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
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
                SizedBox(height: S.scale(context, 2)),
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