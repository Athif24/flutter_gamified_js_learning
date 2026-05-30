import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';

class Separator extends StatelessWidget {
  final BloomTheme t;
  const Separator({
    super.key,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: S.scale(context, 4)),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(color: t.mutedText),
              child: const SizedBox(height: 2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: S.scale(context, 8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 2)),
                child: Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: S.scale(context, 6),
                    height: S.scale(context, 6),
                    color: t.mutedText,
                  ),
                ),
              )),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(color: t.mutedText),
              child: const SizedBox(height: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  const DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      final end = (x + dash).clamp(0, size.width).toDouble();
      canvas.drawLine(Offset(x, size.height / 2), Offset(end, size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => color != oldDelegate.color;
}
