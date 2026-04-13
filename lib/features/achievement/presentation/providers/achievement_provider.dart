import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/achievement_remote_datasource.dart';
import '../../data/models/achievement_model.dart';

final achievementDsProvider = Provider((ref) =>
    AchievementRemoteDatasource(ref.read(apiClientProvider)));

final xpProvider = FutureProvider<XpModel>(
    (ref) => ref.read(achievementDsProvider).getXp());

final streakProvider = FutureProvider<StreakModel>(
    (ref) => ref.read(achievementDsProvider).getStreak());

final userBadgesProvider = FutureProvider<List<BadgeModel>>(
    (ref) => ref.read(achievementDsProvider).getUserBadges());

final allBadgesProvider = FutureProvider<List<BadgeModel>>(
    (ref) => ref.read(achievementDsProvider).getAllBadges());

final learningReportProvider = FutureProvider<LearningReportModel>(
    (ref) => ref.read(achievementDsProvider).getLearningReport());