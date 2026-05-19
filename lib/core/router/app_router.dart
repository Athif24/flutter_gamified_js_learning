import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/courses/presentation/screens/lesson_screen.dart';
import '../../features/courses/presentation/screens/quiz_intro_screen.dart';
import '../../features/courses/presentation/screens/quiz_screen.dart';
import '../../shared/widgets/main_screen.dart';
import '../logging/navigation_logger.dart';

final _navLogger = NavigationLogger();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    observers: [_navLogger],
    redirect: (context, state) async {
      final token    = await SecureStorage.getToken();
      final loggedIn = token != null;
      final onAuth   = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn  && onAuth)  return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login',
          builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',
          builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home',
          builder: (_, __) => const MainScreen()),
      GoRoute(
        path: '/course/:courseId',
        builder: (_, s) => CourseDetailScreen(
          courseId: s.pathParameters['courseId']!,
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