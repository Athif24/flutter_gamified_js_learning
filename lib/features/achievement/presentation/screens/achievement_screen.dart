import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/achievement_provider.dart';
import '../../data/models/achievement_model.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t    = ref.watch(currentThemeProvider);
    final auth = ref.watch(authProvider);
    final xpAsync      = ref.watch(xpProvider);
    final streakAsync  = ref.watch(streakProvider);
    final badgesAsync  = ref.watch(userBadgesProvider);
    final reportAsync  = ref.watch(learningReportProvider);
    final name = auth.user?.name ?? 'Mahasiswa';

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Hero progress card ───────────────────────────────────
              xpAsync.when(
                loading: () => _Skeleton(t: t, height: 160),
                error: (e, _) => _RetryCard(t: t, label: 'Progress',
                    onRetry: () => ref.refresh(xpProvider)),
                data: (xp) => streakAsync.maybeWhen(
                  data: (streak) => _HeroCard(t: t, xp: xp,
                      streak: streak, name: name)
                      .animate().fadeIn(),
                  orElse: () => _HeroCard(t: t, xp: xp,
                      streak: null, name: name)
                      .animate().fadeIn(),
                ),
              ),

              const SizedBox(height: 16),

              // ── Stats row ────────────────────────────────────────────
              reportAsync.when(
                loading: () => _Skeleton(t: t, height: 90),
                error: (_, __) => const SizedBox.shrink(),
                data: (r) => Row(children: [
                  Expanded(child: _StatCard(t: t, emoji: '⚡',
                      value: '${r.quizAttempts}',
                      label: 'TOTAL XP', color: t.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(t: t, emoji: '🔥',
                      value: streakAsync.maybeWhen(
                          data: (s) => '${s.currentStreak} hari',
                          orElse: () => '—'),
                      label: 'STREAK SEKARANG', color: t.warning)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(t: t, emoji: '💎',
                      value: '${r.quizAttempts}/${r.quizAttempts}',
                      label: 'BADGE DIRAIH', color: t.info)),
                  const SizedBox(width: 10),
                  Expanded(child: xpAsync.maybeWhen(
                    data: (xp) => _StatCard(t: t, emoji: '↑',
                        value: '${xp.xpToNextLevel} XP',
                        label: 'LEVEL BERIKUTNYA', color: t.success),
                    orElse: () => const SizedBox.shrink(),
                  )),
                ]).animate().fadeIn(delay: 100.ms),
              ),

              const SizedBox(height: 22),

              // ── Koleksi Badge ────────────────────────────────────────
              _SectionHeader(t: t, title: 'Koleksi Badge', emoji: '🏅'),
              const SizedBox(height: 12),

              badgesAsync.when(
                loading: () => _Skeleton(t: t, height: 150),
                error: (e, _) => _RetryCard(t: t, label: 'Badge',
                    onRetry: () => ref.refresh(userBadgesProvider)),
                data: (badges) => badges.isEmpty
                    ? _EmptyBadges(t: t)
                    : _BadgesGrid(badges: badges, t: t)
                        .animate().fadeIn(delay: 200.ms),
              ),

              const SizedBox(height: 22),

              // ── Statistik belajar ────────────────────────────────────
              _SectionHeader(t: t, title: 'Statistik Belajar', emoji: '📊'),
              const SizedBox(height: 12),

              reportAsync.when(
                loading: () => _Skeleton(t: t, height: 200),
                error: (_, __) => const SizedBox.shrink(),
                data: (r) => _LearningStats(t: t, report: r)
                    .animate().fadeIn(delay: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final BloomTheme t;
  final XpModel xp;
  final StreakModel? streak;
  final String name;
  const _HeroCard({required this.t, required this.xp,
      this.streak, required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [t.accent.withOpacity(0.25), t.info.withOpacity(0.15)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: t.accent.withOpacity(0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress Kamu', style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 11,
                fontWeight: FontWeight.w700)),
            Text(name, style: GoogleFonts.nunito(
                color: t.textPrimary, fontSize: 20,
                fontWeight: FontWeight.w900)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: t.bgSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎯', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(xp.levelTitle, style: GoogleFonts.nunito(
                color: t.textPrimary, fontWeight: FontWeight.w800,
                fontSize: 12)),
          ]),
        ),
      ]),
      const SizedBox(height: 12),

      // XP bar
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text('${xp.totalXp} XP', style: GoogleFonts.nunito(
              color: t.accent, fontWeight: FontWeight.w800, fontSize: 13)),
        ]),
        Text('${xp.xpToNextLevel} XP lagi menuju ${xp.levelTitle}',
            style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 11)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
          value: xp.progress,
          backgroundColor: t.bgSurface3,
          valueColor: AlwaysStoppedAnimation(t.accent),
          minHeight: 10,
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Text('Pemula', style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 11)),
        const Spacer(),
        Text(xp.levelTitle, style: GoogleFonts.nunito(
            color: t.textSecondary, fontSize: 11)),
      ]),

      if (streak != null) ...[
        const SizedBox(height: 12),
        Row(children: [
          _MiniChip(t, '🔥', '${streak!.currentStreak} Hari Streak', t.warning),
          const SizedBox(width: 10),
          _MiniChip(t, '💎', '💎 Jewels', t.info),
          const SizedBox(width: 10),
          _MiniChip(t, '❤️', '0/5 Lives', t.error),
        ]),
      ],
    ]),
  );
}

