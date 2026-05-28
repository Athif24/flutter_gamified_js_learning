import 'package:flutter/material.dart';

class S {
  static bool isTablet(BuildContext c) =>
      MediaQuery.of(c).size.shortestSide >= 600;

  static double scale(BuildContext c, double val) =>
      val * (MediaQuery.of(c).size.width / 375).clamp(0.85, 1.25);

  static double font(BuildContext c, double size) =>
      scale(c, size) * (isTablet(c) ? 1.15 : 1.0);
}
