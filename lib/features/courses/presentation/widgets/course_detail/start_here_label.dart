import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class StartHereLabel extends StatelessWidget {
  final BloomTheme t;
  const StartHereLabel({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: S.scale(context, 12),
                vertical: S.scale(context, 6),
              ),
              decoration: BoxDecoration(
                color: t.textPrimary,
                borderRadius: BorderRadius.circular(S.scale(context, 12)),
                border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
              ),
              child: Text(
                'Mulai di sini!',
                style: GoogleFonts.nunito(
                  color: t.bgPrimary,
                  fontSize: S.font(context, 11),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, S.scale(context, -6)),
              child: Transform.rotate(
                angle: 0.7854,
                child: Container(width: S.scale(context, 10), height: S.scale(context, 10), color: t.textPrimary),
              ),
            ),
          ],
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(duration: 1500.ms, begin: 0, end: -4);
  }
}