import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'shared/themes/app_theme.dart';
import 'shared/themes/theme_provider.dart';

class BloomApp extends ConsumerWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router     = ref.watch(appRouterProvider);
    final bloomTheme = themeState.theme;

    return MaterialApp.router(
      title: 'Bloom',
      debugShowCheckedModeBanner: false,
      theme    : AppTheme.build(bloomTheme),
      darkTheme: AppTheme.build(bloomTheme),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}