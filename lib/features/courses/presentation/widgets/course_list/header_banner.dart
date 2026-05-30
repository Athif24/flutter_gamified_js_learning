import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class HeaderBanner extends StatelessWidget {
  final int courseCount;
  final BloomTheme t;
  const HeaderBanner({super.key, required this.courseCount, required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 16),
        S.scale(context, 12),
        S.scale(context, 16),
        0,
      ),
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(S.scale(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: S.scale(context, 24),
                    color: t.primaryContent,
                  ),
                  SizedBox(width: S.scale(context, 8)),
                  Expanded(
                    child: Text(
                      'Pilih Kursusmu',
                      style: GoogleFonts.nunito(
                        color: t.primaryContent,
                        fontSize: S.font(context, 22),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: S.scale(context, 6)),
              Text(
                'Mulai perjalanan belajarmu dan kuasai skill baru!',
                style: GoogleFonts.nunito(
                  color: t.primaryContent.withValues(alpha: 0.8),
                  fontSize: S.font(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: S.scale(context, 14)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 14),
                  vertical: S.scale(context, 7),
                ),
                decoration: BoxDecoration(
                  color: t.primaryContent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(S.scale(context, 16)),
                  border: Border.all(color: t.textPrimary, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: S.scale(context, 16),
                      color: t.primaryContent.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: S.scale(context, 6)),
                    Text(
                      '$courseCount Kursus Tersedia',
                      style: GoogleFonts.nunito(
                        color: t.primaryContent.withValues(alpha: 0.9),
                        fontSize: S.font(context, 12),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
