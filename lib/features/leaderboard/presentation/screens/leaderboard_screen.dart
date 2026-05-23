import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_skeleton.dart';
import '../../data/models/leaderboard_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

String _fmtCompact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════

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
        ref.read(leaderboardPageProvider.notifier).state = 1;
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
                error: (e, _) => _buildError(t, e),
                data: (res) => _buildContent(t, res),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ──────────────────────────────────────────────────────────

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
        ref.read(leaderboardPageProvider.notifier).state = 1;
        await _silentRefresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // ── Header Card ──────────────────────────────────────────────
          _HeaderCard(
            t: t,
            currentUserRank: currentUserRank,
            currentUserXp: currentUserXp,
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // ── User Rank Card ───────────────────────────────────────────
          if (currentUserRank != null && currentUserXp != null)
            _UserRankCard(
              t: t,
              rank: currentUserRank,
              xp: currentUserXp,
            ).animate().fadeIn(delay: 100.ms),

          if (currentUserRank != null && currentUserXp != null)
            const SizedBox(height: 16),

          // ── Podium ────────────────────────────────────────────────────
          if (entries.length >= 3)
            _Podium(
              t: t,
              entries: entries.take(3).toList(),
            ).animate().fadeIn(delay: 180.ms),

          if (entries.length >= 3) const SizedBox(height: 16),

          // ── Search ────────────────────────────────────────────────────
          _SearchCard(
            t: t,
            onChanged: (v) => setState(() => _searchQuery = v),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          // ── Table ────────────────────────────────────────────────────
          _LeaderboardTable(
            t: t,
            entries: filtered,
            isSearchActive: _searchQuery.isNotEmpty,
            currentUserRank: currentUserRank,
            topXp: topXp,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // ── Footer Stats ─────────────────────────────────────────────
          if (entries.isNotEmpty)
            _FooterStats(
              t: t,
              total: entries.length,
              topXp: topXp,
              myRank: currentUserRank,
            ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────

  Widget _buildError(BloomTheme t, Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: t.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.errLoadLeaderboardDetail,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Coba lagi',
                  child: Bounceable(
                    onTap: () {
                      setShowSlowIndicator(true);
                      _silentRefresh();
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        AppStrings.retry,
                        style: GoogleFonts.nunito(
                          color: t.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HEADER CARD
// ════════════════════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  final BloomTheme t;
  final int? currentUserRank;
  final int? currentUserXp;
  const _HeaderCard({
    required this.t,
    this.currentUserRank,
    this.currentUserXp,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Header Leaderboard',
      child: Container(
        padding: const EdgeInsets.all(16),
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
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: t.primaryContent,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  'Leaderboard',
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Lihat peringkat Anda dan kompetisi dengan pemain lain',
              style: GoogleFonts.nunito(
                color: t.primaryContent.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// USER RANK CARD
// ════════════════════════════════════════════════════════════════════════════

class _UserRankCard extends StatelessWidget {
  final BloomTheme t;
  final int rank;
  final int xp;
  const _UserRankCard({required this.t, required this.rank, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Posisi Anda: ranking $rank, total XP $xp',
      child: Container(
        padding: const EdgeInsets.all(24),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posisi Anda',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Icon(
                      Icons.local_fire_department_rounded,
                      size: 24,
                      color: t.warning,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.15, 1.15),
                      duration: 1000.ms,
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RANKING',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '#$rank',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _RankBadgeSmall(rank: rank, t: t),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL XP',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formatNumber(xp),
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'XP',
                            style: GoogleFonts.nunito(
                              color: t.mutedText,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// RANK BADGE (small, for user card & table)
// ════════════════════════════════════════════════════════════════════════════

class _RankBadgeSmall extends StatelessWidget {
  final int rank;
  final BloomTheme t;
  const _RankBadgeSmall({required this.rank, required this.t});

  Color get _bg {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return t.bgSurface2;
  }

  Color get _fg {
    if (rank == 1) return const Color(0xFF78350F);
    if (rank == 2) return const Color(0xFF475569);
    if (rank == 3) return const Color(0xFF7C2D12);
    return t.textPrimary;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1) const Text('🥇', style: TextStyle(fontSize: 12)),
        if (rank == 2) const Text('🥈', style: TextStyle(fontSize: 12)),
        if (rank == 3) const Text('🥉', style: TextStyle(fontSize: 12)),
        if (rank <= 3) const SizedBox(width: 3),
        Text(
          '$rank',
          style: GoogleFonts.nunito(
            color: _fg,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// PODIUM
// ════════════════════════════════════════════════════════════════════════════

class _Podium extends StatelessWidget {
  final BloomTheme t;
  final List<LeaderboardEntry> entries;
  const _Podium({required this.t, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();
    return Semantics(
      label: 'Top 3 pemain terbaik',
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 22, color: t.warning),
              const SizedBox(width: 8),
              Text(
                'Top 3 Pemain Terbaik',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumUser(entry: entries[1], rank: 2, t: t, baseH: 48),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PodiumUser(entry: entries[0], rank: 1, t: t, baseH: 80),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PodiumUser(entry: entries[2], rank: 3, t: t, baseH: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumUser extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final BloomTheme t;
  final double baseH;
  const _PodiumUser({
    required this.entry,
    required this.rank,
    required this.t,
    required this.baseH,
  });

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8);
    return const Color(0xFFCD7F32);
  }

  String _initial() =>
      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (rank == 1)
        Icon(Icons.emoji_events_rounded, size: 28, color: t.warning),
      if (rank == 2) Icon(Icons.emoji_events_rounded, size: 24, color: t.info),
      if (rank == 3)
        Icon(Icons.emoji_events_rounded, size: 24, color: t.accent),
      const SizedBox(height: 8),
      // Avatar
      Container(
            width: rank == 1 ? 56 : 44,
            height: rank == 1 ? 56 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _color, width: rank == 1 ? 3 : 2),
              color: _color.withValues(alpha: 0.2),
            ),
            child: Center(
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: entry.avatar!,
                        width: rank == 1 ? 50 : 38,
                        height: rank == 1 ? 50 : 38,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? 20 : 16,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? 20 : 16,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _initial(),
                      style: GoogleFonts.nunito(
                        color: _color,
                        fontWeight: FontWeight.w900,
                        fontSize: rank == 1 ? 20 : 16,
                      ),
                    ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -4, duration: 1200.ms),
      const SizedBox(height: 8),
      Text(
        entry.name,
        style: GoogleFonts.nunito(
          color: t.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: rank == 1 ? 12 : 11,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 2),
      Text(
        '#${entry.rank}',
        style: GoogleFonts.nunito(
          color: _color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '${_fmtCompact(entry.xpTotal)} XP',
        style: GoogleFonts.nunito(
          color: t.mutedText,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
      if (entry.levelName != null)
        Text(
          entry.levelName!,
          style: GoogleFonts.nunito(
            color: t.mutedText.withValues(alpha: 0.7),
            fontSize: 9,
          ),
        ),
      const SizedBox(height: 4),
      // Podium base
      Container(
        height: baseH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color, _color.withValues(alpha: 0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
          border: Border.all(color: _color, width: 3),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: GoogleFonts.nunito(
              color: rank == 1
                  ? const Color(0xFF78350F)
                  : rank == 2
                  ? const Color(0xFF475569)
                  : const Color(0xFF7C2D12),
              fontWeight: FontWeight.w900,
              fontSize: rank == 1 ? 28 : 22,
            ),
          ),
        ),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════════════════════
// SEARCH CARD
// ════════════════════════════════════════════════════════════════════════════

class _SearchCard extends StatelessWidget {
  final BloomTheme t;
  final ValueChanged<String> onChanged;
  const _SearchCard({required this.t, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(18),
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
          Text(
            'Cari Pemain',
            style: GoogleFonts.nunito(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: t.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.3)),
            ),
            child: Semantics(
              label: 'Cari pemain',
              child: TextField(
                onChanged: onChanged,
                style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ketik nama pemain...',
                  hintStyle: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: t.mutedText,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LEADERBOARD TABLE
// ════════════════════════════════════════════════════════════════════════════

class _LeaderboardTable extends StatelessWidget {
  final BloomTheme t;
  final List<LeaderboardEntry> entries;
  final bool isSearchActive;
  final int? currentUserRank;
  final int topXp;
  const _LeaderboardTable({
    required this.t,
    required this.entries,
    this.isSearchActive = false,
    this.currentUserRank,
    required this.topXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 28, color: t.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard',
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Ranking pemain berdasarkan total XP',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty && !isSearchActive)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Belum ada data',
                style: GoogleFonts.nunito(color: t.mutedText, fontSize: 15),
              ),
            )
          else if (entries.isEmpty && isSearchActive)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Tidak ada pemain dengan nama tersebut',
                style: GoogleFonts.nunito(color: t.mutedText, fontSize: 15),
              ),
            )
          else
            LayoutBuilder(
              builder: (_, constraints) {
                final maxH = 650.0;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxH),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                              t.bgSurface2,
                            ),
                            columnSpacing: 20,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 60,
                            columns: [
                              DataColumn(
                                label: Text(
                                  '#',
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Pemain',
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Level',
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'XP',
                                  style: GoogleFonts.nunito(
                                    color: t.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                numeric: true,
                              ),
                            ],
                            rows: entries.map((e) {
                              final isMe = e.rank == currentUserRank;
                              return DataRow(
                                color: WidgetStatePropertyAll(
                                  isMe ? t.accent.withValues(alpha: 0.2) : null,
                                ),
                                cells: [
                                  DataCell(_RankBadgeSmall(rank: e.rank, t: t)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: t.bgSurface2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: t.textPrimary,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child:
                                                e.avatar != null &&
                                                    e.avatar!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          7,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: e.avatar!,
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                      placeholder: (_, __) => Text(
                                                        e.name.isNotEmpty
                                                            ? e.name[0]
                                                                  .toUpperCase()
                                                            : '?',
                                                        style:
                                                            GoogleFonts.nunito(
                                                              color:
                                                                  t.mutedText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                      errorWidget: (_, __, ___) => Text(
                                                        e.name.isNotEmpty
                                                            ? e.name[0]
                                                                  .toUpperCase()
                                                            : '?',
                                                        style:
                                                            GoogleFonts.nunito(
                                                              color:
                                                                  t.mutedText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    e.name.isNotEmpty
                                                        ? e.name[0]
                                                              .toUpperCase()
                                                        : '?',
                                                    style: GoogleFonts.nunito(
                                                      color: t.mutedText,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              e.name,
                                              style: GoogleFonts.nunito(
                                                color: isMe
                                                    ? t.primary
                                                    : t.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (isMe)
                                              Text(
                                                'Anda',
                                                style: GoogleFonts.nunito(
                                                  color: t.primary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    e.levelName != null
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: t.primary.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: t.textPrimary,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              e.levelName!,
                                              style: GoogleFonts.nunito(
                                                color: t.primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            '-',
                                            style: GoogleFonts.nunito(
                                              color: t.mutedText,
                                              fontSize: 12,
                                            ),
                                          ),
                                  ),
                                  DataCell(
                                    Text(
                                      _fmtCompact(e.xpTotal),
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                t.bgSurface.withValues(alpha: 0),
                                t.bgSurface.withValues(alpha: 0.9),
                                t.bgSurface,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                t.bgSurface.withValues(alpha: 0),
                                t.bgSurface.withValues(alpha: 0.9),
                                t.bgSurface,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FOOTER STATS
// ════════════════════════════════════════════════════════════════════════════

class _FooterStats extends StatelessWidget {
  final BloomTheme t;
  final int total;
  final int topXp;
  final int? myRank;
  const _FooterStats({
    required this.t,
    required this.total,
    required this.topXp,
    this.myRank,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Statistik: $total pemain, Top XP $topXp${myRank != null ? ', ranking anda $myRank' : ''}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(
              t: t,
              label: 'Total Pemain',
              value: formatNumber(total),
              color: t.primary,
            ),
            _StatItem(
              t: t,
              label: 'Top XP',
              value: formatNumber(topXp),
              color: t.success,
            ),
            if (myRank != null)
              _StatItem(
                t: t,
                label: 'Ranking Anda',
                value: '#$myRank',
                color: t.info,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.t,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
