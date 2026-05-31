import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../shared/themes/theme_provider.dart';
import 'map_item.dart';

class PetaBelajarPainter extends CustomPainter {
  final List<NodePos> positions;
  final BloomTheme t;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double curveOffset;

  PetaBelajarPainter({
    required this.positions,
    required this.t,
    this.strokeWidth = 4,
    this.dashWidth = 10,
    this.dashSpace = 8,
    this.curveOffset = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = t.border.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < positions.length - 1; i++) {
      final a = positions[i];
      final b = positions[i + 1];

      final path = Path();
      path.moveTo(a.x, a.y);
      path.cubicTo(a.x, a.y + curveOffset, b.x, b.y - curveOffset, b.x, b.y);

      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        double distance = 0;
        while (distance < metric.length) {
          final end = min(distance + dashWidth, metric.length);
          final segment = metric.extractPath(distance, end);
          canvas.drawPath(segment, paint);
          distance += dashWidth + dashSpace;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PetaBelajarPainter o) =>
      o.positions != positions;
}