import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class StatCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final String? subtitle;
  final Color color;
  const StatCard({
    super.key,
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 16)),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.08), t.bgSurface),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(
          color: t.textPrimary,
          width: S.scale(context, 2),
        ),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(
              S.scale(context, 3),
              S.scale(context, 3),
            ),
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: S.scale(context, 2),
              ),
            ),
            child: Center(
              child: Icon(icon, color: color, size: S.scale(context, 20)),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 11),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: S.font(context, 20),
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                subtitle!,
                style: GoogleFonts.nunito(
                  color: t.textPrimary.withValues(alpha: 0.5),
                  fontSize: S.font(context, 11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
