import 'package:flutter/material.dart';

class SplashGridRingsPainter extends CustomPainter {
  final bool isDark;

  SplashGridRingsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width * (60 / 1080);
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: isDark ? 0.07 : 0.04)
      ..strokeWidth = 1;

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final center = Offset(size.width / 2, size.height / 2);
    const radii = [420.0, 300.0, 190.0, 100.0];
    const alphas = [18, 28, 45, 60];

    for (int i = 0; i < 4; i++) {
      final ringPaint = Paint()
        ..color = const Color(0xFFEF9F27).withValues(alpha: alphas[i] / 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (2 / 1080);
      canvas.drawCircle(center, size.width * (radii[i] / 1080), ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashGridRingsPainter old) =>
      old.isDark != isDark;
}
