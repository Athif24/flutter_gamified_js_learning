import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';

class ScoreRing extends StatelessWidget {
  final int pct;
  final bool isPassed;
  final bool isSuper;
  final BloomTheme t;
  final Color ringBgColor;
  final double size;

  const ScoreRing({
    super.key,
    required this.pct,
    required this.isPassed,
    required this.isSuper,
    required this.t,
    required this.ringBgColor,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RingPainter(
          pct: pct / 100.0,
          color: isPassed ? t.success : t.error,
          strokeWidth: S.scale(context, 10),
          ringBgColor: ringBgColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 24),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SKOR',
                style: GoogleFonts.nunito(
                  color: t.textSecondary,
                  fontSize: S.font(context, 10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final double strokeWidth;
  final Color ringBgColor;

  RingPainter({
    required this.pct,
    required this.color,
    required this.strokeWidth,
    required this.ringBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = ringBgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      3.14159 * 2 * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.pct != pct ||
        oldDelegate.color != color ||
        oldDelegate.ringBgColor != ringBgColor;
  }
}
