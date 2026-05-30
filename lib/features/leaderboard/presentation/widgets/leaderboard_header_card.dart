import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';

class HeaderCard extends StatelessWidget {
  final BloomTheme t;
  final int? currentUserRank;
  final int? currentUserXp;
  const HeaderCard({
    super.key,
    required this.t,
    this.currentUserRank,
    this.currentUserXp,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Header Leaderboard',
      child: Container(
        padding: EdgeInsets.all(S.scale(context, 16)),
        decoration: BoxDecoration(
          color: t.primary,
          borderRadius: BorderRadius.circular(S.scale(context, 24)),
          border: Border.all(color: t.textPrimary, width: 2),
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
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: t.primaryContent,
                  size: S.scale(context, 32),
                ),
                SizedBox(width: S.scale(context, 8)),
                Text(
                  'Leaderboard',
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: S.font(context, 24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: S.scale(context, 4)),
            Padding(
              padding: EdgeInsets.only(left: S.scale(context, 4)),
              child: Text(
                'Lihat peringkat Anda dan kompetisi dengan pemain lain',
                style: GoogleFonts.nunito(
                  color: t.primaryContent.withValues(alpha: 0.8),
                  fontSize: S.font(context, 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
