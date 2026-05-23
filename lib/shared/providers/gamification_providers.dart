import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/achievement/presentation/providers/achievement_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/leaderboard/presentation/providers/leaderboard_provider.dart';
import '../../features/store/presentation/providers/store_provider.dart';
import '../../features/courses/presentation/providers/course_provider.dart';

void invalidateGamificationProviders(
  WidgetRef ref, {
  String? courseId,
  String? quizId,
  Set<String> skip = const {},
}) {
  if (!skip.contains('xp')) ref.invalidate(xpProvider);
  if (!skip.contains('streak')) ref.invalidate(streakProvider);
  if (!skip.contains('badges')) ref.invalidate(userBadgesProvider);
  if (!skip.contains('lives')) ref.invalidate(livesProvider);
  if (!skip.contains('profile')) ref.invalidate(profileProvider);
  if (!skip.contains('jewel')) ref.invalidate(jewelBalanceProvider);
  if (!skip.contains('jewelHistory')) ref.invalidate(jewelHistoryProvider);
  if (!skip.contains('leaderboard')) ref.invalidate(leaderboardProvider);
  if (!skip.contains('xpHistory')) ref.invalidate(xpHistoryProvider);
  if (!skip.contains('levels')) ref.invalidate(levelsProvider);
  if (!skip.contains('events')) ref.invalidate(eventsProvider);
  if (!skip.contains('enrolledCourses')) ref.invalidate(enrolledCoursesProvider);
  if (courseId != null && !skip.contains('courseDetail')) {
    ref.invalidate(courseDetailProvider(courseId));
  }
  if (quizId != null) {
    if (!skip.contains('myQuizResult')) ref.invalidate(myQuizResultProvider(quizId));
    if (!skip.contains('quizPreview')) ref.invalidate(quizPreviewProvider(quizId));
    if (!skip.contains('quizAttempt')) ref.invalidate(quizAttemptProvider(quizId));
  }
}
