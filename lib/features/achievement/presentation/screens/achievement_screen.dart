import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../data/models/achievement_model.dart';

import '../widgets/level_roadmap.dart';
import '../widgets/xp_history_list.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
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
      },
      fetchState: fetchState,
    );
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
        _silentRefresh();
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
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Hero progress card ───────────────────────────────────
                            xpAsync.when(
                              loading: () => _HeroCardSkeleton(t: t),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (xp) => _HeroCard(
                                t: t,
                                xp: xp,
                                streak: streakAsync.valueOrNull,
                                lives: livesAsync.valueOrNull,
                                name: name,
                              ).animate().fadeIn(),
                            ),

                            const SizedBox(height: 16),

                            // ── Stats row ────────────────────────────────────────────
                            xpAsync.when(
                              loading: () => _StatsRowSkeleton(t: t),
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
                                  _StatCard(
                                    t: t,
                                    icon: Icons.bolt_rounded,
                                    value: formatNumber(xp.totalXp),
                                    label: 'TOTAL XP',
                                    subtitle: 'experience points',
                                    color: t.warning,
                                  ),
                                  _StatCard(
                                    t: t,
                                    icon: Icons.local_fire_department_rounded,
                                    value: '${s?.currentStreak ?? 0} hari',
                                    subtitle:
                                        'Terpanjang: ${s?.longestStreak ?? 0} hari',
                                    label: 'STREAK SEKARANG',
                                    color: Colors.orange,
                                  ),
                                  _StatCard(
                                    t: t,
                                    icon: Icons.workspace_premium_rounded,
                                    value: '$earnedBadges/$totalBadges',
                                    subtitle: badgePct,
                                    label: 'BADGE DIRAIH',
                                    color: Colors.purple,
                                  ),
                                  _StatCard(
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
                                        12 * (crossAxisCount - 1);
                                    final childWidth =
                                        (constraints.maxWidth - totalGutter) /
                                        crossAxisCount;
                                    return Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: items
                                          .map(
                                            (item) => SizedBox(
                                              width: childWidth,
                                              child: item,
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                ).animate().fadeIn(delay: 100.ms);
                              },
                            ),

                            const SizedBox(height: 16),

                            // ── Koleksi Badge ────────────────────────────────────────
                            _BadgeCollection(
                              t: t,
                              badgesAsync: badgesAsync,
                            ).animate().fadeIn(delay: 200.ms),

                            const SizedBox(height: 16),

                            // ── Level Roadmap + Riwayat XP (two-column) ──────────────
                            xpAsync.when(
                              loading: () => _LevelSkeleton(t: t),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (xp) => levelsAsync.when(
                                loading: () => _LevelSkeleton(t: t),
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
                                            const SizedBox(width: 16),
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
                                            const SizedBox(height: 16),
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

// ── Shimmer skeleton widgets ──────────────────────────────────────────────────

class _HeroCardSkeleton extends StatelessWidget {
  final BloomTheme t;
  const _HeroCardSkeleton({required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: t.textPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        const SizedBox(height: 8),
        Container(
              width: 160,
              height: 28,
              decoration: BoxDecoration(
                color: t.bgSurface3,
                borderRadius: BorderRadius.circular(4),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        const SizedBox(height: 16),
        Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: t.bgSurface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.textPrimary, width: 2),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) =>
                Container(
                      width: 80,
                      height: 70,
                      decoration: BoxDecoration(
                        color: t.bgSurface3,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.textPrimary, width: 2),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      ],
    ),
  );
}

class _StatsRowSkeleton extends StatelessWidget {
  final BloomTheme t;
  const _StatsRowSkeleton({required this.t});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
      final totalGutter = 12 * (crossAxisCount - 1);
      final childWidth = (constraints.maxWidth - totalGutter) / crossAxisCount;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: childWidth,
            child:
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: t.textPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 60,
                            height: 11,
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 20,
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 70,
                            height: 11,
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      );
    },
  );
}

