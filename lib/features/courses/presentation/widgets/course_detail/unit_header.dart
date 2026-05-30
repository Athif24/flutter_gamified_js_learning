import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class UnitHeader extends StatelessWidget {
  final String name;
  final BloomTheme t;
  final bool compact;
  const UnitHeader({
    super.key,
    required this.name,
    required this.t,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? S.scale(context, 48) : S.scale(context, 72),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          Expanded(
            flex: 3,
            child: Divider(color: t.border.withValues(alpha: 0.15)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: S.scale(context, 12)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: S.scale(context, 14),
                vertical: S.scale(context, 5),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(S.scale(context, 50)),
                border: Border.all(width: S.scale(context, 2), color: t.textPrimary),
                color: t.bgSurface2,
                boxShadow: [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.font(context, 11),
                  fontWeight: FontWeight.w900,
                  letterSpacing: S.scale(context, 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Divider(color: t.border.withValues(alpha: 0.15)),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}