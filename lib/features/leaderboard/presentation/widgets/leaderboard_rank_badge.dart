import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';
import 'leaderboard_helpers.dart';

class RankBadgeSmall extends StatelessWidget {
  final int rank;
  final BloomTheme t;
  const RankBadgeSmall({
    super.key,
    required this.rank,
    required this.t,
  });

  bool get _isTop3 => rank >= 1 && rank <= 3;

  Color get _bg {
    if (rank == 1) return const Color(0xFFFFD600);
    if (rank == 2) return const Color(0xFFC8C8C8);
    if (rank == 3) return const Color(0xFFFF7A00);
    return t.bgSurface2;
  }

  Color get _fg {
    if (rank == 1) return const Color(0xFF78350F);
    if (rank == 2) return const Color(0xFF475569);
    if (rank == 3) return const Color(0xFF7C2D12);
    return t.mutedText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 10),
        vertical: S.scale(context, 4),
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(S.scale(context, 6)),
        border: _isTop3
            ? Border.all(color: _fg.withValues(alpha: 0.3))
            : Border.all(color: t.border),
        boxShadow: _isTop3
            ? [BoxShadow(color: _bg, offset: const Offset(2, 2), blurRadius: 0)]
            : null,
      ),
      child: Text(
        fmtCompact(rank),
        style: GoogleFonts.nunito(
          color: _fg,
          fontWeight: FontWeight.w900,
          fontSize: S.font(context, 12),
        ),
      ),
    );
  }
}
