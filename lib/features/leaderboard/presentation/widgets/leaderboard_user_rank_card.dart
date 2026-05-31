import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/number_formatter.dart';
import 'leaderboard_rank_badge.dart';

class UserRankCard extends StatelessWidget {
  final BloomTheme t;
  final int rank;
  final int xp;
  const UserRankCard({
    super.key,
    required this.t,
    required this.rank,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Posisi Anda: ranking $rank, total XP $xp',
      child: Container(
        padding: EdgeInsets.all(S.scale(context, 24)),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(S.scale(context, 24)),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posisi Anda',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: S.font(context, 18),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                        Icons.local_fire_department_rounded,
                        size: S.scale(context, 24),
                        color: t.warning,
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.15, 1.15),
                        duration: 1000.ms,
                      ),
                ),
              ],
            ),
            SizedBox(height: S.scale(context, 16)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RANKING',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 10),
                          letterSpacing: S.scale(context, 1.5),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 4)),
                      Row(
                        children: [
                          Text(
                            '#$rank',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: S.font(context, 36),
                            ),
                          ),
                          SizedBox(width: S.scale(context, 8)),
                          RankBadgeSmall(rank: rank, t: t),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL XP',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 10),
                          letterSpacing: S.scale(context, 1.5),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatNumber(xp),
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: S.font(context, 36),
                              ),
                            ),
                          ),
                          SizedBox(width: S.scale(context, 4)),
                          Text(
                            'XP',
                            style: GoogleFonts.nunito(
                              color: t.mutedText,
                              fontWeight: FontWeight.w700,
                              fontSize: S.font(context, 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
