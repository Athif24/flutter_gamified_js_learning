import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/datasources/achievement_remote_datasource.dart';
import '../../data/models/achievement_model.dart';

final achievementDsProvider = Provider(
  (ref) => AchievementRemoteDatasource(ref.read(apiClientProvider)),
);

final xpProvider = FutureProvider<XpModel>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  final levels = await ref.watch(levelsProvider.future);
  final sorted = List<LevelModel>.from(levels)
    ..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));
  final currentIdx = sorted.lastIndexWhere(
    (l) => l.requiredXp <= profile.xpTotal,
  );
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
  (ref) => ref.read(achievementDsProvider).getStreak(),
);

final userBadgesProvider = FutureProvider<List<BadgeModel>>(
  (ref) => ref.read(achievementDsProvider).getUserBadges(),
);

final allBadgesProvider = FutureProvider<List<BadgeModel>>(
  (ref) => ref.read(achievementDsProvider).getAllBadges(),
);

final mergedBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final ds = ref.read(achievementDsProvider);
  final [allBadges, userBadges] = await Future.wait([
    ds.getAllBadges(),
    ds.getUserBadges(),
  ]);
  final earnedIds = userBadges.map((ub) => ub.badgeId ?? ub.id).toSet();
  return allBadges.map((badge) {
    final earned = userBadges
        .where((ub) => (ub.badgeId ?? ub.id) == badge.id)
        .firstOrNull;
    return BadgeModel(
      id: badge.id,
      badgeId: badge.badgeId,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      isEarned: earnedIds.contains(badge.id),
      earnedAt: earned?.earnedAt,
      requiredValue: badge.requiredValue,
      conditionType: badge.conditionType,
      conditionValue: badge.conditionValue,
      rewardJewels: badge.rewardJewels,
    );
  }).toList();
});

class XpHistoryState {
  final List<XpHistoryEntry> entries;
  final String? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const XpHistoryState({
    this.entries = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  XpHistoryState copyWith({
    List<XpHistoryEntry>? entries,
    String? cursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) => XpHistoryState(
    entries: entries ?? this.entries,
    cursor: cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error ?? this.error,
  );
}

class XpHistoryNotifier extends StateNotifier<XpHistoryState> {
  final AchievementRemoteDatasource _ds;
  XpHistoryNotifier(this._ds) : super(const XpHistoryState());

  Future<void> fetchInitial() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _ds.getXpHistory();
      if (!mounted) return;
      state = XpHistoryState(
        entries: result.data,
        cursor: result.cursor,
        hasMore: result.hasMore,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: 'Gagal memuat riwayat XP');
    }
  }

  Future<void> loadMore() async {
    if (!mounted) return;
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _ds.getXpHistory(cursor: state.cursor);
      if (!mounted) return;
      state = XpHistoryState(
        entries: [...state.entries, ...result.data],
        cursor: result.cursor,
        hasMore: result.hasMore,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false, error: 'Gagal memuat riwayat XP');
    }
  }
}

final xpHistoryProvider =
    StateNotifierProvider<XpHistoryNotifier, XpHistoryState>((ref) {
      final notifier = XpHistoryNotifier(ref.read(achievementDsProvider));
      Future.microtask(() => notifier.fetchInitial());
      return notifier;
    });

final levelsProvider = FutureProvider<List<LevelModel>>(
  (ref) => ref.read(achievementDsProvider).getLevels(),
);

final livesProvider = FutureProvider<LivesModel>((ref) async {
  try {
    final ds = ref.read(profileDsProvider);
    return await ds.getEffectiveLives();
  } catch (_) {
    final profile = await ref.watch(profileProvider.future);
    return LivesModel(current: profile.lifes, max: profile.maxLives);
  }
});