import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class StatBadge extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final Color color;
  final int delay;

  const StatBadge({
    super.key,
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: S.scale(context, 18), color: color),
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
}
