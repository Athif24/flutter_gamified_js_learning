import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class EmptyState extends StatelessWidget {
  final BloomTheme t;
  const EmptyState({super.key, required this.t});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(S.scale(context, 32)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: S.scale(context, 80)),
        decoration: BoxDecoration(
          color: t.bgSurface,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book,
              size: S.scale(context, 64),
              color: t.mutedText.withValues(alpha: 0.5),
            ),
            SizedBox(height: S.scale(context, 16)),
            Text(
              'Belum ada kursus nih',
              style: GoogleFonts.nunito(
                color: t.textPrimary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: S.font(context, 16),
              ),
            ),
            SizedBox(height: S.scale(context, 4)),
            Text(
              'Sabar ya, admin lagi nyiapin kursus kece buat kamu!',
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 13),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
