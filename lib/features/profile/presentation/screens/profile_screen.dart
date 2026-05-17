import 'dart:io' show File;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../widgets/theme_picker_sheet.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';
import '../widgets/crop_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 4 && next == 4) {
        ref.invalidate(profileProvider);
      }
    });

    final t = ref.watch(currentThemeProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(profileProvider.future).then((_) {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: profileAsync.when(
              loading: () => _skeleton(t),
              error: (e, _) => _retryCard(t, () {
                ref.invalidate(profileProvider);
              }),
              data: (p) => Column(
                children: [
                  _ProfileHeroCard(t: t, profile: p, ref: ref),
                  const SizedBox(height: 16),
                  _ProfileStatsGrid(t: t, profile: p),
                  const SizedBox(height: 16),
                  _LearningSummary(t: t, profile: p),
                  const SizedBox(height: 16),
                  _RecentActivity(t: t, entries: p.recentXp),
                  const SizedBox(height: 16),
                  _AccountSection(t: t, email: p.email),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero Card ──────────────────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  final WidgetRef ref;
  const _ProfileHeroCard({
    required this.t,
    required this.profile,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final initials = profile.initials;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.accent.withValues(alpha: 0.25),
                t.accentDark.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: t.textPrimary.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: t.border,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: t.textPrimary.withAlpha(76),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: t.border,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: t.bgSurface.withValues(alpha: 0.3),
                  backgroundImage: profile.avatar != null
                      ? NetworkImage(profile.avatar!)
                      : null,
                  child: profile.avatar == null
                      ? Text(
                          initials,
                          style: GoogleFonts.nunito(
                            color: t.accent,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                profile.name,
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.email,
                style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (profile.levelTitle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: t.bgSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        profile.levelTitle,
                        style: GoogleFonts.nunito(
                          color: t.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: t.bgSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: t.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bergabung ${profile.daysSinceJoined} hari lalu',
                          style: GoogleFonts.nunito(
                            color: t.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Bounceable(
                onTap: () => _showEditProfile(context, ref, t, profile),
                hitTestBehavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: t.bgSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: t.border,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, color: t.accentText, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.nunito(
                          color: t.accentText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -48,
          top: -48,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
              child: Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.bgSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -32,
          bottom: -32,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.textHint.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Bounceable(
            onTap: () => showThemePicker(context, ref),
            hitTestBehavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.bgSurface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.border, width: 1.5),
              ),
              child: Center(
                child: Text('🎨', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}

// ── Stats Grid ─────────────────────────────────────────────────────────────────

class _ProfileStatsGrid extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  const _ProfileStatsGrid({required this.t, required this.profile});

  @override
  Widget build(BuildContext context) {
    final streakActive = profile.currentStreak > 0;

    int? daysSinceLastActivity;
    if (profile.lastActivityDate != null) {
      final last = DateTime.tryParse(profile.lastActivityDate!);
      if (last != null) {
        daysSinceLastActivity = DateTime.now().difference(last).inDays;
      }
    }

    final streakLabel = streakActive
        ? 'STREAK HARI INI'
        : daysSinceLastActivity != null && daysSinceLastActivity > 1
        ? 'STREAK BERAKHIR ($daysSinceLastActivity HARI LALU)'
        : 'STREAK HARI INI';

    final streakValue = profile.currentStreak > 0
        ? '${profile.currentStreak} hari'
        : '0 hari';

    final streakSub = streakActive ? 'tetap konsisten!' : 'mulai lagi sekarang';

    final stats = [
      _StatData(
        label: 'TOTAL XP',
        value: _formatNumber(profile.xpTotal),
        sub: 'experience points',
        icon: Icons.bolt_rounded,
        color: t.warning,
      ),
      _StatData(
        label: 'JEWELS',
        value: _formatNumber(profile.jewels),
        sub: 'koin reward',
        icon: Icons.diamond_rounded,
        color: const Color(0xFF38BDF8),
      ),
      _StatData(
        label: streakLabel,
        value: streakValue,
        sub: streakSub,
        icon: Icons.local_fire_department_rounded,
        color: streakActive ? Colors.orange : t.textHint,
      ),
      _StatData(
        label: 'REKOR STREAK',
        value: '${profile.longestStreak} hari',
        sub: 'pencapaian terbaik',
        icon: Icons.emoji_events_rounded,
        color: Colors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final gutter = 12 * (crossAxisCount - 1);
        final childWidth = (constraints.maxWidth - gutter) / crossAxisCount;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats
              .map(
                (s) => SizedBox(
                  width: childWidth,
                  child: _StatCard(t: t, data: s),
                ),
              )
              .toList(),
        );
      },
    ).animate().fadeIn(delay: 100.ms);
  }
}

class _StatData {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatData({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final BloomTheme t;
  final _StatData data;
  const _StatCard({required this.t, required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: data.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border, width: 2),
      boxShadow: [
        BoxShadow(color: t.border, offset: const Offset(3, 3), blurRadius: 0),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(data.icon, color: data.color, size: 20)),
        ),
        const SizedBox(height: 12),
        Text(
          data.label,
          style: GoogleFonts.nunito(
            color: data.color.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.value,
          style: GoogleFonts.nunito(
            color: data.color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          data.sub,
          style: GoogleFonts.nunito(
            color: t.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ── Learning Summary ───────────────────────────────────────────────────────────

class _LearningSummary extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  const _LearningSummary({required this.t, required this.profile});

  @override
  Widget build(BuildContext context) {
    final courseRate = profile.coursesEnrolled > 0
        ? (profile.coursesCompleted / profile.coursesEnrolled * 100).round()
        : 0;
    final quizPassRate = profile.quizAttempts > 0
        ? (profile.quizPassed / profile.quizAttempts * 100).round()
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: t.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    'Ringkasan Belajar',
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: t.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: t.accent.withAlpha(76)),
                ),
                child: Text(
                  '${profile.lessonsCompleted} lesson selesai',
                  style: GoogleFonts.nunito(
                    color: t.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressBlock(
            t: t,
            label: 'Progres Course',
            value: '${profile.coursesCompleted}/${profile.coursesEnrolled}',
            pct: courseRate,
            sub: '$courseRate% course sudah dituntaskan',
          ),
          const SizedBox(height: 12),
          _ProgressBlock(
            t: t,
            label: 'Pass Rate Quiz',
            value: '${profile.quizPassed}/${profile.quizAttempts}',
            pct: quizPassRate,
            sub: '$quizPassRate% quiz berhasil dilalui',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (_, constraints) {
              final childWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.track_changes_rounded,
                      iconColor: t.success,
                      bgColor: t.success.withAlpha(25),
                      borderColor: t.success.withAlpha(76),
                      label: 'Skor Rata-rata',
                      value: '${profile.avgScore.round()}%',
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.emoji_events_rounded,
                      iconColor: t.warning,
                      bgColor: t.warning.withAlpha(25),
                      borderColor: t.warning.withAlpha(76),
                      label: 'Skor Terbaik',
                      value: '${profile.bestScore.round()}%',
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.check_circle_rounded,
                      iconColor: t.accent,
                      bgColor: t.accent.withAlpha(25),
                      borderColor: t.accent.withAlpha(76),
                      label: 'Quiz Attempt',
                      value: _formatNumber(profile.quizAttempts),
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.menu_book_rounded,
                      iconColor: Colors.deepPurple,
                      bgColor: Colors.deepPurple.withAlpha(25),
                      borderColor: Colors.deepPurple.withAlpha(76),
                      label: 'Lesson Selesai',
                      value: _formatNumber(profile.lessonsCompleted),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _ProgressBlock extends StatelessWidget {
  final BloomTheme t;
  final String label, value, sub;
  final int pct;
  const _ProgressBlock({
    required this.t,
    required this.label,
    required this.value,
    required this.pct,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: t.bgSurface2.withAlpha(102),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border.withAlpha(25), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                color: t.textSecondary.withAlpha(153),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: t.border.withAlpha(38)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct / 100.0,
              backgroundColor: t.bgSurface3,
              valueColor: AlwaysStoppedAnimation(t.accent),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: GoogleFonts.nunito(
            color: t.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final Color iconColor;
  final Color bgColor, borderColor;
  final String label, value;
  const _MiniStat({
    required this.t,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: t.bgSurface2.withAlpha(102),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: t.border.withAlpha(25), width: 2),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 16)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.nunito(
                    color: t.textSecondary.withAlpha(140),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  value,
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

// ── Recent Activity ────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  final BloomTheme t;
  final List<RecentXpEntry> entries;
  const _RecentActivity({required this.t, required this.entries});

  static const _sourceConfig = {
    'quiz': {'icon': Icons.code_rounded, 'label': 'Quiz', 'color': null},
    'lesson': {
      'icon': Icons.menu_book_rounded,
      'label': 'Lesson',
      'color': null,
    },
    'bonus': {
      'icon': Icons.card_giftcard_rounded,
      'label': 'Bonus',
      'color': null,
    },
  };

  String _dateLabel(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(d.year, d.month, d.day);
    if (dateDay == today) return 'Hari ini';
    if (dateDay == yesterday) return 'Kemarin';
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

  String _timeStr(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalXp = entries.fold<int>(0, (sum, e) => sum + e.xpEarned);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: t.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: t.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: t.warning.withAlpha(90)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: t.warning, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '+${_formatNumber(totalXp)} XP',
                      style: GoogleFonts.nunito(
                        color: t.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            _emptyActivity(t)
          else
            ...entries.map((e) => _buildEntry(t, e)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEntry(BloomTheme t, RecentXpEntry e) {
    final cfg = _sourceConfig[e.sourceType] ?? _sourceConfig['lesson']!;
    final icon = cfg['icon'] as IconData;
    final label = cfg['label'] as String;

    Color iconColor;
    Color bgColor;
    switch (e.sourceType) {
      case 'quiz':
        iconColor = t.accent;
        bgColor = t.accent.withAlpha(25);
        break;
      case 'bonus':
        iconColor = Colors.deepPurple;
        bgColor = Colors.deepPurple.withAlpha(25);
        break;
      default:
        iconColor = t.success;
        bgColor = t.success.withAlpha(25);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.bgSurface2.withAlpha(102),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border.withAlpha(25), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withAlpha(76)),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_dateLabel(e.createdAt)} • ${_timeStr(e.createdAt)}',
                    style: GoogleFonts.nunito(color: t.textHint, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: t.warning.withAlpha(90), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: t.warning, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '+${_formatNumber(e.xpEarned)}',
                    style: GoogleFonts.nunito(
                      color: t.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _emptyActivity(BloomTheme t) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40),
    decoration: BoxDecoration(
      color: t.bgSurface2.withAlpha(76),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.border.withAlpha(50), width: 2),
    ),
    child: Column(
      children: [
        Icon(Icons.bolt_rounded, size: 40, color: t.textHint.withAlpha(63)),
        const SizedBox(height: 8),
        Text(
          'Belum ada aktivitas terbaru',
          style: GoogleFonts.nunito(
            color: t.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selesaikan quiz atau lesson untuk mulai kumpulkan XP.',
          style: GoogleFonts.nunito(color: t.textHint, fontSize: 11),
        ),
      ],
    ),
  );
}

// ── Account Section ────────────────────────────────────────────────────────────

class _AccountSection extends ConsumerStatefulWidget {
  final BloomTheme t;
  final String email;
  const _AccountSection({required this.t, required this.email});

  @override
  ConsumerState<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<_AccountSection> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotifPref();
  }

  Future<void> _loadNotifPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (mounted) setState(() => _notificationsEnabled = value);

    final api = ref.read(apiClientProvider);
    if (value) {
      await FcmService.registerToken(api);
    } else {
      await FcmService.unregisterToken(api);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, color: t.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Akun & Keamanan',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.bgSurface2.withAlpha(102),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border.withAlpha(25), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: t.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.accent.withAlpha(76)),
                  ),
                  child: Icon(Icons.email_rounded, color: t.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMAIL LOGIN',
                        style: GoogleFonts.nunito(
                          color: t.textSecondary.withAlpha(140),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.bgSurface2.withAlpha(102),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border.withAlpha(25), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: t.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.accent.withAlpha(76)),
                  ),
                  child:
                      Icon(Icons.notifications_outlined, color: t.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Terima notifikasi belajar',
                        style: GoogleFonts.nunito(
                          color: t.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeThumbColor: t.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Bounceable(
                  onTap: () => _showChangePassword(context, ref, t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: t.border,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: t.accentText,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ubah Password',
                            style: GoogleFonts.nunito(
                              color: t.accentText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Bounceable(
                  onTap: () => _showLogoutConfirm(context, ref, t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: t.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: t.error.withAlpha(76),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: t.border,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: t.error, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Keluar',
                            style: GoogleFonts.nunito(
                              color: t.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 12),
          Text(
            'Untuk keamanan, ganti password secara berkala dan pastikan tidak '
            'menggunakan password yang sama dengan akun lain.',
            style: GoogleFonts.nunito(color: t.textHint, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

// ── Dialogs ────────────────────────────────────────────────────────────────────

Future<void> _showEditProfile(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
  ProfileModel profile,
) {
  final nameController = TextEditingController(text: profile.name);
  final emailController = TextEditingController(text: profile.email);
  final formKey = GlobalKey<FormState>();
  final initials = profile.initials;
  bool isLoading = false;
  File? avatarFile;
  String? avatarUrl = profile.avatar;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bgSurface,
            border: Border.all(color: t.border, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.border,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Edit Profile',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                      'Update foto, nama, dan email kamu di sini.',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Avatar ──────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: t.border, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: t.border,
                                  offset: const Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: t.bgSurface2,
                              backgroundImage: avatarFile != null
                                  ? FileImage(avatarFile!)
                                  : (avatarUrl != null
                                        ? NetworkImage(avatarUrl!)
                                        : null),
                              child: avatarFile == null && avatarUrl == null
                                  ? Text(
                                      initials,
                                      style: GoogleFonts.nunito(
                                        color: t.accent,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (avatarFile != null || avatarUrl != null)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  avatarFile = null;
                                  avatarUrl = null;
                                }),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: t.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: t.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Bounceable(
                        onTap: () async {
                          final result = await AssetPicker.pickAssets(
                            ctx,
                            pickerConfig: const AssetPickerConfig(
                              maxAssets: 1,
                              requestType: RequestType.image,
                            ),
                          );
                          final asset = result?.firstOrNull;
                          if (asset != null) {
                            final file = await asset.file;
                            if (file != null) {
                              final cropped = await Navigator.of(ctx).push<File>(
                                MaterialPageRoute(
                                  builder: (_) => CropScreen(
                                    imageFile: file,
                                    t: t,
                                  ),
                                ),
                              );
                              if (cropped != null) {
                                setState(() => avatarFile = cropped);
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withAlpha(179),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.upload_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                avatarFile != null || avatarUrl != null
                                    ? 'Ganti Foto Ah'
                                    : 'Upload Foto Kece',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Format JPG/PNG/GIF, max 5MB ya!',
                        style: GoogleFonts.nunito(
                          color: t.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nama',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintStyle: GoogleFonts.nunito(color: t.textHint),
                    filled: true,
                    fillColor: t.bgSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: emailController,
                  style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintStyle: GoogleFonts.nunito(color: t.textHint),
                    filled: true,
                    fillColor: t.bgSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Bounceable(
                    onTap: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => isLoading = true);
                            try {
                              String? uploadedUrl;
                              if (avatarFile != null) {
                                uploadedUrl =
                                    await CloudinaryService.uploadImage(
                                      avatarFile!.path,
                                    );
                              }
                              final updateData = <String, dynamic>{
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                              };
                              if (avatarFile != null) {
                                updateData['avatar'] = uploadedUrl!;
                              } else if (avatarUrl == null &&
                                  profile.avatar != null) {
                                updateData['avatar'] = '';
                              }
                              await ref
                                  .read(profileDsProvider)
                                  .updateProfile(updateData);
                              ref.invalidate(profileProvider);
                              ref.read(authProvider.notifier).refreshMe();
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Profil berhasil diperbarui',
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: t.accentText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Menyimpan...',
                                    style: GoogleFonts.nunito(
                                      color: t.accentText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded, color: t.accentText, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Simpan',
                                    style: GoogleFonts.nunito(
                                      color: t.accentText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Bounceable(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded, color: t.textSecondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Batal',
                              style: GoogleFonts.nunito(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
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
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showChangePassword(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
) {
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bgSurface,
            border: Border.all(color: t.border, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.border,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 20, color: t.textPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ubah Password',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: t.textPrimary.withAlpha(76),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pakai password yang kuat dan jangan bagikan ke siapa pun.',
                  style: GoogleFonts.nunito(
                    color: t.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: currentPwController,
                  obscureText: true,
                  style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password Sekarang',
                    labelStyle: GoogleFonts.nunito(color: t.textSecondary),
                    filled: true,
                    fillColor: t.bgSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Masukkan password lama' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPwController,
                  obscureText: true,
                  style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    labelStyle: GoogleFonts.nunito(color: t.textSecondary),
                    filled: true,
                    fillColor: t.bgSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Masukkan password baru';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPwController,
                  obscureText: true,
                  style: GoogleFonts.nunito(color: t.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    labelStyle: GoogleFonts.nunito(color: t.textSecondary),
                    filled: true,
                    fillColor: t.bgSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v != newPwController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Bounceable(
                    onTap: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => isLoading = true);
                            try {
                              final error = await ref
                                  .read(authProvider.notifier)
                                  .changePassword(
                                    currentPwController.text,
                                    newPwController.text,
                                  );
                              if (error != null) {
                                setState(() => isLoading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error,
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password berhasil diubah!',
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } catch (_) {
                              setState(() => isLoading = false);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: t.accentText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Menyimpan...',
                                    style: GoogleFonts.nunito(
                                      color: t.accentText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded, color: t.accentText, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Simpan',
                                    style: GoogleFonts.nunito(
                                      color: t.accentText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Bounceable(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded, color: t.textSecondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Batal',
                              style: GoogleFonts.nunito(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
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
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Logout Confirm Dialog ───────────────────────────────────────────────────────

Future<void> _showLogoutConfirm(
  BuildContext context,
  WidgetRef ref,
  BloomTheme t,
) {
  bool isLoading = false;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bgSurface,
            border: Border.all(color: t.border, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.border,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Icon(Icons.logout_rounded, size: 48, color: t.error),
              const SizedBox(height: 16),
              Text(
                'Keluar',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah kamu yakin ingin keluar?',
                style: GoogleFonts.nunito(
                  color: t.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Bounceable(
                  onTap: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          await ref.read(authProvider.notifier).logout();
                          ref.read(navIndexProvider.notifier).state = 0;
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (context.mounted) context.go('/login');
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: t.error.withAlpha(200),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Keluar',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Bounceable(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(179),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Batal',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Shared ─────────────────────────────────────────────────────────────────────

String _formatNumber(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final parts = <String>[];
  for (int i = s.length; i > 0; i -= 3) {
    parts.insert(0, s.substring(i > 3 ? i - 3 : 0, i));
  }
  return parts.join('.');
}

Widget _skeleton(BloomTheme t) => Column(
  children: [
    _Skeleton(t: t, height: 240),
    const SizedBox(height: 16),
    _Skeleton(t: t, height: 100),
    const SizedBox(height: 16),
    _Skeleton(t: t, height: 320),
    const SizedBox(height: 16),
    _Skeleton(t: t, height: 180),
  ],
);

Widget _retryCard(BloomTheme t, VoidCallback onRetry) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: t.bgSurface2,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: t.border),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline_rounded, color: t.error, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          'Gagal memuat profil',
          style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 12),
        ),
      ),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: t.accent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'Retry',
            style: GoogleFonts.nunito(
              color: t.accentText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  ),
);

class _Skeleton extends StatelessWidget {
  final BloomTheme t;
  final double height;
  const _Skeleton({required this.t, required this.height});
  @override
  Widget build(BuildContext context) =>
      Container(
            height: height,
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(18),
            ),
          )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: t.bgSurface3);
}
