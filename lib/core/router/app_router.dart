import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding/screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/courses/presentation/screens/lesson_screen.dart';
import '../../features/courses/presentation/screens/quiz_intro_screen.dart';
import '../../features/courses/presentation/screens/quiz_screen.dart';
import '../../shared/widgets/main_screen.dart';
import '../logging/navigation_logger.dart';
import '../auth/auth_refresh_notifier.dart';
import '../navigation/deep_link_helper.dart';

final _navLogger = NavigationLogger();

Widget _nullRouteRedirect(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => GoRouter.of(context).go('/home'),
  );
  return const SizedBox.shrink();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    observers: [_navLogger],
    refreshListenable: Listenable.merge([
      ref.watch(authRefreshNotifierProvider),
      pendingDeepLinkNotifier,
    ]),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggedIn = auth.isLoggedIn;
      final onAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      if (auth.isCheckingAuth) {
        return onSplash ? null : '/splash';
      }

      if (onSplash) {
        return loggedIn ? '/home' : '/login';
      }

      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/home';

      if (loggedIn &&
          !auth.wizardCompleted &&
          state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      final deepLink = pendingDeepLinkNotifier.value;
      if (deepLink != null &&
          loggedIn &&
          auth.wizardCompleted &&
          state.matchedLocation == '/home') {
        pendingDeepLinkNotifier.value = null;
        return deepLink;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (_, __) => const MainScreen()),
      GoRoute(
        path: '/course/:courseId',
        pageBuilder: (context, s) {
          final courseId = s.pathParameters['courseId'];
          return CustomTransitionPage(
            key: s.pageKey,
            child: courseId != null
                ? CourseDetailScreen(courseId: courseId)
                : _nullRouteRedirect(context),
            transitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (_, animation, __, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(curved),
                child: FadeTransition(opacity: curved, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, s) {
          final lessonId = s.pathParameters['lessonId'];
          if (lessonId == null) return _nullRouteRedirect(context);
          return LessonScreen(
            lessonId: lessonId,
            courseId: s.uri.queryParameters['courseId'],
          );
        },
      ),
      GoRoute(
        path: '/quiz-intro/:quizId',
        builder: (context, s) {
          final quizId = s.pathParameters['quizId'];
          if (quizId == null) return _nullRouteRedirect(context);
          return QuizIntroScreen(
            quizId: quizId,
            courseId: s.uri.queryParameters['courseId'],
            lessonId: s.uri.queryParameters['lessonId'],
          );
        },
      ),
      GoRoute(
        path: '/quiz/:quizId',
        builder: (context, s) {
          final quizId = s.pathParameters['quizId'];
          if (quizId == null) return _nullRouteRedirect(context);
          return QuizScreen(
            quizId: quizId,
            courseId: s.uri.queryParameters['courseId'],
            lessonId: s.uri.queryParameters['lessonId'],
          );
        },
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctx.go('/home'),
              child: const Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    ),
  );
});