import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
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

final _navLogger = NavigationLogger();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    observers: [_navLogger],
    refreshListenable: ref.watch(authRefreshNotifierProvider),
    redirect: (context, state) {
      final auth     = ref.read(authProvider);
      final loggedIn = auth.isLoggedIn;
      final onAuth   = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      if (auth.isCheckingAuth) {
        return onSplash ? null : '/splash';
      }

      if (onSplash) {
        return loggedIn ? '/home' : '/login';
      }

      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn  && onAuth)  return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash',
          builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',
          builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',
          builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home',
          builder: (_, __) => const MainScreen()),
      GoRoute(
        path: '/course/:courseId',
        pageBuilder: (_, s) => CustomTransitionPage(
          key: s.pageKey,
          child: CourseDetailScreen(
            courseId: s.pathParameters['courseId']!,
          ),
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
        ),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, s) => LessonScreen(
          lessonId : s.pathParameters['lessonId']!,
          courseId : s.uri.queryParameters['courseId'],
        ),
      ),
      GoRoute(
        path: '/quiz-intro/:quizId',
        builder: (_, s) => QuizIntroScreen(
          quizId   : s.pathParameters['quizId']!,
          courseId : s.uri.queryParameters['courseId'],
        ),
      ),
      GoRoute(
        path: '/quiz/:quizId',
        builder: (_, s) => QuizScreen(
          quizId   : s.pathParameters['quizId']!,
          courseId : s.uri.queryParameters['courseId'],
        ),
      ),
    ],
    errorBuilder: (ctx, state) => const Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan',
          style: TextStyle(color: Colors.white))),
    ),
  );
});