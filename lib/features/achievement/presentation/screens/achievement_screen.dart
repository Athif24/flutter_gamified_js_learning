import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/level_roadmap.dart';
import '../widgets/xp_history_list.dart';
import '../widgets/achievement_skeletons.dart';
import '../widgets/hero_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/badge_collection.dart';
import '../../../../shared/services/sound_service.dart';

class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({super.key});

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen>
    with SilentRefreshMixin<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_silentRefresh()));
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(achievementFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(xpProvider);
        ref.invalidate(streakProvider);
        ref.invalidate(mergedBadgesProvider);
        ref.invalidate(livesProvider);
        ref.invalidate(levelsProvider);
        ref.invalidate(xpHistoryProvider);
        await ref.read(xpProvider.future);
        await ref.read(streakProvider.future);
        await ref.read(mergedBadgesProvider.future);
        await ref.read(livesProvider.future);
        await ref.read(levelsProvider.future);
      },
      fetchState: fetchState,
    );
  }

  List<Widget> _wrapStatItems(List<StatCard> items, double childWidth) {
    return items
        .map((item) => SizedBox(width: childWidth, child: item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 1 && next == 1) {
        ref.invalidate(xpProvider);
        ref.invalidate(streakProvider);
        ref.invalidate(mergedBadgesProvider);
        ref.invalidate(livesProvider);
        ref.invalidate(levelsProvider);
        ref.invalidate(xpHistoryProvider);
        unawaited(_silentRefresh());
      }
    });

    ref.listen<String?>(xpHistoryProvider.select((s) => s.error), (_, err) {
      if (err != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              err,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: ref.read(currentThemeProvider).error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
            ),
          ),
        );
      }
    });

    final t = ref.watch(currentThemeProvider);
    final auth = ref.watch(authProvider);
    final xpAsync = ref.watch(xpProvider);
    final streakAsync = ref.watch(streakProvider);
    final badgesAsync = ref.watch(mergedBadgesProvider);
    final livesAsync = ref.watch(livesProvider);
    final levelsAsync = ref.watch(levelsProvider);
    final xpHistoryState = ref.watch(xpHistoryProvider);
    final name = auth.user?.name ?? 'Mahasiswa';
    final hasError =
        xpAsync.hasError || levelsAsync.hasError || badgesAsync.hasError;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: hasError
                  ? ErrorBody(
                      t: t,
                      title: AppStrings.errLoadAchievementDetail,
                      onRetry: () {
                        ref.read(soundProvider).playClick();
                        setShowSlowIndicator(true);
                        _silentRefresh();
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _silentRefresh();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          S.scale(context, 20),
                          S.scale(context, 20),
                          S.scale(context, 20),
                          S.scale(context, 40),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            xpAsync.when(
                              loading: () => HeroCardSkeleton(t: t),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (xp) => HeroCard(
                                t: t,
                                xp: xp,
                                streak: streakAsync.valueOrNull,
                                lives: livesAsync.valueOrNull,
                                name: name,
                              ).animate().fadeIn(),
                            ),

                            SizedBox(height: S.scale(context, 16)),

                            xpAsync.when(
                              loading: () => StatsRowSkeleton(t: t),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (xp) {
                                final s = streakAsync.valueOrNull;
                                final earnedBadges =
                                    badgesAsync.valueOrNull
                                        ?.where((b) => b.isEarned)
                                        .length ??
                                    0;
                                final totalBadges =
                                    badgesAsync.valueOrNull?.length ?? 0;
                                final badgePct = totalBadges > 0
                                    ? '${(earnedBadges / totalBadges * 100).toInt()}% selesai'
                                    : 'Ayo kerjain quiz!';
                                final items = [
                                  StatCard(
                                    t: t,
                                    icon: Icons.bolt_rounded,
                                    value: formatNumber(xp.totalXp),
                                    label: 'TOTAL XP',
                                    subtitle: 'experience points',
                                    color: t.warning,
                                  ),
                                  StatCard(
                                    t: t,
                                    icon: Icons.local_fire_department_rounded,
                                    value: '${s?.currentStreak ?? 0} hari',
                                    subtitle:
                                        'Terpanjang: ${s?.longestStreak ?? 0} hari',
                                    label: 'STREAK SEKARANG',
                                    color: t.warning,
                                  ),
                                  StatCard(
                                    t: t,
                                    icon: Icons.workspace_premium_rounded,
                                    value: '$earnedBadges/$totalBadges',
                                    subtitle: badgePct,
                                    label: 'BADGE DIRAIH',
                                    color: Colors.purple,
                                  ),
                                  StatCard(
                                    t: t,
                                    icon: xp.nextLevelTitle != null
                                        ? Icons.arrow_upward_rounded
                                        : Icons.trending_up_rounded,
                                    value: xp.nextLevelTitle != null
                                        ? '${formatNumber(xp.xpToNextLevel)} XP'
                                        : 'MAX!',
                                    subtitle: xp.nextLevelTitle != null
                                        ? 'Menuju ${xp.nextLevelTitle}'
                                        : 'Level tertinggi tercapai',
                                    label: 'LEVEL BERIKUTNYA',
                                    color: t.success,
                                  ),
                                ];
                                return LayoutBuilder(
                                  builder: (_, constraints) {
                                    final crossAxisCount =
                                        constraints.maxWidth > 600 ? 4 : 2;
                                    final totalGutter =
                                        S.scale(context, 12) * (crossAxisCount - 1);
                                    final childWidth =
                                        (constraints.maxWidth - totalGutter) /
                                        crossAxisCount;
                                    return Wrap(
                                      spacing: S.scale(context, 12),
                                      runSpacing: S.scale(context, 12),
                                      children: _wrapStatItems(items, childWidth),
                                    );
                                  },
                                ).animate().fadeIn(delay: 100.ms);
                              },
                            ),

                            SizedBox(height: S.scale(context, 16)),

                            BadgeCollection(
                              t: t,
                              badgesAsync: badgesAsync,
                            ).animate().fadeIn(delay: 200.ms),

                            SizedBox(height: S.scale(context, 16)),

                            xpAsync.when(
                              loading: () => LevelSkeleton(t: t),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (xp) => levelsAsync.when(
                                loading: () => LevelSkeleton(t: t),
                                error: (e, _) => const SizedBox.shrink(),
                                data: (levels) => LayoutBuilder(
                                  builder: (_, constraints) =>
                                      constraints.maxWidth > 600
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: LevelRoadmap(
                                                levels: levels,
                                                xpTotal: xp.totalXp,
                                              ),
                                            ),
                                            SizedBox(width: S.scale(context, 16)),
                                            Expanded(
                                              child: XpHistoryList(
                                                entries: xpHistoryState.entries,
                                                isLoading:
                                                    xpHistoryState.isLoading,
                                                isLoadingMore: xpHistoryState
                                                    .isLoadingMore,
                                                hasMore: xpHistoryState.hasMore,
                                                onLoadMore: () => ref
                                                    .read(
                                                      xpHistoryProvider
                                                          .notifier,
                                                    )
                                                    .loadMore(),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LevelRoadmap(
                                              levels: levels,
                                              xpTotal: xp.totalXp,
                                            ),
                                            SizedBox(height: S.scale(context, 16)),
                                            XpHistoryList(
                                              entries: xpHistoryState.entries,
                                              isLoading:
                                                  xpHistoryState.isLoading,
                                              isLoadingMore:
                                                  xpHistoryState.isLoadingMore,
                                              hasMore: xpHistoryState.hasMore,
                                              onLoadMore: () => ref
                                                  .read(
                                                    xpHistoryProvider.notifier,
                                                  )
                                                  .loadMore(),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}