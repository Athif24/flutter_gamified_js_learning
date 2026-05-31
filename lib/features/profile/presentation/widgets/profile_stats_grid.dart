import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/profile_model.dart';

class StatData {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const StatData({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });
}

class StatCard extends StatelessWidget {
  final BloomTheme t;
  final StatData data;
  const StatCard({super.key, required this.t, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 16)),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          data.color.withValues(alpha: 0.08),
          t.bgSurface,
        ),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: S.scale(context, 40),
            height: S.scale(context, 40),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
              border: Border.all(
                color: data.color.withValues(alpha: 0.4),
                width: S.scale(context, 2),
              ),
            ),
            child: Center(
              child: ExcludeSemantics(child: Icon(data.icon, color: data.color, size: S.scale(context, 20))),
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          Text(
            data.label,
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: S.font(context, 11),
              fontWeight: FontWeight.w700,
              letterSpacing: S.scale(context, 0.5),
            ),
          ),
          SizedBox(height: S.scale(context, 2)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: S.font(context, 20),
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: S.scale(context, 2)),
          Text(
            data.sub,
            style: GoogleFonts.nunito(
              color: t.textPrimary.withValues(alpha: 0.5),
              fontSize: S.font(context, 11),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ProfileStatsGrid extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  const ProfileStatsGrid({super.key, required this.t, required this.profile});

  @override
  Widget build(BuildContext context) {
    final streakActive = profile.currentStreak > 0;

    final streakLabel = 'STREAK HARI INI';

    final streakValue = profile.currentStreak > 0
        ? '${profile.currentStreak} hari'
        : '0 hari';

    final streakSub = streakActive ? 'tetap konsisten!' : 'mulai lagi sekarang';

    final stats = [
      StatData(
        label: 'TOTAL XP',
        value: formatNumber(profile.xpTotal),
        sub: 'experience points',
        icon: Icons.bolt_rounded,
        color: t.warning,
      ),
      StatData(
        label: 'JEWELS',
        value: formatNumber(profile.jewels),
        sub: 'koin reward',
        icon: Icons.diamond_rounded,
        color: t.info,
      ),
      StatData(
        label: streakLabel,
        value: streakValue,
        sub: streakSub,
        icon: Icons.local_fire_department_rounded,
        color: streakActive ? t.warning : t.textHint,
      ),
      StatData(
        label: 'REKOR STREAK',
        value: '${profile.longestStreak} hari',
        sub: 'pencapaian terbaik',
        icon: Icons.emoji_events_rounded,
        color: t.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final s = S.scale(context, 12);
        final gutter = s * (crossAxisCount - 1);
        final childWidth = (constraints.maxWidth - gutter) / crossAxisCount;
        return Wrap(
          spacing: s,
          runSpacing: s,
          children: stats
              .map(
                (s) => SizedBox(
                  width: childWidth,
                  child: StatCard(t: t, data: s),
                ),
              )
              .toList(),
        );
      },
    ).animate().fadeIn(delay: 100.ms);
  }
}
