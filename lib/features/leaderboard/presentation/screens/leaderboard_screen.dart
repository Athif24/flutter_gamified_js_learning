import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_skeleton.dart';
import '../widgets/leaderboard_header_card.dart';
import '../widgets/leaderboard_user_rank_card.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_search_card.dart';
import '../widgets/leaderboard_table.dart';
import '../widgets/leaderboard_footer_stats.dart';
import '../../data/models/leaderboard_model.dart';
import '../../../../shared/services/sound_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SilentRefreshMixin<LeaderboardScreen> {
  String _searchQuery = '';
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && ref.read(leaderboardProvider).hasValue) {
        ref.invalidate(leaderboardProvider);
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(leaderboardFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(leaderboardProvider);
        await ref.read(leaderboardProvider.future);
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 2 && next == 2) {
        ref.invalidate(leaderboardProvider);
        _silentRefresh();
      }
    });

    final t = ref.watch(currentThemeProvider);
    final boardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: boardAsync.when(
                loading: () => LeaderboardSkeleton(t: t),
                error: (e, _) => ErrorBody(
                  t: t,
                  icon: iconForError(e),
                  title: AppStrings.errLoadLeaderboardDetail,
                  message: sanitizeErrorMessage(e),
                  onRetry: () {
                    ref.read(soundProvider).playClick();
                    setShowSlowIndicator(true);
                    _silentRefresh();
                  },
                ),
                data: (res) => _buildContent(t, res),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BloomTheme t, LeaderboardResponse res) {
    final entries = res.leaderboard;
    final currentUserRank = res.currentUserRank;
    final currentUserXp = res.currentUserXp;
    final topXp = entries.isNotEmpty ? entries[0].xpTotal : 0;
    final filtered = _searchQuery.isEmpty
        ? entries
        : entries
              .where(
                (e) =>
                    e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _silentRefresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          HeaderCard(
            t: t,
            currentUserRank: currentUserRank,
            currentUserXp: currentUserXp,
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          if (currentUserRank != null && currentUserXp != null)
            UserRankCard(
              t: t,
              rank: currentUserRank,
              xp: currentUserXp,
            ).animate().fadeIn(delay: 100.ms),

          if (currentUserRank != null && currentUserXp != null)
            const SizedBox(height: 16),

          if (entries.length >= 3)
            Podium(
              t: t,
              entries: entries.take(3).toList(),
            ).animate().fadeIn(delay: 180.ms),

          if (entries.length >= 3) const SizedBox(height: 16),

          SearchCard(
            t: t,
            onChanged: (v) => setState(() => _searchQuery = v),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          LeaderboardTable(
            t: t,
            entries: filtered,
            isSearchActive: _searchQuery.isNotEmpty,
            currentUserRank: currentUserRank,
            topXp: topXp,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          if (entries.isNotEmpty)
            FooterStats(
              t: t,
              total: entries.length,
              topXp: topXp,
              myRank: currentUserRank,
            ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}
