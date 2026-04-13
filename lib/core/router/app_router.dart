import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/courses/presentation/screens/lesson_screen.dart';
import '../../features/courses/presentation/screens/quiz_screen.dart';
import '../../shared/widgets/main_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
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
          // ── Ganti false → true untuk aktifkan Versi 2 (bubble quiz terpisah) ──
          showQuizBubbles: false,
        ),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, s) => LessonScreen(
          lessonId : s.pathParameters['lessonId']!,
          // courseId dipakai untuk refresh bubble setelah selesai
          courseId : s.uri.queryParameters['courseId'],
          // quizId hanya ada di Versi 1 (null di Versi 2)
          quizId   : s.uri.queryParameters['quizId'],
        ),
      ),
      GoRoute(
        path: '/quiz/:quizId',
        builder: (_, s) => QuizScreen(
          quizId   : s.pathParameters['quizId']!,
          // courseId dipakai untuk refresh bubble setelah submit quiz
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