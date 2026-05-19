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
}) {
  ref.invalidate(xpProvider);
  ref.invalidate(streakProvider);
  ref.invalidate(userBadgesProvider);
  ref.invalidate(learningReportProvider);
  ref.invalidate(livesProvider);
  ref.invalidate(profileProvider);
  ref.invalidate(jewelBalanceProvider);
  ref.invalidate(jewelHistoryProvider);
  ref.invalidate(leaderboardProvider);
  ref.invalidate(xpHistoryProvider);
  ref.invalidate(levelsProvider);
  ref.invalidate(eventsProvider);
  ref.invalidate(enrolledCoursesProvider);
  if (courseId != null) {
    ref.invalidate(courseDetailProvider(courseId));
  }
  if (quizId != null) {
    ref.invalidate(myQuizResultProvider(quizId));
    ref.invalidate(quizPreviewProvider(quizId));
    ref.invalidate(quizAttemptProvider(quizId));
  }
}