class _LevelSkeleton extends StatelessWidget {
  final BloomTheme t;
  const _LevelSkeleton({required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: t.textPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        const SizedBox(height: 20),
        ...List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
            child:
                Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.bgSurface3,
                            border: Border.all(color: t.textPrimary, width: 2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: t.bgSurface3.withAlpha(50),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: t.textPrimary,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      ],
    ),
  );
}

class _BadgeGridSkeleton extends StatelessWidget {
  final BloomTheme t;
  const _BadgeGridSkeleton({required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: t.textPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child:
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.bgSurface3.withAlpha(50),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: t.textPrimary, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 13,
                              decoration: BoxDecoration(
                                color: t.bgSurface3,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 13,
                              decoration: BoxDecoration(
                                color: t.bgSurface3,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 1200.ms, color: t.bgSurface3),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (_, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            final totalGutter = 12 * (crossAxisCount - 1);
            final childWidth =
                (constraints.maxWidth - totalGutter) / crossAxisCount;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                crossAxisCount,
                (_) => SizedBox(
                  width: childWidth,
                  child:
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: t.bgSurface3.withAlpha(50),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: t.textPrimary,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: t.textPrimary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 60,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 1200.ms, color: t.bgSurface3),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final BloomTheme t;
  final XpModel xp;
  final StreakModel? streak;
  final LivesModel? lives;
  final String name;
  const _HeroCard({
    required this.t,
    required this.xp,
    this.streak,
    this.lives,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(rs(24)),
        decoration: BoxDecoration(
          color: t.primary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Progress Kamu',
                  style: GoogleFonts.nunito(
                    color: t.primaryContent.withValues(alpha: 0.8),
                    fontSize: rs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs(8),
                    vertical: rs(4),
                  ),
                  decoration: BoxDecoration(
                    color: t.primaryContent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: t.textPrimary, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        color: t.primaryContent,
                        size: rs(12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        xp.levelTitle,
                        style: GoogleFonts.nunito(
                          color: t.primaryContent,
                          fontWeight: FontWeight.w800,
                          fontSize: rs(11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: GoogleFonts.nunito(
                  color: t.primaryContent,
                  fontSize: rs(24),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // XP bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: t.primaryContent.withValues(alpha: 0.8),
                      size: rs(16),
                    ),
                    const SizedBox(width: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${formatNumber(xp.totalXp)} XP',
                        style: GoogleFonts.nunito(
                          color: t.primaryContent.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w800,
                          fontSize: rs(14),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          xp.nextLevelTitle != null
                              ? '${formatNumber(xp.xpToNextLevel)} XP lagi menuju ${xp.nextLevelTitle}'
                              : 'Max level!',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: rs(12),
                          ),
                        ),
                      ),
                    ),
                    if (xp.nextLevelTitle != null)
                      Padding(
                        padding: EdgeInsets.only(left: rs(4)),
                        child: Icon(
                          Icons.chevron_right,
                          color: t.primaryContent.withValues(alpha: 0.8),
                          size: rs(14),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: rs(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.border.withAlpha(120), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: t.border.withAlpha(75),
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: xp.progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: t.bgSurface3,
                    valueColor: AlwaysStoppedAnimation(t.primary),
                    minHeight: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  xp.levelTitle,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent.withValues(alpha: 0.8),
                    fontSize: rs(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (xp.nextLevelTitle != null)
                  Text(
                    xp.nextLevelTitle!,
                    style: GoogleFonts.nunito(
                      color: t.primaryContent.withValues(alpha: 0.8),
                      fontSize: rs(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rs(12), horizontal: rs(16)),
              decoration: BoxDecoration(
                color: t.bgSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: t.textPrimary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: rs(32),
                          height: rs(32),
                          decoration: BoxDecoration(
                            color: t.warning.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.warning.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: t.warning,
                              size: rs(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${streak?.currentStreak ?? 0}',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontSize: rs(18),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'HARI STREAK',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: rs(10),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: rs(1),
                    height: rs(40),
                    color: t.textPrimary.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: rs(32),
                          height: rs(32),
                          decoration: BoxDecoration(
                            color: t.info.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.info.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.diamond_rounded,
                              color: t.info,
                              size: rs(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatNumber(xp.jewels),
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontSize: rs(18),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'JEWELS',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: rs(10),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: rs(1),
                    height: rs(40),
                    color: t.textPrimary.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: rs(32),
                          height: rs(32),
                          decoration: BoxDecoration(
                            color: t.error.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.error.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              color: t.error,
                              size: rs(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${lives?.current ?? 0}',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontSize: rs(18),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'LIVES',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: rs(10),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final String? subtitle;
  final Color color;
  const _StatCard({
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
    padding: EdgeInsets.all(rs(16)),
    decoration: BoxDecoration(
      color: Color.alphaBlend(color.withValues(alpha: 0.08), t.bgSurface),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.textPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: rs(40),
          height: rs(40),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Center(child: Icon(icon, color: color, size: rs(20))),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontSize: rs(11),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontSize: rs(20),
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              subtitle!,
              style: GoogleFonts.nunito(
                color: t.textPrimary.withValues(alpha: 0.5),
                fontSize: rs(11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    ),
  );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final IconData icon;
  final String? count;
  const _SectionHeader({
    required this.t,
    required this.title,
    required this.icon,
    this.count,
  });
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Row(
    children: [
      Icon(icon, color: t.warning, size: rs(20)),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.nunito(
          color: t.textPrimary,
          fontSize: rs(16),
          fontWeight: FontWeight.w800,
        ),
      ),
      if (count != null) ...[
        const Spacer(),
        Text(
          count!,
          style: GoogleFonts.nunito(
            color: t.textSecondary,
            fontSize: rs(13),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ],
  );
  }
}

class _BadgeCollection extends ConsumerStatefulWidget {
  final BloomTheme t;
  final AsyncValue<List<BadgeModel>> badgesAsync;
  const _BadgeCollection({required this.t, required this.badgesAsync});

  @override
  ConsumerState<_BadgeCollection> createState() => _BadgeCollectionState();
}

class _BadgeCollectionState extends ConsumerState<_BadgeCollection> {
  String _activeTab = 'all';

  static const _conditionIcons = {
    'streak': Icons.local_fire_department_rounded,
    'xp': Icons.bolt_rounded,
    'lesson_completion': Icons.menu_book_rounded,
    'event': Icons.event_rounded,
  };

  static const _conditionLabels = {
    'streak': 'Streak',
    'xp': 'XP',
    'lesson_completion': 'Pelajaran',
    'event': 'Event',
  };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    final t = widget.t;
    return widget.badgesAsync.when(
      loading: () => _BadgeGridSkeleton(t: t),
      error: (e, _) => const SizedBox.shrink(),
      data: (badges) {
        if (badges.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                t: t,
                title: 'Koleksi Badge',
                icon: Icons.workspace_premium_rounded,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                  padding: EdgeInsets.all(rs(24)),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.textPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: t.textPrimary,
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text('🏅', style: TextStyle(fontSize: rs(36))),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada badge',
                          style: GoogleFonts.nunito(
                            color: t.textSecondary,
                            fontSize: rs(13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        final earnedCount = badges.where((b) => b.isEarned).length;
        final lockedCount = badges.length - earnedCount;

        final filtered = badges.where((b) {
          if (_activeTab == 'earned') return b.isEarned;
          if (_activeTab == 'locked') return !b.isEarned;
          return true;
        }).toList();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(rs(20)),
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.textPrimary, width: 2),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                t: t,
                title: 'Koleksi Badge',
                icon: Icons.workspace_premium_rounded,
                count: '$earnedCount/${badges.length}',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: rs(34),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterTab(
                      label: 'Semua',
                      count: badges.length,
                      isActive: _activeTab == 'all',
                      onTap: () => setState(() => _activeTab = 'all'),
                      t: t,
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      label: 'Diraih',
                      count: earnedCount,
                      isActive: _activeTab == 'earned',
                      onTap: () => setState(() => _activeTab = 'earned'),
                      t: t,
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      label: 'Terkunci',
                      count: lockedCount,
                      isActive: _activeTab == 'locked',
                      onTap: () => setState(() => _activeTab = 'locked'),
                      t: t,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: rs(2),
                decoration: BoxDecoration(
                  color: t.textPrimary.withAlpha(80),
                  boxShadow: [
                    BoxShadow(
                      color: t.textPrimary,
                      offset: const Offset(0, 1),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: rs(32)),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: rs(40),
                        color: t.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _activeTab == 'earned'
                            ? 'Belum ada badge yang diraih'
                            : 'Semua badge sudah diraih!',
                        style: GoogleFonts.nunito(
                          color: t.textSecondary,
                          fontSize: rs(13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (_, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800
                        ? 5
                        : constraints.maxWidth > 600
                        ? 4
                        : constraints.maxWidth > 400
                        ? 3
                        : 2;
                    final totalGutter = 12 * (crossAxisCount - 1);
                    final childWidth =
                        (constraints.maxWidth - totalGutter) / crossAxisCount;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filtered
                          .map(
                            (b) => SizedBox(
                              width: childWidth,
                              child: _buildBadgeCard(t, b, w),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(BloomTheme t, BadgeModel b, double screenW) {
    final rs = (double px) => px * (screenW / 390).clamp(0.8, 1.3);
    final earned = b.isEarned;
    final condIcon = _conditionIcons[b.conditionType];
    final condLabel = _conditionLabels[b.conditionType];

    final cardBody = Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: earned ? t.bgSurface : t.bgSurface2.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.textPrimary, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rs(56),
            height: rs(56),
            decoration: BoxDecoration(
              color: earned ? t.warning.withAlpha(25) : t.bgSurface3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.textPrimary, width: 2),
            ),
            child: Semantics(
              label:
                  '${b.name} - ${earned ? "Sudah didapat" : "Belum didapat"}',
              child: Center(
                child: b.icon.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: b.icon,
                        width: rs(36),
                        height: rs(36),
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Icon(
                          Icons.emoji_events_rounded,
                          size: rs(24),
                          color: earned ? t.warning : t.textHint,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.emoji_events_rounded,
                          size: rs(24),
                          color: earned ? t.warning : t.textHint,
                        ),
                      )
                    : Text(b.icon, style: TextStyle(fontSize: rs(24))),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              b.name,
              style: GoogleFonts.nunito(
                fontSize: rs(14),
                fontWeight: FontWeight.w800,
                color: earned ? t.textPrimary : t.textHint,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (b.description != null && b.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                b.description!,
                style: GoogleFonts.nunito(fontSize: rs(11), color: t.textHint),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (condIcon != null && b.conditionValue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(6), vertical: rs(2)),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: t.border.withAlpha(50), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(condIcon, size: rs(10), color: t.textSecondary),
                  const SizedBox(width: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$condLabel: ${b.conditionValue}',
                      style: GoogleFonts.nunito(
                        fontSize: rs(10),
                        color: t.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (b.rewardJewels > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_rounded, size: rs(10), color: t.info),
                const SizedBox(width: 2),
                Text(
                  '+${b.rewardJewels} jewels',
                  style: GoogleFonts.nunito(
                    fontSize: rs(11),
                    color: t.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          if (earned && b.earnedAt != null) ...[
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Diraih ${_formatDate(b.earnedAt)}',
                style: GoogleFonts.nunito(fontSize: rs(10), color: t.textHint),
              ),
            ),
          ],
        ],
      ),
    );

    final card = Stack(
      clipBehavior: Clip.none,
      children: [
        cardBody,
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              width: rs(24),
              height: rs(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earned ? t.success : t.bgSurface3,
                border: Border.all(color: t.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: t.border,
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: earned
                    ? Icon(Icons.check_rounded, color: t.accentText, size: rs(13))
                    : Icon(Icons.lock_rounded, color: t.textHint, size: rs(14)),
              ),
            ),
          ),
      ],
    );

    if (!earned) {
      return Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: card,
        ),
      );
    }
    return card;
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final BloomTheme t;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Bounceable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? t.accent : t.bgSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              color: isActive ? t.accentText : t.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isActive ? t.accentText.withAlpha(30) : t.bgSurface2,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.nunito(
                color: isActive ? t.accentText : t.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}