import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_skeleton.dart';
import '../../data/models/leaderboard_model.dart';
import '../../../../shared/services/sound_service.dart';

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
        ref.invalidate(leaderboardProvider);
        _silentRefresh();
      }
    });

    final t = ref.watch(currentThemeProvider);
    final screenW = MediaQuery.of(context).size.width;
    final boardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: boardAsync.when(
                loading: () => LeaderboardSkeleton(t: t, screenW: screenW),
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
                data: (res) => _buildContent(t, res, screenW),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ──────────────────────────────────────────────────────────

  Widget _buildContent(BloomTheme t, LeaderboardResponse res, double screenW) {
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
          // ── Header Card ──────────────────────────────────────────────
          _HeaderCard(
            t: t,
            screenW: screenW,
            currentUserRank: currentUserRank,
            currentUserXp: currentUserXp,
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // ── User Rank Card ───────────────────────────────────────────
          if (currentUserRank != null && currentUserXp != null)
            _UserRankCard(
              t: t,
              screenW: screenW,
              rank: currentUserRank,
              xp: currentUserXp,
            ).animate().fadeIn(delay: 100.ms),

          if (currentUserRank != null && currentUserXp != null)
            const SizedBox(height: 16),

          // ── Podium ────────────────────────────────────────────────────
          if (entries.length >= 3)
            _Podium(
              t: t,
              screenW: screenW,
              entries: entries.take(3).toList(),
            ).animate().fadeIn(delay: 180.ms),

          if (entries.length >= 3) const SizedBox(height: 16),

          // ── Search ────────────────────────────────────────────────────
          _SearchCard(
            t: t,
            screenW: screenW,
            onChanged: (v) => setState(() => _searchQuery = v),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          // ── Table ────────────────────────────────────────────────────
          _LeaderboardTable(
            t: t,
            screenW: screenW,
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
              screenW: screenW,
              total: entries.length,
              topXp: topXp,
              myRank: currentUserRank,
            ).animate().fadeIn(delay: 350.ms),
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
  final double screenW;
  final int? currentUserRank;
  final int? currentUserXp;
  const _HeaderCard({
    required this.t,
    required this.screenW,
    this.currentUserRank,
    this.currentUserXp,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Semantics(
      label: 'Header Leaderboard',
      child: Container(
        padding: EdgeInsets.all(rs(16)),
        decoration: BoxDecoration(
          color: t.primary,
          borderRadius: BorderRadius.circular(rs(24)),
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
                  size: rs(32),
                ),
                SizedBox(width: rs(8)),
                Text(
                  'Leaderboard',
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: rs(24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(4)),
            Padding(
              padding: EdgeInsets.only(left: rs(4)),
              child: Text(
                'Lihat peringkat Anda dan kompetisi dengan pemain lain',
                style: GoogleFonts.nunito(
                  color: t.primaryContent.withValues(alpha: 0.8),
                  fontSize: rs(14),
                ),
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
  final double screenW;
  final int rank;
  final int xp;
  const _UserRankCard({required this.t, required this.screenW, required this.rank, required this.xp});

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Semantics(
      label: 'Posisi Anda: ranking $rank, total XP $xp',
      child: Container(
        padding: EdgeInsets.all(rs(24)),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(rs(24)),
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
                    fontSize: rs(18),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Icon(
                      Icons.local_fire_department_rounded,
                      size: rs(24),
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
            SizedBox(height: rs(16)),
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
                          fontSize: rs(10),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: rs(4)),
                      Row(
                        children: [
                          Text(
                            '#$rank',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: rs(36),
                            ),
                          ),
                          SizedBox(width: rs(8)),
                          _RankBadgeSmall(rank: rank, t: t, screenW: screenW),
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
                          fontSize: rs(10),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: rs(4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formatNumber(xp),
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: rs(36),
                            ),
                          ),
                          SizedBox(width: rs(4)),
                          Text(
                            'XP',
                            style: GoogleFonts.nunito(
                              color: t.mutedText,
                              fontWeight: FontWeight.w700,
                              fontSize: rs(12),
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
// RANK BADGE
// ════════════════════════════════════════════════════════════════════════════

class _RankBadgeSmall extends StatelessWidget {
  final int rank;
  final BloomTheme t;
  final double screenW;
  const _RankBadgeSmall({required this.rank, required this.t, required this.screenW});

  bool get _isTop3 => rank >= 1 && rank <= 3;

  Color get _bg {
    if (rank == 1) return const Color(0xFFFFD600);
    if (rank == 2) return const Color(0xFFC8C8C8);
    if (rank == 3) return const Color(0xFFFF7A00);
    return t.bgSurface2;
  }

  Color get _fg {
    if (rank == 1) return const Color(0xFF78350F);
    if (rank == 2) return const Color(0xFF475569);
    if (rank == 3) return const Color(0xFF7C2D12);
    return t.mutedText;
  }

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(4)),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(rs(6)),
        border: _isTop3
            ? Border.all(color: _fg.withValues(alpha: 0.3))
            : Border.all(color: t.border),
        boxShadow: _isTop3
            ? [BoxShadow(color: _bg, offset: const Offset(2, 2), blurRadius: 0)]
            : null,
      ),
      child: Text(
        '$rank',
        style: GoogleFonts.nunito(
          color: _fg,
          fontWeight: FontWeight.w900,
          fontSize: rs(12),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PODIUM
// ════════════════════════════════════════════════════════════════════════════

class _Podium extends StatelessWidget {
  final BloomTheme t;
  final double screenW;
  final List<LeaderboardEntry> entries;
  const _Podium({required this.t, required this.screenW, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Semantics(
      label: 'Top 3 pemain terbaik',
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: rs(22), color: t.warning),
              SizedBox(width: rs(8)),
              Text(
                'Top 3 Pemain Terbaik',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: rs(16),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: rs(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumUser(entry: entries[1], rank: 2, t: t, screenW: screenW, baseH: rs(48)),
              ),
              SizedBox(width: rs(8)),
              Expanded(
                child: _PodiumUser(entry: entries[0], rank: 1, t: t, screenW: screenW, baseH: rs(80)),
              ),
              SizedBox(width: rs(8)),
              Expanded(
                child: _PodiumUser(entry: entries[2], rank: 3, t: t, screenW: screenW, baseH: rs(40)),
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
  final double screenW;
  final double baseH;
  const _PodiumUser({
    required this.entry,
    required this.rank,
    required this.t,
    required this.screenW,
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
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Column(
    children: [
      if (rank == 1)
        Icon(Icons.emoji_events_rounded, size: rs(28), color: t.warning),
      if (rank == 2) Icon(Icons.emoji_events_rounded, size: rs(24), color: t.info),
      if (rank == 3)
        Icon(Icons.emoji_events_rounded, size: rs(24), color: t.accent),
      SizedBox(height: rs(8)),
      // Avatar
      Container(
            width: rank == 1 ? rs(56) : rs(44),
            height: rank == 1 ? rs(56) : rs(44),
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
                        width: rank == 1 ? rs(50) : rs(38),
                        height: rank == 1 ? rs(50) : rs(38),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? rs(20) : rs(16),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? rs(20) : rs(16),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _initial(),
                      style: GoogleFonts.nunito(
                        color: _color,
                        fontWeight: FontWeight.w900,
                        fontSize: rank == 1 ? rs(20) : rs(16),
                      ),
                    ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -4, duration: 1200.ms),
      SizedBox(height: rs(8)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          entry.name,
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: rank == 1 ? rs(12) : rs(11),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: rs(2)),
      Text(
        '#${entry.rank}',
        style: GoogleFonts.nunito(
          color: _color,
          fontWeight: FontWeight.w800,
          fontSize: rs(11),
        ),
      ),
      SizedBox(height: rs(4)),
      Text(
        '${_fmtCompact(entry.xpTotal)} XP',
        style: GoogleFonts.nunito(
          color: t.mutedText,
          fontWeight: FontWeight.w700,
          fontSize: rs(10),
        ),
      ),
      if (entry.levelName != null)
        Text(
          entry.levelName!,
          style: GoogleFonts.nunito(
            color: t.mutedText.withValues(alpha: 0.7),
            fontSize: rs(9),
          ),
        ),
      SizedBox(height: rs(4)),
      // Podium base
      Container(
        height: baseH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color, _color.withValues(alpha: 0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(rs(12)),
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
              fontSize: rank == 1 ? rs(28) : rs(22),
            ),
          ),
        ),
      ),
    ],
  );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SEARCH CARD
// ════════════════════════════════════════════════════════════════════════════

class _SearchCard extends StatelessWidget {
  final BloomTheme t;
  final double screenW;
  final ValueChanged<String> onChanged;
  const _SearchCard({required this.t, required this.screenW, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(18)),
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
              fontSize: rs(12),
            ),
          ),
          SizedBox(height: rs(8)),
          Container(
            decoration: BoxDecoration(
              color: t.bgPrimary,
              borderRadius: BorderRadius.circular(rs(10)),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.3)),
            ),
            child: Semantics(
              label: 'Cari pemain',
              child: TextField(
                onChanged: onChanged,
                style: GoogleFonts.nunito(color: t.textPrimary, fontSize: rs(13)),
                decoration: InputDecoration(
                  hintText: 'Ketik nama pemain...',
                  hintStyle: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: rs(13),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: t.mutedText,
                    size: rs(20),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: rs(12)),
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
  final double screenW;
  final List<LeaderboardEntry> entries;
  final bool isSearchActive;
  final int? currentUserRank;
  final int topXp;
  const _LeaderboardTable({
    required this.t,
    required this.screenW,
    required this.entries,
    this.isSearchActive = false,
    this.currentUserRank,
    required this.topXp,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(rs(24)),
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
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: rs(28), color: t.warning),
              SizedBox(width: rs(8)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: rs(20),
                    ),
                  ),
                  Text(
                    'Ranking pemain berdasarkan total XP',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: rs(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: rs(16)),
          // ── Content ─────────────────────────────────────────────────
          if (entries.isEmpty && !isSearchActive)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(32)),
              child: Text(
                'Belum ada data',
                style: GoogleFonts.nunito(color: t.mutedText, fontSize: rs(15)),
              ),
            )
          else if (entries.isEmpty && isSearchActive)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(32)),
              child: Text(
                'Tidak ada pemain dengan nama tersebut',
                style: GoogleFonts.nunito(color: t.mutedText, fontSize: rs(15)),
              ),
            )
          else
            Column(
              children: [
                // Top 5 rows
                ...entries.take(5).map((e) => Padding(
                  padding: EdgeInsets.only(bottom: rs(8)),
                  child: _LeaderboardRow(
                    entry: e,
                    isCurrentUser: e.rank == currentUserRank,
                    t: t,
                    screenW: screenW,
                  ),
                )),
                // Separator (always visible when not searching)
                if (!isSearchActive && currentUserRank != null) ...[
                  SizedBox(height: rs(8)),
                  _Separator(t: t, screenW: screenW),
                  // User row (only if not in top 5)
                  if (currentUserRank! > 5) ...[
                    SizedBox(height: rs(8)),
                    if (entries.where((e) => e.rank == currentUserRank).firstOrNull case final userEntry?)
                      _LeaderboardRow(
                        entry: userEntry,
                        isCurrentUser: true,
                        t: t,
                        screenW: screenW,
                      ),
                  ],
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LEADERBOARD ROW
// ════════════════════════════════════════════════════════════════════════════

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final BloomTheme t;
  final double screenW;
  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    required this.t,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
      decoration: BoxDecoration(
        color: isCurrentUser ? t.accent.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(rs(10)),
      ),
      child: Row(
        children: [
          // Rank badge
          _RankBadgeSmall(rank: entry.rank, t: t, screenW: screenW),
          SizedBox(width: rs(12)),
          // Avatar
          Container(
            width: rs(36),
            height: rs(36),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(rs(8)),
              border: Border.all(color: t.textPrimary, width: 1.5),
            ),
            child: Center(
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(rs(7)),
                      child: CachedNetworkImage(
                        imageUrl: entry.avatar!,
                        width: rs(32),
                        height: rs(32),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Text(
                          entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: rs(12),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Text(
                          entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: rs(12),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontWeight: FontWeight.w800,
                        fontSize: rs(12),
                      ),
                    ),
            ),
          ),
          SizedBox(width: rs(8)),
          // Name
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser ? 'Anda' : entry.name,
                    style: GoogleFonts.nunito(
                      color: isCurrentUser ? t.primary : t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: rs(13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: rs(8)),
          // XP (plain text, no border)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_fmtCompact(entry.xpTotal)} XP',
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: rs(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SEPARATOR
// ════════════════════════════════════════════════════════════════════════════

class _Separator extends StatelessWidget {
  final BloomTheme t;
  final double screenW;
  const _Separator({required this.t, required this.screenW});

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(4)),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(color: t.mutedText),
              child: const SizedBox(height: 2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rs(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(2)),
                child: Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: rs(6),
                    height: rs(6),
                    color: t.mutedText,
                  ),
                ),
              )),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(color: t.mutedText),
              child: const SizedBox(height: 2),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DASHED LINE PAINTER
// ════════════════════════════════════════════════════════════════════════════

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      final end = (x + dash).clamp(0, size.width).toDouble();
      canvas.drawLine(Offset(x, size.height / 2), Offset(end, size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => color != oldDelegate.color;
}

// ════════════════════════════════════════════════════════════════════════════
// FOOTER STATS
// ════════════════════════════════════════════════════════════════════════════

class _FooterStats extends StatelessWidget {
  final BloomTheme t;
  final double screenW;
  final int total;
  final int topXp;
  final int? myRank;
  const _FooterStats({
    required this.t,
    required this.screenW,
    required this.total,
    required this.topXp,
    this.myRank,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Semantics(
      label:
          'Statistik: $total pemain, Top XP $topXp${myRank != null ? ', ranking anda $myRank' : ''}',
      child: Container(
        padding: EdgeInsets.all(rs(16)),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(rs(18)),
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
              screenW: screenW,
              label: 'Total Pemain',
              value: formatNumber(total),
              color: t.primary,
            ),
            _StatItem(
              t: t,
              screenW: screenW,
              label: 'Top XP',
              value: formatNumber(topXp),
              color: t.success,
            ),
            if (myRank != null)
              _StatItem(
                t: t,
                screenW: screenW,
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
  final double screenW;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.t,
    required this.screenW,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w800,
            fontSize: rs(10),
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: rs(4)),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: rs(20),
          ),
        ),
      ],
    ),
  );
  }
}
