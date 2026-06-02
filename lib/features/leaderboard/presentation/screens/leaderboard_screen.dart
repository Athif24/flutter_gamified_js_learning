import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/leaderboard_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
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

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _searchQuery = '';
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 2 && next == 2) {
        ref.invalidate(leaderboardProvider);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(leaderboardProvider);
    });
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(leaderboardProvider);
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final boardAsync = ref.watch(leaderboardProvider);
    final profileAsync = ref.watch(profileProvider);
    final myName = profileAsync.maybeWhen(
      data: (p) => p.name,
      orElse: () => null,
    );
    final myAvatar = profileAsync.maybeWhen(
      data: (p) => p.avatar,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
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
                    ref.invalidate(leaderboardProvider);
                  },
                ),
                data: (res) => _buildContent(t, res, myName, myAvatar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BloomTheme t,
    LeaderboardResponse res,
    String? myName,
    String? myAvatar,
  ) {
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

    final childWidgets = <Widget>[
      HeaderCard(t: t).animate().fadeIn(),
      SizedBox(height: S.scale(context, 16)),
      if (currentUserRank != null && currentUserXp != null) ...[
        UserRankCard(
          t: t,
          rank: currentUserRank,
          xp: currentUserXp,
        ).animate().fadeIn(delay: 100.ms),
        SizedBox(height: S.scale(context, 16)),
      ],
      if (entries.length >= 3) ...[
        Podium(
          t: t,
          entries: entries.take(3).toList(),
        ).animate().fadeIn(delay: 180.ms),
        SizedBox(height: S.scale(context, 16)),
      ],
      SearchCard(
        t: t,
        onChanged: _onSearchChanged,
      ).animate().fadeIn(delay: 250.ms),
      SizedBox(height: S.scale(context, 16)),
      LeaderboardTable(
        t: t,
        entries: filtered,
        isSearchActive: _searchQuery.isNotEmpty,
        currentUserRank: currentUserRank,
        currentUserXp: currentUserXp,
        currentUserName: myName,
        currentUserAvatar: myAvatar,
        topXp: topXp,
      ).animate().fadeIn(delay: 300.ms),
      SizedBox(height: S.scale(context, 16)),
      if (entries.isNotEmpty)
        FooterStats(
          t: t,
          total: entries.length,
          topXp: topXp,
          myRank: currentUserRank,
        ).animate().fadeIn(delay: 350.ms),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(leaderboardProvider);
        await ref.read(leaderboardProvider.future);
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          S.scale(context, 20),
          S.scale(context, 20),
          S.scale(context, 20),
          S.scale(context, 32),
        ),
        itemCount: childWidgets.length,
        itemBuilder: (_, i) => childWidgets[i],
      ),
    );
  }
}