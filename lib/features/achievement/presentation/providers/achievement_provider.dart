  import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/datasources/achievement_remote_datasource.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/event_model.dart';

final achievementDsProvider = Provider((ref) =>
    AchievementRemoteDatasource(ref.read(apiClientProvider)));

final xpProvider = FutureProvider<XpModel>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  final levels = await ref.watch(levelsProvider.future);
  final sorted = List<LevelModel>.from(levels)
    ..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));
  final currentIdx = sorted.lastIndexWhere((l) => l.requiredXp <= profile.xpTotal);
  final currentLevel = currentIdx >= 0 ? sorted[currentIdx] : null;
  final nextIdx = sorted.indexWhere((l) => l.requiredXp > profile.xpTotal);
  final nextLevel = nextIdx >= 0 ? sorted[nextIdx] : null;
  final xpToNextLevel = nextLevel != null
      ? nextLevel.requiredXp - profile.xpTotal
      : 0;
  return XpModel(
    totalXp: profile.xpTotal,
    level: profile.level,
    levelTitle: profile.levelTitle,
    xpToNextLevel: xpToNextLevel,
    jewels: profile.jewels,
    nextLevelTitle: nextLevel?.name,
    currentLevelRequiredXp: currentLevel?.requiredXp ?? 0,
  );
});

final streakProvider = FutureProvider<StreakModel>(
    (ref) => ref.read(achievementDsProvider).getStreak());

final userBadgesProvider = FutureProvider<List<BadgeModel>>(
    (ref) => ref.read(achievementDsProvider).getUserBadges());

final allBadgesProvider = FutureProvider<List<BadgeModel>>(
    (ref) => ref.read(achievementDsProvider).getAllBadges());

final mergedBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final ds = ref.read(achievementDsProvider);
  final [allBadges, userBadges] = await Future.wait([
    ds.getAllBadges(),
    ds.getUserBadges(),
  ]);
  final earnedIds = userBadges.map((ub) => ub.id).toSet();
  return allBadges.map((badge) {
    final earned = userBadges.where((ub) => ub.id == badge.id).firstOrNull;
    return BadgeModel(
      id: badge.id,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      rarity: badge.rarity,
      isEarned: earnedIds.contains(badge.id),
      earnedAt: earned?.earnedAt,
      requiredValue: badge.requiredValue,
      conditionType: badge.conditionType,
      conditionValue: badge.conditionValue,
      rewardJewels: badge.rewardJewels,
    );
  }).toList();
});

final xpHistoryProvider = FutureProvider<List<XpHistoryEntry>>(
    (ref) => ref.read(achievementDsProvider).getXpHistory());

final levelsProvider = FutureProvider<List<LevelModel>>(
    (ref) => ref.read(achievementDsProvider).getLevels());

final eventDsProvider = Provider((ref) =>
    EventRemoteDatasource(ref.read(apiClientProvider)));

final eventsProvider = FutureProvider<List<EventModel>>(
    (ref) => ref.read(eventDsProvider).getEvents());

final livesProvider = FutureProvider<LivesModel>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  return LivesModel(
    current: profile.lifes,
    max: profile.maxLives,
  );
});

final learningReportProvider = FutureProvider<LearningReportModel>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  return LearningReportModel(
    quizAttempts: profile.quizAttempts,
    quizPassed: profile.quizPassed,
    averageScore: profile.avgScore,
    bestScore: profile.bestScore,
    lessonsCompleted: profile.lessonsCompleted,
    coursesCompleted: 0,
  );
});