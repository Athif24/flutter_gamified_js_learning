import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.isCheckingAuth == true && !next.isCheckingAuth) {
        if (next.isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return Scaffold(
      backgroundColor: t.bgPrimary,
    );
  }
}
