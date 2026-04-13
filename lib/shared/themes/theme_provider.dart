import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════════════════
// BLOOM THEME MODEL
// ════════════════════════════════════════════════════════════════════════════

class BloomTheme {
  final String id;
  final String name;
  final String emoji;

  // Backgrounds
  final Color bgPrimary;    // scaffold background
  final Color bgSurface;    // card/surface
  final Color bgSurface2;   // input/secondary surface
  final Color bgSurface3;   // tertiary surface

  // Borders
  final Color border;

  // Accent (CTA, active elements)
  final Color accent;
  final Color accentDark;
  final Color accentText;   // text on top of accent

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Fixed status colors
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const BloomTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgSurface2,
    required this.bgSurface3,
    required this.border,
    required this.accent,
    required this.accentDark,
    required this.accentText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    this.success  = const Color(0xFF4CAF50),
    this.error    = const Color(0xFFFF6B6B),
    this.warning  = const Color(0xFFFF9F43),
    this.info     = const Color(0xFF4A90E2),
  });
}

// ════════════════════════════════════════════════════════════════════════════
// BUILT-IN THEMES (mirip DaisyUI)
// ════════════════════════════════════════════════════════════════════════════

const bloomThemeList = <BloomTheme>[
  // ── Dark (default) ────────────────────────────────────────────────────
  BloomTheme(
    id: 'dark', name: 'Dark', emoji: '🌙',
    bgPrimary  : Color(0xFF0D0F1E), bgSurface : Color(0xFF1A1D2E),
    bgSurface2 : Color(0xFF242740), bgSurface3: Color(0xFF2E3150),
    border     : Color(0xFF363B5E),
    accent     : Color(0xFFF5C518), accentDark: Color(0xFFE0AD00),
    accentText : Color(0xFF1A1A1A),
    textPrimary: Color(0xFFEEEFF8), textSecondary: Color(0xFF8A8FAD),
    textHint   : Color(0xFF565A7A),
  ),
  // ── Light ─────────────────────────────────────────────────────────────
  BloomTheme(
    id: 'light', name: 'Light', emoji: '☀️',
    bgPrimary  : Color(0xFFF2F4F7), bgSurface : Color(0xFFFFFFFF),
    bgSurface2 : Color(0xFFF8F9FB), bgSurface3: Color(0xFFEEF0F5),
    border     : Color(0xFFE0E3EC),
    accent     : Color(0xFF4A90E2), accentDark: Color(0xFF2D6FBF),
    accentText : Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1D23), textSecondary: Color(0xFF6B7280),
    textHint   : Color(0xFF9CA3AF),
  ),
  // ── Purple / Synthwave ────────────────────────────────────────────────
  BloomTheme(
    id: 'purple', name: 'Purple', emoji: '💜',
    bgPrimary  : Color(0xFF1A0A2E), bgSurface : Color(0xFF2D1B4E),
    bgSurface2 : Color(0xFF3D2465), bgSurface3: Color(0xFF4A2D7A),
    border     : Color(0xFF5C3A9A),
    accent     : Color(0xFFBF5FFF), accentDark: Color(0xFF9F3FDF),
    accentText : Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF0E6FF), textSecondary: Color(0xFFB89FD4),
    textHint   : Color(0xFF7A5FA0),
  ),
  // ── Gold / Bumblebee ──────────────────────────────────────────────────
  BloomTheme(
    id: 'gold', name: 'Gold', emoji: '⭐',
    bgPrimary  : Color(0xFF1A1508), bgSurface : Color(0xFF2A2210),
    bgSurface2 : Color(0xFF3A3018), bgSurface3: Color(0xFF4A3E20),
    border     : Color(0xFF5A4E30),
    accent     : Color(0xFFFFD700), accentDark: Color(0xFFE0B800),
    accentText : Color(0xFF1A1508),
    textPrimary: Color(0xFFFFF8E0), textSecondary: Color(0xFFCCA840),
    textHint   : Color(0xFF8A7030),
  ),
  // ── Green / Emerald ───────────────────────────────────────────────────
  BloomTheme(
    id: 'green', name: 'Emerald', emoji: '💚',
    bgPrimary  : Color(0xFF0A1A0E), bgSurface : Color(0xFF122218),
    bgSurface2 : Color(0xFF1A3224), bgSurface3: Color(0xFF224030),
    border     : Color(0xFF2E5A40),
    accent     : Color(0xFF2ECC71), accentDark: Color(0xFF27AE60),
    accentText : Color(0xFF0A1A0E),
    textPrimary: Color(0xFFE0FFF0), textSecondary: Color(0xFF80C098),
    textHint   : Color(0xFF4A7A60),
  ),
  // ── Blue / Corporate ──────────────────────────────────────────────────
  BloomTheme(
    id: 'blue', name: 'Blue', emoji: '💙',
    bgPrimary  : Color(0xFF080F1E), bgSurface : Color(0xFF101828),
    bgSurface2 : Color(0xFF182035), bgSurface3: Color(0xFF202A42),
    border     : Color(0xFF2C3A55),
    accent     : Color(0xFF4A90E2), accentDark: Color(0xFF2D6FBF),
    accentText : Color(0xFFFFFFFF),
    textPrimary: Color(0xFFE0EEFF), textSecondary: Color(0xFF7A9EC8),
    textHint   : Color(0xFF4A6A90),
  ),
  // ── Pink / Cupcake ────────────────────────────────────────────────────
  BloomTheme(
    id: 'pink', name: 'Cupcake', emoji: '🩷',
    bgPrimary  : Color(0xFF1E0A12), bgSurface : Color(0xFF2E1220),
    bgSurface2 : Color(0xFF3E1A2E), bgSurface3: Color(0xFF4E223C),
    border     : Color(0xFF6E3055),
    accent     : Color(0xFFFF6B9D), accentDark: Color(0xFFDF4B7D),
    accentText : Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFE6F0), textSecondary: Color(0xFFCE8AAA),
    textHint   : Color(0xFF8A5070),
  ),
  // ── Cyberpunk ─────────────────────────────────────────────────────────
  BloomTheme(
    id: 'cyber', name: 'Cyberpunk', emoji: '🤖',
    bgPrimary  : Color(0xFF0A0A0A), bgSurface : Color(0xFF141414),
    bgSurface2 : Color(0xFF1E1E1E), bgSurface3: Color(0xFF282828),
    border     : Color(0xFF00FF9F),
    accent     : Color(0xFF00FF9F), accentDark: Color(0xFF00CC80),
    accentText : Color(0xFF0A0A0A),
    textPrimary: Color(0xFF00FF9F), textSecondary: Color(0xFF008866),
    textHint   : Color(0xFF005544),
  ),
  // ── Nord ──────────────────────────────────────────────────────────────
  BloomTheme(
    id: 'nord', name: 'Nord', emoji: '❄️',
    bgPrimary  : Color(0xFF2E3440), bgSurface : Color(0xFF3B4252),
    bgSurface2 : Color(0xFF434C5E), bgSurface3: Color(0xFF4C566A),
    border     : Color(0xFF5E6F8A),
    accent     : Color(0xFF88C0D0), accentDark: Color(0xFF6AA0B0),
    accentText : Color(0xFF2E3440),
    textPrimary: Color(0xFFECEFF4), textSecondary: Color(0xFFD8DEE9),
    textHint   : Color(0xFF8F9BBC),
  ),
  // ── Sunset ────────────────────────────────────────────────────────────
  BloomTheme(
    id: 'sunset', name: 'Sunset', emoji: '🌅',
    bgPrimary  : Color(0xFF1A0808), bgSurface : Color(0xFF2A1010),
    bgSurface2 : Color(0xFF3A1818), bgSurface3: Color(0xFF4A2020),
    border     : Color(0xFF6A3030),
    accent     : Color(0xFFFF6B35), accentDark: Color(0xFFDF4B15),
    accentText : Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFE8E0), textSecondary: Color(0xFFCC8870),
    textHint   : Color(0xFF8A5040),
  ),
];

// ════════════════════════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════════════════════════

class ThemeState {
  final String themeId;
  const ThemeState({this.themeId = 'dark'});

  BloomTheme get theme => bloomThemeList.firstWhere(
        (t) => t.id == themeId,
        orElse: () => bloomThemeList.first,
      );

  ThemeState copyWith({String? themeId}) =>
      ThemeState(themeId: themeId ?? this.themeId);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _key = 'bloom_theme_id';

  ThemeNotifier() : super(const ThemeState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id    = prefs.getString(_key) ?? 'dark';
    state = state.copyWith(themeId: id);
  }

  Future<void> setTheme(String id) async {
    state = state.copyWith(themeId: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((_) => ThemeNotifier());

final currentThemeProvider =
    Provider<BloomTheme>((ref) => ref.watch(themeProvider).theme);