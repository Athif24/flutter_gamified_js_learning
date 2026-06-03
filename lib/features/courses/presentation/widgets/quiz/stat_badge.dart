import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

enum StatBadgeVariant { standard, neoBru }

class StatBadge extends StatelessWidget {
  final BloomTheme t;
  final String emoji;
  final String value, label;
  final Color color;
  final int delay;
  final StatBadgeVariant variant;

  const StatBadge({
    super.key,
    required this.t,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    this.delay = 0,
    this.variant = StatBadgeVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == StatBadgeVariant.neoBru) {
      return _buildNeoBru(context);
    }
    return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: S.scale(context, 18))),
                SizedBox(width: S.scale(context, 4)),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    color: color,
                    fontSize: S.font(context, 18),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: S.scale(context, 4)),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 10),
                fontWeight: FontWeight.w900,
                letterSpacing: S.scale(context, 1.5),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.6, 0.6));
  }

  Widget _buildNeoBru(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: S.scale(context, 5)),
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 14),
        vertical: S.scale(context, 10),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.75), width: 2),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary.withValues(alpha: 0.7),
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: S.scale(context, 18))),
          SizedBox(height: S.scale(context, 3)),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: S.font(context, 19),
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: t.textSecondary,
              fontSize: S.font(context, 9),
              fontWeight: FontWeight.w700,
              letterSpacing: S.scale(context, 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
