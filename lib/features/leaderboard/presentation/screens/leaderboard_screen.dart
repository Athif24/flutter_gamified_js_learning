import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../providers/leaderboard_provider.dart';
import '../../data/models/leaderboard_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

String _fmt(int n) {
  if (n < 1000) return n.toString();
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

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

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 2 && next == 2) {
        ref.invalidate(leaderboardProvider);
      }
    });

    final t = ref.watch(currentThemeProvider);
    final boardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: boardAsync.when(
          loading: () => _buildSkeleton(t),
          error: (e, _) => _buildError(t, e),
          data: (res) => _buildContent(t, res),
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
        : entries.where((e) =>
            e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(leaderboardProvider);
        return Future<void>.value();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // ── Header Card ──────────────────────────────────────────────
          _HeaderCard(t: t, currentUserRank: currentUserRank,
              currentUserXp: currentUserXp).animate().fadeIn(),

          const SizedBox(height: 16),

          // ── User Rank Card ───────────────────────────────────────────
          if (currentUserRank != null && currentUserXp != null)
            _UserRankCard(t: t, rank: currentUserRank, xp: currentUserXp)
                .animate().fadeIn(delay: 100.ms),

          if (currentUserRank != null && currentUserXp != null)
            const SizedBox(height: 16),

          // ── Podium ────────────────────────────────────────────────────
          if (entries.length >= 3)
            _Podium(t: t, entries: entries.take(3).toList())
                .animate().fadeIn(delay: 180.ms),

          if (entries.length >= 3)
            const SizedBox(height: 16),

          // ── Search ────────────────────────────────────────────────────
          _SearchCard(t: t, onChanged: (v) =>
              setState(() => _searchQuery = v))
              .animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          // ── Table ────────────────────────────────────────────────────
          _LeaderboardTable(t: t, entries: filtered,
              currentUserRank: currentUserRank, topXp: topXp)
              .animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // ── Footer Stats ─────────────────────────────────────────────
          if (entries.isNotEmpty)
            _FooterStats(t: t, total: entries.length,
                topXp: topXp, myRank: currentUserRank)
                .animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  // ── Skeleton ─────────────────────────────────────────────────────────

  Widget _buildSkeleton(BloomTheme t) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _SkelBox(h: 160, t: t),
        const SizedBox(height: 16),
        _SkelBox(h: 120, t: t),
        const SizedBox(height: 16),
        _SkelBox(h: 200, t: t),
        const SizedBox(height: 16),
        _SkelBox(h: 60, t: t),
        const SizedBox(height: 16),
        _SkelBox(h: 350, t: t),
        const SizedBox(height: 16),
        _SkelBox(h: 80, t: t),
      ],
    );
  }

  // ── Error ────────────────────────────────────────────────────────────

  Widget _buildError(BloomTheme t, Object e) {
    return Center(child: Column(
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
          child: Row(children: [
            Icon(Icons.error_outline_rounded, color: t.error, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text('Gagal memuat leaderboard. Silakan coba lagi.',
                style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 13))),
            const SizedBox(width: 8),
            Bounceable(
              onTap: () => ref.invalidate(leaderboardProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: t.bgSurface, borderRadius: BorderRadius.circular(50)),
                child: Text('Coba Lagi', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ]),
        ),
      ],
    ));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SKELETON BOX
// ════════════════════════════════════════════════════════════════════════════

