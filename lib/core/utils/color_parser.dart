import 'package:flutter/material.dart';

/// Parses a hex color string (e.g., "#FF5733") into a [Color].
/// Returns null if the string is invalid or empty.
Color? parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  } catch (_) {
    return null;
  }
}
