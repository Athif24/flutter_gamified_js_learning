import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_screen_transparent.png',
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 400.ms).blur(
                  begin: const Offset(6, 6),
                  end: Offset.zero,
                  duration: 400.ms,
                ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo/logo_app.png',
                  height: 48,
                ).animate(delay: 600.ms).fadeIn(duration: 300.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 8),
                Text(
                  'JS Learning',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 300.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
