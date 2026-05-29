import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class StoreEmptyState extends StatelessWidget {
  final BloomTheme t;
  final String emoji, title, subtitle;

  const StoreEmptyState({
    super.key,
    required this.t,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              emoji,
              style: TextStyle(fontSize: S.scale(context, 56)),
            ),
          ),
          SizedBox(height: S.scale(context, 14)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: S.scale(context, 16),
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: S.scale(context, 6)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.scale(context, 13),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}