import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../../data/models/leaderboard_model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t         = ref.watch(currentThemeProvider);
    final boardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text('Leaderboard', style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: 22,
                  fontWeight: FontWeight.w900))
                  .animate().fadeIn(),
              const Spacer(),
              Bounceable(
                onTap: () => ref.refresh(leaderboardProvider),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: t.bgSurface2, shape: BoxShape.circle,
                      border: Border.all(color: t.border)),
                  child: Icon(Icons.refresh_rounded,
                      color: t.accent, size: 18),
                ),
              ).animate().fadeIn(delay: 100.ms),
            ]),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Lihat peringkat Anda dan kompetisi dengan pemain lain',
                style: GoogleFonts.nunito(
                    color: t.textSecondary, fontSize: 12))
                .animate().fadeIn(delay: 150.ms),
          ),

          const SizedBox(height: 12),

          Expanded(child: boardAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
            error: (e, _) => Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😢', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Gagal memuat', style: GoogleFonts.nunito(
                    color: t.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Bounceable(
                  onTap: () => ref.refresh(leaderboardProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(50)),
                    child: Text('Coba Lagi', style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: t.accentText)),
                  ),
                ),
              ],
            )),
            data: (entries) {
              if (entries.isEmpty) {
                return Center(child: Text(
                'Belum ada data', style: GoogleFonts.nunito(
                    color: t.textSecondary)));
              }
              // Find my position
              final me = entries.where((e) => e.isCurrentUser).firstOrNull;

              return CustomScrollView(slivers: [
                // My position card
                if (me != null)
                  SliverToBoxAdapter(
                    child: _MyPositionCard(t: t, entry: me)
                        .animate().fadeIn(delay: 100.ms),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(children: [
                      const Text('🥇', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text('Top 3 Pemain Terbaik', style: GoogleFonts.nunito(
                          color: t.accent, fontSize: 14,
                          fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),

                // Podium top 3
                if (entries.length >= 3)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _Podium(entries: entries.take(3).toList(), t: t)
                          .animate().fadeIn(delay: 200.ms),
                    ),
                  ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.border),
                      ),
                      child: TextField(
                        style: GoogleFonts.nunito(color: t.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ketik nama pemain...',
                          hintStyle: GoogleFonts.nunito(
                              color: t.textHint, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: t.accent, size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 280.ms),
                ),

                // All entries
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RankTile(entry: entries[i], t: t)
                          .animate().fadeIn(delay: (50 * i).ms)
                          .slideX(begin: 0.05),
                      childCount: entries.length,
                    ),
                  ),
                ),
              ]);
            },
          )),
        ]),
      ),
    );
  }
}

// ── My position card ──────────────────────────────────────────────────────────

class _MyPositionCard extends StatelessWidget {
  final BloomTheme t;
  final LeaderboardEntry entry;
  const _MyPositionCard({required this.t, required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.accent.withOpacity(0.4)),
    ),
    child: Row(children: [
      Text('📍', style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Text('Posisi Anda', style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w600)),
      const SizedBox(width: 10),
      Text('#${entry.rank}', style: GoogleFonts.nunito(
          color: t.accent, fontSize: 22,
          fontWeight: FontWeight.w900)),
      const Spacer(),
      Text('TOTAL XP', style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 10)),
      const SizedBox(width: 8),
      Text('${entry.xp} XP', style: GoogleFonts.nunito(
          color: t.info, fontSize: 20, fontWeight: FontWeight.w900)),
    ]),
  );
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final BloomTheme t;
  const _Podium({required this.entries, required this.t});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(child: _PodiumUser(entry: entries[1], rank: 2, height: 90, t: t)),
      const SizedBox(width: 8),
      Expanded(child: _PodiumUser(entry: entries[0], rank: 1, height: 120, t: t)),
      const SizedBox(width: 8),
      Expanded(child: _PodiumUser(entry: entries[2], rank: 3, height: 70, t: t)),
    ],
  );
}

class _PodiumUser extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final BloomTheme t;
  const _PodiumUser({required this.entry, required this.rank,
      required this.height, required this.t});

  Color get _color => switch(rank) {
    1 => const Color(0xFFFFD700),
    2 => const Color(0xFFC0C0C0),
    _ => const Color(0xFFCD7F32),
  };

  String get _initials {
    final parts = entry.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (rank == 1)
      Text('👑', style: const TextStyle(fontSize: 20))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1,1), end: const Offset(1.1,1.1),
              duration: 1000.ms),
    const SizedBox(height: 6),
    Container(
      width: rank == 1 ? 60 : 50,
      height: rank == 1 ? 60 : 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withOpacity(0.15),
        border: Border.all(color: _color, width: rank == 1 ? 3 : 2),
        boxShadow: rank == 1 ? [BoxShadow(
          color: _color.withOpacity(0.4),
          blurRadius: 14, spreadRadius: 2,
        )] : null,
      ),
      child: Center(child: Text(_initials, style: GoogleFonts.nunito(
          color: _color, fontWeight: FontWeight.w900,
          fontSize: rank == 1 ? 20 : 16))),
    ),
    const SizedBox(height: 6),
    Text(entry.name.split(' ').first, style: GoogleFonts.nunito(
        color: t.textPrimary, fontWeight: FontWeight.w700,
        fontSize: rank == 1 ? 12 : 11),
        overflow: TextOverflow.ellipsis),
    const SizedBox(height: 2),
    Text('${_fmt(entry.xp)} XP', style: GoogleFonts.nunito(
        color: t.textSecondary, fontSize: 10)),
    Text(entry.levelTitle, style: GoogleFonts.nunito(
        color: t.textSecondary, fontSize: 9)),
    const SizedBox(height: 6),
    Container(
      height: height,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Center(child: Text('$rank', style: GoogleFonts.nunito(
          color: _color, fontSize: 26, fontWeight: FontWeight.w900))),
    ),
  ]);

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Rank Tile ─────────────────────────────────────────────────────────────────

class _RankTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final BloomTheme t;
  const _RankTile({required this.entry, required this.t});

  String get _initials {
    final parts = entry.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isMe  = entry.isCurrentUser;
    final isTop = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isMe ? t.accent.withOpacity(0.08) : t.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? t.accent.withOpacity(0.4) : t.border),
      ),
      child: Row(children: [
        SizedBox(width: 28, child: Text('${entry.rank}',
            style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center)),
        const SizedBox(width: 10),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMe ? t.accent : t.accent.withOpacity(0.12),
          ),
          child: Center(child: Text(_initials, style: GoogleFonts.nunito(
              color: isMe ? t.accentText : t.accent,
              fontWeight: FontWeight.w900, fontSize: 13))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Flexible(child: Text(
                isMe ? '${entry.name} (Kamu)' : entry.name,
                style: GoogleFonts.nunito(
                    color: isMe ? t.accent : t.textPrimary,
                    fontWeight: FontWeight.w700, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              )),
            ]),
            Text(entry.levelTitle, style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 11)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isTop
                ? t.accent.withOpacity(0.15) : t.bgSurface2,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text('${entry.xp}', style: GoogleFonts.nunito(
              color: isTop ? t.accent : t.textSecondary,
              fontWeight: FontWeight.w800, fontSize: 12)),
        ),
      ]),
    );
  }
}