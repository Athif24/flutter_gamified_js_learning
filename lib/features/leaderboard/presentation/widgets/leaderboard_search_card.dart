import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';

class SearchCard extends StatelessWidget {
  final BloomTheme t;
  final ValueChanged<String> onChanged;
  const SearchCard({
    super.key,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 18)),
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
          Text(
            'Cari Pemain',
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: S.font(context, 12),
            ),
          ),
          SizedBox(height: S.scale(context, 8)),
          Container(
            decoration: BoxDecoration(
              color: t.bgPrimary,
              borderRadius: BorderRadius.circular(S.scale(context, 10)),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.3)),
            ),
            child: Semantics(
              label: 'Cari pemain',
              child: TextField(
                onChanged: onChanged,
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 13),
                ),
                decoration: InputDecoration(
                  hintText: 'Ketik nama pemain...',
                  hintStyle: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: S.font(context, 13),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: t.mutedText,
                    size: S.scale(context, 20),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: S.scale(context, 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
