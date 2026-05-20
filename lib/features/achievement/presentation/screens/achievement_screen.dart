import 'dart:ui' show ImageFilter;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
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

class _AchievementScreenState extends ConsumerState<AchievementScreen> with SilentRefreshMixin<AchievementScreen> {
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

    final t    = ref.watch(currentThemeProvider);
    final auth = ref.watch(authProvider);
    final xpAsync      = ref.watch(xpProvider);
    final streakAsync  = ref.watch(streakProvider);
    final badgesAsync  = ref.watch(mergedBadgesProvider);
    final livesAsync   = ref.watch(livesProvider);
    final levelsAsync  = ref.watch(levelsProvider);
    final xpHistoryAsync = ref.watch(xpHistoryProvider);
    final name = auth.user?.name ?? 'Mahasiswa';

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Column(
        children: [
          SlowLoadingIndicator(
            visible: showSlowIndicator,
            t: t,
          ),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(xpProvider);
                  ref.invalidate(streakProvider);
                  ref.invalidate(mergedBadgesProvider);
                  ref.invalidate(livesProvider);
                  ref.invalidate(levelsProvider);
                  ref.invalidate(xpHistoryProvider);
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
                loading: () => LoadingCircle(t: t),
                error: (e, _) => _RetryCard(t: t, label: 'Progress',
                    onRetry: () => ref.refresh(xpProvider)),
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
                loading: () => LoadingCircle(t: t),
                error: (_, __) => const SizedBox.shrink(),
                data: (xp) {
                  final s = streakAsync.valueOrNull;
                  final earnedBadges = badgesAsync.valueOrNull
                      ?.where((b) => b.isEarned).length ?? 0;
                  final totalBadges = badgesAsync.valueOrNull?.length ?? 0;
                  final badgePct = totalBadges > 0
                      ? '${(earnedBadges / totalBadges * 100).toInt()}% selesai'
                      : 'Ayo kerjain quiz!';
                  final items = [
                    _StatCard(t: t, icon: Icons.bolt_rounded,
                        value: _formatNumber(xp.totalXp),
                        label: 'TOTAL XP',
                        subtitle: 'experience points',
                        color: t.warning),
                    _StatCard(t: t, icon: Icons.local_fire_department_rounded,
                        value: '${s?.currentStreak ?? 0} hari',
                        subtitle: 'Terpanjang: ${s?.longestStreak ?? 0} hari',
                        label: 'STREAK SEKARANG', color: Colors.orange),
                    _StatCard(t: t, icon: Icons.emoji_events_rounded,
                        value: '$earnedBadges/$totalBadges',
                        subtitle: badgePct,
                        label: 'BADGE DIRAIH', color: Colors.purple),
                    _StatCard(t: t,
                        icon: xp.nextLevelTitle != null
                            ? Icons.arrow_upward_rounded
                            : Icons.trending_up_rounded,
                        value: xp.nextLevelTitle != null
                            ? '${_formatNumber(xp.xpToNextLevel)} XP'
                            : 'MAX!',
                        subtitle: xp.nextLevelTitle != null
                            ? 'Menuju ${xp.nextLevelTitle}'
                            : 'Level tertinggi tercapai',
                        label: 'LEVEL BERIKUTNYA', color: t.success),
                  ];
                  return LayoutBuilder(
                    builder: (_, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                      final totalGutter = 12 * (crossAxisCount - 1);
                      final childWidth = (constraints.maxWidth - totalGutter) / crossAxisCount;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: items.map((item) =>
                            SizedBox(width: childWidth, child: item)).toList(),
                      );
                    },
                  ).animate().fadeIn(delay: 100.ms);
                },
              ),

              const SizedBox(height: 16),

