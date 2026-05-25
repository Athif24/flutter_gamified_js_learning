import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';

class PositionStep extends ConsumerWidget {
  const PositionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.celebration_rounded, size: 64, color: t.primary),
          const SizedBox(height: 16),
          Text('Siap Memulai!',
              style: GoogleFonts.nunito(
                  fontSize: 24, fontWeight: FontWeight.w900, color: t.textPrimary)),
          const SizedBox(height: 8),
          Text('Ini posisi awal kamu. Yuk kejar yang terbaik!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: t.mutedText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _StatCard(t: t, icon: Icons.stars_rounded, label: 'XP Awal', value: '0')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(t: t, icon: Icons.monitor_heart_rounded, label: 'Level', value: '1')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(t: t, icon: Icons.leaderboard_rounded, label: 'Peringkat', value: '-')),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded, color: t.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perjalanan sejauh ribuan kilometer dimulai dari satu langkah.',
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: t.textPrimary,
                        fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
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
  final BloomTheme t; final IconData icon; final String label; final String value;
  const _StatCard({required this.t, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.border),
    ),
    child: Column(
      children: [
        Icon(icon, color: t.primary, size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w900, color: t.textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 10, color: t.mutedText, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
