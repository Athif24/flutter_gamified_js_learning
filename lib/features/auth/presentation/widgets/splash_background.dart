import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import 'splash_painter.dart';

class SplashBackground extends ConsumerWidget {
  const SplashBackground({super.key});

  static const _particles = <(String, double, double)>[
    ('const', 0.167, 0.292),
    ('() =>', 0.759, 0.224),
    ('[ ]', 0.287, 0.391),
    ('let', 0.722, 0.354),
    ('{  }', 0.130, 0.438),
    ('async', 0.806, 0.427),
    ('.map()', 0.185, 0.510),
    ('=> {}', 0.722, 0.500),
    ('return', 0.093, 0.573),
    ('++i', 0.833, 0.573),
    ('[ ]', 0.324, 0.625),
    ('null', 0.667, 0.625),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final isDark = t.isLight == false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: SplashGridRingsPainter(isDark: isDark),
              ),
            ),

            Positioned.fill(
              child: Center(
                child: _CenterGlow(w: w),
              ),
            ),

            ..._particles.map(
              (p) => Positioned(
                left: w * p.$2,
                top: h * p.$3,
                child: Opacity(
                  opacity: isDark ? 0.22 : 0.35,
                  child: Text(
                    p.$1,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: S.font(context, 11),
                      color: const Color(0xFFEF9F27),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: h * 0.41,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BLOOM',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: S.font(context, 48),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFEF9F27),
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  Center(
                    child: Container(
                      width: w * 0.204,
                      height: S.scale(context, 3),
                      color: const Color(0xFFEF9F27),
                    ),
                  ),
                  SizedBox(height: h * 0.016),
                  Text(
                    'LEVEL UP YOUR THINKING',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: S.font(context, 15),
                      color: isDark
                          ? const Color.fromARGB(230, 220, 220, 220)
                          : const Color.fromARGB(230, 60, 60, 60),
                    ),
                  ),
                  SizedBox(height: h * 0.042),
                  Center(
                    child: _ProgressBar(
                      barWidth: w * 0.296,
                      barHeight: S.scale(context, 4),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CenterGlow extends StatelessWidget {
  final double w;
  const _CenterGlow({required this.w});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glowLayer(w * 0.046, 30),
        _glowLayer(w * 0.028, 80),
        _glowLayer(w * 0.013, 160),
        _glowLayer(w * 0.006, 255),
      ],
    );
  }

  Widget _glowLayer(double radius, int alpha) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEF9F27).withValues(alpha: alpha / 255),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double barWidth;
  final double barHeight;
  final bool isDark;

  const _ProgressBar({
    required this.barWidth,
    required this.barHeight,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dotRadius = S.scale(context, 6);

    return SizedBox(
      width: barWidth,
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(barHeight / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9F27),
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: barWidth - dotRadius,
            top: -dotRadius + barHeight / 2,
            child: Container(
              width: dotRadius * 2,
              height: dotRadius * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEF9F27),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