              // ── Koleksi Badge ────────────────────────────────────────
              _BadgeCollection(t: t, badgesAsync: badgesAsync)
                  .animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // ── Level Roadmap + Riwayat XP (two-column) ──────────────
              xpAsync.when(
                loading: () => LoadingCircle(t: t),
                error: (_, __) => const SizedBox.shrink(),
                data: (xp) => levelsAsync.when(
                  loading: () => LoadingCircle(t: t),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (levels) => LayoutBuilder(
                    builder: (_, constraints) =>
                        constraints.maxWidth > 600
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      entries: xpHistoryAsync.valueOrNull ?? [],
                                      isLoading: xpHistoryAsync.isLoading,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LevelRoadmap(
                                    levels: levels,
                                    xpTotal: xp.totalXp,
                                  ),
                                  const SizedBox(height: 16),
                                  XpHistoryList(
                                    entries: xpHistoryAsync.valueOrNull ?? [],
                                    isLoading: xpHistoryAsync.isLoading,
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
          ),
        ],
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final BloomTheme t;
  final XpModel xp;
  final StreakModel? streak;
  final LivesModel? lives;
  final String name;
  const _HeroCard({required this.t, required this.xp,
      this.streak, this.lives, required this.name});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: t.accent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border, width: 2),
          boxShadow: [BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LayoutBuilder(
            builder: (_, constraints) {
              final nameCol = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Progress Kamu', style: GoogleFonts.nunito(
                    color: t.textSecondary, fontSize: 14,
                    fontWeight: FontWeight.w700)),
                Text(name, style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: constraints.maxWidth > 600 ? 30 : 24,
                    fontWeight: FontWeight.w900)),
              ]);
              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: t.bgSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: t.textPrimary.withAlpha(102), width: 2)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.emoji_events_rounded, color: t.warning, size: 16),
                  const SizedBox(width: 6),
                  Text(xp.levelTitle, style: GoogleFonts.nunito(
                      color: t.textPrimary, fontWeight: FontWeight.w800,
                      fontSize: 14)),
                ]),
              );
              if (constraints.maxWidth < 360) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [nameCol, const SizedBox(height: 8), badge]);
              }
              return Row(children: [Expanded(child: nameCol), badge]);
            },
          ),
          const SizedBox(height: 12),

          // XP bar
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.bolt_rounded, color: t.warning, size: 16),
              const SizedBox(width: 6),
              Text('${_formatNumber(xp.totalXp)} XP', style: GoogleFonts.nunito(
                  color: t.warning, fontWeight: FontWeight.w800, fontSize: 14)),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                xp.nextLevelTitle != null
                    ? '${_formatNumber(xp.xpToNextLevel)} XP lagi menuju ${xp.nextLevelTitle}'
                    : 'Max level!',
                style: GoogleFonts.nunito(
                    color: t.textSecondary, fontSize: 12)),
              if (xp.nextLevelTitle != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.chevron_right, color: t.textSecondary, size: 14),
                ),
            ]),
          ]),
          const SizedBox(height: 6),
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.border.withAlpha(120), width: 2),
              boxShadow: [BoxShadow(
                  color: t.border.withAlpha(75),
                  offset: const Offset(1, 1), blurRadius: 0)],
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
                  valueColor: AlwaysStoppedAnimation(t.accent),
                  minHeight: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text(xp.levelTitle, style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 12,
                fontWeight: FontWeight.w700)),
            const Spacer(),
            if (xp.nextLevelTitle != null)
              Text(xp.nextLevelTitle!, style: GoogleFonts.nunito(
                  color: t.textSecondary, fontSize: 12,
                  fontWeight: FontWeight.w700)),
          ]),

          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _StatPill(
                t: t,
                icon: Icons.local_fire_department_rounded,
                value: '${streak?.currentStreak ?? 0}',
                label: 'Hari Streak',
                iconColor: Colors.orange,
                bgColor: Colors.orange.withAlpha(25),
              ),
              _StatPill(
                t: t,
                icon: Icons.diamond_rounded,
                value: _formatNumber(xp.jewels),
                label: 'Jewels',
                iconColor: Colors.lightBlue,
                bgColor: Colors.lightBlue.withAlpha(25),
              ),
              _StatPill(
                t: t,
                icon: Icons.favorite_rounded,
                value: '${lives?.current ?? 0}',
                label: 'Lives',
                iconColor: lives != null && lives!.current <= 1 ? t.error : t.success,
                bgColor: (lives != null && lives!.current <= 1 ? t.error : t.success).withAlpha(25),
              ),
            ],
          ),
        ]),
      ),
    ],
  );
}

