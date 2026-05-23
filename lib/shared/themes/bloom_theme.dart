import 'package:flutter/material.dart';

class BloomTheme {
  final String id;
  final String name;
  final String emoji;

  final Color bgPrimary;
  final Color bgSurface;
  final Color bgSurface2;
  final Color bgSurface3;

  final Color border;

  final Color primary;
  final Color primaryContent;

  final Color accent;
  final Color accentDark;
  final Color accentText;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color mutedText;

  final Color successText;
  final Color warningText;
  final Color errorText;
  final Color infoText;

  final Color secondary;
  final Color secondaryContent;
  final Color accentContent;
  final Color successContent;
  final Color warningContent;
  final Color errorContent;
  final Color infoContent;

  final bool isLight;

  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const BloomTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isLight,
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgSurface2,
    required this.bgSurface3,
    required this.border,
    required this.primary,
    required this.primaryContent,
    required this.accent,
    required this.accentDark,
    required this.accentText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.mutedText,
    required this.successText,
    required this.warningText,
    required this.errorText,
    required this.infoText,
    required this.secondary,
    required this.secondaryContent,
    required this.accentContent,
    required this.successContent,
    required this.warningContent,
    required this.errorContent,
    required this.infoContent,
    this.success = const Color(0xFF4CAF50),
    this.error = const Color(0xFFFF6B6B),
    this.warning = const Color(0xFFFF9F43),
    this.info = const Color(0xFF4A90E2),
  });
}
