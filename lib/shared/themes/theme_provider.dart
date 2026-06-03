export 'bloom_theme.dart';

import 'dart:ui' show Brightness, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloom_theme.dart';
import 'theme_parser.dart';

// ════════════════════════════════════════════════════════════════════════════
// BUILT-IN THEMES (35 exact DaisyUI v5.5.19 themes)
// ════════════════════════════════════════════════════════════════════════════

final bloomThemeList = buildBloomThemeList();

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
    final stored = prefs.getString(_key);
    if (stored != null) {
      state = state.copyWith(themeId: stored);
    } else {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      state = state.copyWith(
        themeId: brightness == Brightness.dark ? 'dark' : 'light',
      );
    }
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