class _StatPill extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final Color iconColor, bgColor;
  const _StatPill({
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: iconColor.withAlpha(80), width: 2),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(child: Icon(icon, color: iconColor, size: 16)),
      ),
      const SizedBox(width: 10),
      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.nunito(
            color: iconColor, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label.toUpperCase(), style: GoogleFonts.nunito(
            color: iconColor.withAlpha(180), fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ]),
    ]),
      ),
    ),
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final String? subtitle;
  final Color color;
  const _StatCard({required this.t, required this.icon,
      required this.value, required this.label, required this.color,
      this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border, width: 2),
      boxShadow: [BoxShadow(color: t.border, offset: const Offset(3, 3), blurRadius: 0)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Icon(icon, color: color, size: 20)),
      ),
      const SizedBox(height: 12),
      Text(label, style: GoogleFonts.nunito(
          color: color.withValues(alpha: 0.6), fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.nunito(
          color: color, fontSize: 20, fontWeight: FontWeight.w900),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      if (subtitle != null) ...[
        const SizedBox(height: 2),
        Text(subtitle!, style: GoogleFonts.nunito(
            color: t.textHint, fontSize: 11,
            fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ]),
  );
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final IconData icon;
  final String? count;
  const _SectionHeader({required this.t, required this.title, required this.icon, this.count});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: t.warning, size: 20),
    const SizedBox(width: 8),
    Text(title, style: GoogleFonts.nunito(
        color: t.textPrimary, fontSize: 16,
        fontWeight: FontWeight.w800)),
    if (count != null) ...[
      const Spacer(),
      Text(count!, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 13,
          fontWeight: FontWeight.w700)),
    ],
  ]);
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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return widget.badgesAsync.when(
      loading: () => LoadingCircle(t: t),
      error: (e, _) => const SizedBox.shrink(),
      data: (badges) {
        if (badges.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(t: t, title: 'Koleksi Badge', icon: Icons.emoji_events_rounded),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border, width: 2),
                  boxShadow: [BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: Center(child: Column(children: [
                  const Text('🏅', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text('Belum ada badge',
                      style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 13)),
                ])),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border, width: 2),
            boxShadow: [BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _SectionHeader(t: t, title: 'Koleksi Badge', icon: Icons.emoji_events_rounded, count: '$earnedCount/${badges.length}'),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
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
              height: 2,
              decoration: BoxDecoration(
                color: t.border.withAlpha(80),
                boxShadow: [BoxShadow(
                    color: t.border,
                    offset: const Offset(0, 1), blurRadius: 0)],
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border),
                ),
                child: Column(children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 40, color: t.textHint),
                  const SizedBox(height: 8),
                  Text(_activeTab == 'earned'
                      ? 'Belum ada badge yang diraih'
                      : 'Semua badge sudah diraih!',
                      style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 13)),
                ]),
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
                  final childWidth = (constraints.maxWidth - totalGutter) / crossAxisCount;

                  return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filtered.map((b) =>
                    SizedBox(width: childWidth, child: _buildBadgeCard(t, b))).toList(),
              );
            },
          ),
          ],
        ),
        );
      },
    );
  }

  Widget _buildBadgeCard(BloomTheme t, BadgeModel b) {
    final earned = b.isEarned;
    final condIcon = _conditionIcons[b.conditionType];
    final condLabel = _conditionLabels[b.conditionType];

    final cardBody = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned ? t.bgSurface : t.bgSurface2.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: earned ? t.warning.withAlpha(25) : t.bgSurface3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border, width: 2),
            ),
            child: Semantics(
              label: '${b.name} - ${earned ? "Sudah didapat" : "Belum didapat"}',
              child: Center(
                child: b.icon.startsWith('http')
                  ? CachedNetworkImage(imageUrl: b.icon, width: 36, height: 36,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          Icon(Icons.emoji_events_rounded, size: 24,
                              color: earned ? t.warning : t.textHint),
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.emoji_events_rounded, size: 24,
                              color: earned ? t.warning : t.textHint))
                   : Text(b.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            ),
          const SizedBox(height: 12),
          Text(b.name,
              style: GoogleFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: earned ? t.textPrimary : t.textHint,
              ),
              textAlign: TextAlign.center, maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (b.description != null && b.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(b.description!,
                style: GoogleFonts.nunito(fontSize: 11, color: t.textHint),
                textAlign: TextAlign.center, maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          if (condIcon != null && b.conditionValue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: t.bgSurface2,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: t.border.withAlpha(50), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(condIcon, size: 10, color: t.textSecondary),
                  const SizedBox(width: 3),
                  Text('$condLabel: ${b.conditionValue}',
                      style: GoogleFonts.nunito(fontSize: 10,
                          color: t.textSecondary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
          if (b.rewardJewels > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_rounded, size: 10, color: t.info),
                const SizedBox(width: 2),
                Text('+${b.rewardJewels} jewels',
                    style: GoogleFonts.nunito(fontSize: 11,
                        color: t.info, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
          if (earned && b.earnedAt != null) ...[
            const SizedBox(height: 12),
            Text('Diraih ${_formatDate(b.earnedAt)}',
                style: GoogleFonts.nunito(fontSize: 10, color: t.textHint)),
          ],
        ],
      ),
    );

    final card = Stack(
      clipBehavior: Clip.none,
      children: [
        cardBody,
        Positioned(
          right: -8, top: -8,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned ? t.success : t.bgSurface3,
              border: Border.all(color: t.border, width: 2),
              boxShadow: [BoxShadow(
                  color: t.border,
                  offset: const Offset(1, 1), blurRadius: 0)],
            ),
            child: Center(
              child: earned
                  ? Icon(Icons.check_rounded,
                      color: t.accentText, size: 13)
                  : Icon(Icons.lock_rounded,
                      color: t.textHint, size: 14),
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
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
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
        color: isActive
            ? t.accent
            : t.bgSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [BoxShadow(color: t.border, offset: const Offset(2, 2), blurRadius: 0)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.nunito(
                color: isActive
                    ? t.accentText
                    : t.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isActive
                  ? t.accentText.withAlpha(30)
                  : t.bgSurface2,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text('$count',
                style: GoogleFonts.nunito(
                  color: isActive
                      ? t.accentText
                      : t.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                )),
          ),
        ],
      ),
    ),
  );
}

// ── Skeleton & Retry ──────────────────────────────────────────────────────────

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
      Expanded(child: Text(AppStrings.errLoadAchievementDetail,
          style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 12))),
      Semantics(
        label: 'Coba lagi',
        child: Bounceable(onTap: onRetry, child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: t.accent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: t.border,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ]),
          child: Text(AppStrings.retryLabel, style: GoogleFonts.nunito(
              color: t.accentText, fontSize: 11,
              fontWeight: FontWeight.w800)),
        )),
      ),
    ]),
  );
}

String _formatNumber(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final parts = <String>[];
  for (int i = s.length; i > 0; i -= 3) {
    parts.insert(0, s.substring(i > 3 ? i - 3 : 0, i));
  }
  return parts.join('.');
}
