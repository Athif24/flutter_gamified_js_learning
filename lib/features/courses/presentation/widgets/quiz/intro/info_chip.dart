import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class InfoChip extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final Color color;

  const InfoChip(this.t, this.icon, this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 14),
        vertical: S.scale(context, 7),
      ),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 50)),
        border: Border.all(color: t.border, width: S.scale(context, 1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: S.scale(context, 16), color: color),
          SizedBox(width: S.scale(context, 6)),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontSize: S.font(context, 12),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}