class _SkelBox extends StatelessWidget {
  final double h;
  final BloomTheme t;
  const _SkelBox({required this.h, required this.t});
  @override
  Widget build(BuildContext context) => Container(
    height: h,
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// HEADER CARD
// ════════════════════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  final BloomTheme t;
  final int? currentUserRank;
  final int? currentUserXp;
  const _HeaderCard({required this.t, this.currentUserRank, this.currentUserXp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.accent.withValues(alpha: 0.25), t.info.withValues(alpha: 0.12)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Stack(children: [
        Positioned(right: -48, top: -48,
          child: Container(width: 192, height: 192,
            decoration: BoxDecoration(
              color: t.bgSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(left: -32, bottom: -32,
          child: Container(width: 128, height: 128,
            decoration: BoxDecoration(
              color: t.textHint.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Column(children: [
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leaderboard', style: GoogleFonts.nunito(
                    color: t.accentText, fontSize: 24,
                    fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Lihat peringkat Anda dan kompetisi dengan pemain lain',
                    style: GoogleFonts.nunito(
                        color: t.accentText.withValues(alpha: 0.8), fontSize: 14)),
              ],
            )),
          ]),
        ]),
      ]),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.accent.withValues(alpha: 0.1), t.accent.withValues(alpha: 0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.accent, width: 3),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Posisi Anda', style: GoogleFonts.nunito(
              color: t.accent, fontSize: 18, fontWeight: FontWeight.w900)),
          Icon(Icons.local_fire_department_rounded,
              size: 24, color: const Color(0xFFF59E0B))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1,1), end: const Offset(1.15,1.15),
                  duration: 1000.ms),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RANKING', style: GoogleFonts.nunito(
                  color: t.textSecondary, fontWeight: FontWeight.w800,
                  fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 4),
              Row(children: [
                Text('#$rank', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w900, fontSize: 36)),
                const SizedBox(width: 8),
                _RankBadgeSmall(rank: rank, t: t),
              ]),
            ],
          )),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('TOTAL XP', style: GoogleFonts.nunito(
                  color: t.textSecondary, fontWeight: FontWeight.w800,
                  fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(_fmt(xp), style: GoogleFonts.nunito(
                    color: t.textPrimary, fontWeight: FontWeight.w900, fontSize: 36)),
                const SizedBox(width: 4),
                Text('XP', style: GoogleFonts.nunito(
                    color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ],
          )),
        ]),
      ]),
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
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (rank == 1) const Text('🏆', style: TextStyle(fontSize: 12)),
      if (rank == 2) const Text('🥈', style: TextStyle(fontSize: 12)),
      if (rank == 3) const Text('🥉', style: TextStyle(fontSize: 12)),
      if (rank <= 3) const SizedBox(width: 3),
      Text('$rank', style: GoogleFonts.nunito(
          color: _fg, fontWeight: FontWeight.w900, fontSize: 12)),
    ]),
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
    return Column(children: [
      Row(children: [
        const Icon(Icons.emoji_events_rounded, size: 22, color: Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        Text('Top 3 Pemain Terbaik', style: GoogleFonts.nunito(
            color: t.accent, fontSize: 16, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _PodiumUser(entry: entries[1], rank: 2, t: t, baseH: 48)),
        const SizedBox(width: 8),
        Expanded(child: _PodiumUser(entry: entries[0], rank: 1, t: t, baseH: 80)),
        const SizedBox(width: 8),
        Expanded(child: _PodiumUser(entry: entries[2], rank: 3, t: t, baseH: 40)),
      ]),
    ]);
  }
}

