import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class SectionHeader extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final IconData icon;
  final String? count;
  const SectionHeader({
    super.key,
    required this.t,
    required this.title,
    required this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(child: Icon(icon, color: t.warning, size: S.scale(context, 20))),
        SizedBox(width: S.scale(context, 8)),
        Text(
          title,
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontSize: S.font(context, 16),
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count != null) ...[
          const Spacer(),
          Text(
            count!,
            style: GoogleFonts.nunito(
              color: t.textSecondary,
              fontSize: S.font(context, 13),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
