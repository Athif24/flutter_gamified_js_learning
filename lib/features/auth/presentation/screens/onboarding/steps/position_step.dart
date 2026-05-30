import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class PositionStep extends ConsumerWidget {
  const PositionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    double rs(double px) => S.scale(context, px);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.celebration_rounded, size: rs(64), color: t.primary),
          SizedBox(height: rs(16)),
          Text(
            'Siap Memulai!',
            style: GoogleFonts.nunito(
              fontSize: rs(24),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: rs(8)),
          Text(
            'Ini posisi awal kamu. Yuk kejar yang terbaik!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: rs(13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: rs(28)),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  t: t,
                  icon: Icons.stars_rounded,
                  label: 'XP Awal',
                  value: '0',
                ),
              ),
              SizedBox(width: rs(12)),
              Expanded(
                child: _StatCard(
                  t: t,
                  icon: Icons.monitor_heart_rounded,
                  label: 'Level',
                  value: '1',
                ),
              ),
              SizedBox(width: rs(12)),
              Expanded(
                child: _StatCard(
                  t: t,
                  icon: Icons.leaderboard_rounded,
                  label: 'Peringkat',
                  value: '-',
                ),
              ),
            ],
          ),
          SizedBox(height: rs(28)),
          Container(
            padding: EdgeInsets.all(rs(18)),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: t.primary,
                  size: rs(28),
                ),
                SizedBox(width: rs(12)),
                Expanded(
                  child: Text(
                    'Perjalanan sejauh ribuan kilometer dimulai dari satu langkah.',
                    style: GoogleFonts.nunito(
                      fontSize: rs(12),
                      color: t.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({
    required this.t,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    double rs(double px) => S.scale(context, px);
    return Container(
      padding: EdgeInsets.symmetric(vertical: rs(16), horizontal: rs(4)),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 14)),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: t.primary, size: rs(24)),
          SizedBox(height: rs(6)),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: rs(18),
              fontWeight: FontWeight.w900,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: rs(2)),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: rs(10),
              color: t.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}