class _PodiumUser extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final BloomTheme t;
  final double baseH;
  const _PodiumUser({required this.entry, required this.rank,
      required this.t, required this.baseH});

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8);
    return const Color(0xFFCD7F32);
  }

  String _initial() =>
      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) => Column(children: [
    if (rank == 1)
      const Icon(Icons.emoji_events_rounded, size: 28, color: Color(0xFFB45309)),
    if (rank == 2)
      const Icon(Icons.emoji_events_rounded, size: 24, color: Color(0xFF64748B)),
    if (rank == 3)
      const Icon(Icons.emoji_events_rounded, size: 24, color: Color(0xFFD97706)),
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
                child: Image.network(entry.avatar!, width: rank == 1 ? 50 : 38,
                    height: rank == 1 ? 50 : 38, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(_initial(),
                        style: GoogleFonts.nunito(color: _color,
                            fontWeight: FontWeight.w900, fontSize: rank == 1 ? 20 : 16))))
            : Text(_initial(),
                style: GoogleFonts.nunito(color: _color,
                    fontWeight: FontWeight.w900, fontSize: rank == 1 ? 20 : 16)),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: 0, end: -4, duration: 1200.ms),
    const SizedBox(height: 8),
    Text(entry.name, style: GoogleFonts.nunito(
        color: t.textPrimary, fontWeight: FontWeight.w800,
        fontSize: rank == 1 ? 12 : 11),
        overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
    const SizedBox(height: 2),
    Text('#${entry.rank}', style: GoogleFonts.nunito(
        color: _color, fontWeight: FontWeight.w800, fontSize: 11)),
    const SizedBox(height: 4),
    Text('${_fmtCompact(entry.xpTotal)} XP', style: GoogleFonts.nunito(
        color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 10)),
    if (entry.levelName != null)
      Text(entry.levelName!, style: GoogleFonts.nunito(
          color: t.textHint, fontSize: 9)),
    const SizedBox(height: 4),
    // Podium base
    Container(
      height: baseH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color, _color.withValues(alpha: 0.7)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: _color, width: 3),
      ),
      child: Center(child: Text('$rank', style: GoogleFonts.nunito(
          color: rank == 1 ? const Color(0xFF78350F)
              : rank == 2 ? const Color(0xFF475569)
              : const Color(0xFF7C2D12),
          fontWeight: FontWeight.w900, fontSize: rank == 1 ? 28 : 22))),
    ),
  ]);
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cari Pemain', style: GoogleFonts.nunito(
            color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.bgPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.textPrimary.withValues(alpha: 0.15)),
          ),
          child: TextField(
            onChanged: onChanged,
            style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ketik nama pemain...',
              hintStyle: GoogleFonts.nunito(color: t.textHint, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: t.textHint, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LEADERBOARD TABLE
// ════════════════════════════════════════════════════════════════════════════

class _LeaderboardTable extends StatelessWidget {
  final BloomTheme t;
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;
  final int topXp;
  const _LeaderboardTable({required this.t, required this.entries,
    this.currentUserRank, required this.topXp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.accent, width: 3),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.emoji_events_rounded, size: 28, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leaderboard', style: GoogleFonts.nunito(
                  color: t.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
              Text('Ranking pemain berdasarkan total XP', style: GoogleFonts.nunito(
                  color: t.textSecondary, fontSize: 12)),
            ],
          )),
        ]),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text('Belum ada data', style: GoogleFonts.nunito(
                color: t.textHint, fontSize: 15)),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(t.bgSurface2),
              columnSpacing: 20,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 60,
              columns: [
                DataColumn(label: Text('#', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w900, fontSize: 12))),
                DataColumn(label: Text('Pemain', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w900, fontSize: 12))),
                DataColumn(label: Text('Level', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w900, fontSize: 12))),
                DataColumn(label: Text('XP', style: GoogleFonts.nunito(
                    color: t.accent, fontWeight: FontWeight.w900, fontSize: 12)),
                    numeric: true),
              ],
              rows: entries.map((e) {
                final isMe = e.rank == currentUserRank;
                return DataRow(
                  color: WidgetStatePropertyAll(isMe
                      ? t.accent.withValues(alpha: 0.12)
                      : null),
                  cells: [
                    // Rank
                    DataCell(_RankBadgeSmall(rank: e.rank, t: t)),
                    // Name
                    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: t.bgSurface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: t.textPrimary.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: e.avatar != null && e.avatar!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(e.avatar!, width: 28,
                                      height: 28, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                          e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                                          style: GoogleFonts.nunito(
                                              color: t.textHint, fontWeight: FontWeight.w800,
                                              fontSize: 12))))
                              : Text(e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                                  style: GoogleFonts.nunito(
                                      color: t.textHint, fontWeight: FontWeight.w800,
                                      fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.name, style: GoogleFonts.nunito(
                              color: isMe ? t.accent : t.textPrimary,
                              fontWeight: FontWeight.w700, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                          if (isMe)
                            Text('Anda', style: GoogleFonts.nunito(
                                color: t.accent, fontWeight: FontWeight.w800,
                                fontSize: 10)),
                        ],
                      ),
                    ])),
                    // Level
                    DataCell(e.levelName != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(e.levelName!, style: GoogleFonts.nunito(
                                color: t.accent, fontWeight: FontWeight.w700, fontSize: 11)),
                          )
                        : Text('-', style: GoogleFonts.nunito(color: t.textHint, fontSize: 12))),
                    // XP
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_fmt(e.xpTotal), style: GoogleFonts.nunito(
                            color: t.textPrimary, fontWeight: FontWeight.w900, fontSize: 13)),
                        Text('(${_fmtCompact(e.xpTotal)})', style: GoogleFonts.nunito(
                            color: t.textHint, fontSize: 10)),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
      ]),
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
  const _FooterStats({required this.t, required this.total,
      required this.topXp, this.myRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.textPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        _StatItem(t: t, label: 'Total Pemain', value: _fmt(total), color: t.accent),
        _StatItem(t: t, label: 'Top XP', value: _fmt(topXp), color: t.success),
        if (myRank != null)
          _StatItem(t: t, label: 'Ranking Anda', value: '#$myRank', color: t.info),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.t, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: GoogleFonts.nunito(
        color: t.textSecondary, fontWeight: FontWeight.w800,
        fontSize: 10, letterSpacing: 0.5)),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.nunito(
        color: color, fontWeight: FontWeight.w900, fontSize: 20)),
  ]));
}
