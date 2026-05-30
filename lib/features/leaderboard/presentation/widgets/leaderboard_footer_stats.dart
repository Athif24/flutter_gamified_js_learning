import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/number_formatter.dart';

class FooterStats extends StatelessWidget {
  final BloomTheme t;
  final int total;
  final int topXp;
  final int? myRank;
  const FooterStats({
    super.key,
    required this.t,
    required this.total,
    required this.topXp,
    this.myRank,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Statistik: $total pemain, Top XP $topXp${myRank != null ? ', ranking anda $myRank' : ''}',
      child: Container(
        padding: EdgeInsets.all(S.scale(context, 16)),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(S.scale(context, 18)),
          border: Border.all(
            color: t.textPrimary,
            width: S.scale(context, 2),
          ),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: Offset(S.scale(context, 3), S.scale(context, 3)),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            StatItem(
              t: t,
              label: 'Total Pemain',
              value: formatNumber(total),
              color: t.primary,
            ),
            StatItem(
              t: t,
              label: 'Top XP',
              value: formatNumber(topXp),
              color: t.success,
            ),
            if (myRank != null)
              StatItem(
                t: t,
                label: 'Ranking Anda',
                value: '#$myRank',
                color: t.info,
              ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final String value;
  final Color color;
  const StatItem({
    super.key,
    required this.t,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w800,
            fontSize: S.font(context, 10),
            letterSpacing: S.scale(context, 1.5),
          ),
        ),
        SizedBox(height: S.scale(context, 4)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: S.font(context, 20),
            ),
          ),
        ),
      ],
    ),
  );
  }
}
