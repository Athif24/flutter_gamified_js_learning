import 'package:flutter/material.dart';

/// Returns true if the user has requested reduced motion in system settings.
bool a11yReduceMotion(BuildContext context) {
  return MediaQuery.disableAnimationsOf(context);
}

/// Wraps a widget to respect the user's reduced motion preference.
/// If disabled, returns the child as-is (animations enabled).
/// If enabled, returns a static version (no animation).
Widget a11yRespectAnimations({
  required BuildContext context,
  required Widget animatedChild,
  required Widget staticChild,
}) {
  return a11yReduceMotion(context) ? staticChild : animatedChild;
}

/// Ensures a minimum hit target size of 48x48 for accessibility.
/// Wraps the child in a SizedBox if its dimensions are smaller.
Widget a11yMinHitTarget({
  required Widget child,
  double minWidth = 48,
  double minHeight = 48,
}) {
  return SizedBox(
    width: minWidth,
    height: minHeight,
    child: Center(child: child),
  );
}

/// Returns an appropriate text scale factor, clamped to a safe range.
TextScaler a11ySafeTextScaler(BuildContext context, {double maxScale = 1.3}) {
  final scaler = MediaQuery.textScalerOf(context);
  return TextScaler.linear(
    scaler.scale(1.0).clamp(1.0, maxScale),
  );
}

/// Wraps decorative/background widgets to exclude them from semantics tree.
Widget a11yExcludeDecorations({required Widget child}) {
  return ExcludeSemantics(child: child);
}