class _MiniChip extends StatelessWidget {
  final BloomTheme t;
  final String emoji, label;
  final Color color;
  const _MiniChip(this.t, this.emoji, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.nunito(
          color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final BloomTheme t;
  final String emoji, value, label;
  final Color color;
  const _StatCard({required this.t, required this.emoji,
      required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.nunito(
          color: color, fontSize: 15, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center, maxLines: 1,
          overflow: TextOverflow.ellipsis),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 8,
          fontWeight: FontWeight.w700, letterSpacing: 0.3),
          textAlign: TextAlign.center),
    ]),
  );
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final BloomTheme t;
  final String title, emoji;
  const _SectionHeader({required this.t, required this.title, required this.emoji});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    const SizedBox(width: 8),
    Text(title, style: GoogleFonts.nunito(
        color: t.textPrimary, fontSize: 16,
        fontWeight: FontWeight.w800)),
  ]);
}

class _BadgesGrid extends StatelessWidget {
  final List<BadgeModel> badges;
  final BloomTheme t;
  const _BadgesGrid({required this.badges, required this.t});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, mainAxisSpacing: 10,
      crossAxisSpacing: 10, childAspectRatio: 0.82,
    ),
    itemCount: badges.length,
    itemBuilder: (_, i) {
      final b = badges[i];
      final rarityColor = switch(b.rarity) {
        'gold'   => const Color(0xFFFFD700),
        'silver' => const Color(0xFFC0C0C0),
        _        => const Color(0xFFCD7F32),
      };
      return Tooltip(
        message: b.description ?? b.name,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: b.isEarned ? 1.0 : 0.3,
          child: Container(
            decoration: BoxDecoration(
              color: b.isEarned
                  ? rarityColor.withOpacity(0.12) : t.bgSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: b.isEarned
                    ? rarityColor.withOpacity(0.4) : t.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(b.name,
                    style: GoogleFonts.nunito(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: b.isEarned ? rarityColor : t.textHint,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                if (b.earnedAt != null) ...[
                  const SizedBox(height: 2),
                  Text('Diraih', style: GoogleFonts.nunito(
                      fontSize: 8, color: t.success)),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _EmptyBadges extends StatelessWidget {
  final BloomTheme t;
  const _EmptyBadges({required this.t});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border),
    ),
    child: Center(child: Column(children: [
      const Text('🏅', style: TextStyle(fontSize: 36)),
      const SizedBox(height: 8),
      Text('Belum ada badge', style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 13)),
    ])),
  );
}

// ── Learning stats ────────────────────────────────────────────────────────────

class _LearningStats extends StatelessWidget {
  final BloomTheme t;
  final LearningReportModel report;
  const _LearningStats({required this.t, required this.report});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: t.bgSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: t.border),
    ),
    child: Column(children: [
      _StatRow(t: t, label: 'Skor Rata-rata',
          value: '${report.averageScore.toInt()}%', color: t.accent),
      Divider(color: t.border, height: 20),
      _StatRow(t: t, label: 'Skor Terbaik',
          value: '${report.bestScore.toInt()}%', color: t.success),
      Divider(color: t.border, height: 20),
      _StatRow(t: t, label: 'Quiz Attempt',
          value: '${report.quizAttempts}', color: t.info),
      Divider(color: t.border, height: 20),
      _StatRow(t: t, label: 'Lesson Selesai',
          value: '${report.lessonsCompleted}', color: t.warning),
    ]),
  );
}

class _StatRow extends StatelessWidget {
  final BloomTheme t;
  final String label, value;
  final Color color;
  const _StatRow({required this.t, required this.label,
      required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 10),
    Text(label, style: GoogleFonts.nunito(
        color: t.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
    const Spacer(),
    Text(value, style: GoogleFonts.nunito(
        color: color, fontSize: 15, fontWeight: FontWeight.w900)),
  ]);
}

// ── Skeleton & Retry ──────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  final BloomTheme t;
  final double height;
  const _Skeleton({required this.t, required this.height});
  @override
  Widget build(BuildContext context) => Container(
      height: height,
      decoration: BoxDecoration(
          color: t.bgSurface2, borderRadius: BorderRadius.circular(18)))
      .animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1200.ms, color: t.bgSurface3);
}

class _RetryCard extends StatelessWidget {
  final BloomTheme t;
  final String label;
  final VoidCallback onRetry;
  const _RetryCard({required this.t, required this.label, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: t.bgSurface2, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.border),
    ),
    child: Row(children: [
      Icon(Icons.error_outline_rounded, color: t.error, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text('Gagal memuat $label',
          style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 12))),
      Bounceable(onTap: onRetry, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: t.accent, borderRadius: BorderRadius.circular(50)),
        child: Text('Retry', style: GoogleFonts.nunito(
            color: t.accentText, fontSize: 11,
            fontWeight: FontWeight.w800)),
      )),
    ]),
  );
}