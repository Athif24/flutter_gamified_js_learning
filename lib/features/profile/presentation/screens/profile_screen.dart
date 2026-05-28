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
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../store/presentation/providers/store_provider.dart';
import '../../../store/presentation/providers/reward_pool_provider.dart';
import '../widgets/theme_picker_sheet.dart';
import '../widgets/profile_skeleton.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';
import '../widgets/crop_screen.dart';
import '../../../../shared/widgets/game_3d_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SilentRefreshMixin<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(profileFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(profileProvider);
        await ref.read(profileProvider.future);
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 4 && next == 4) {
        ref.invalidate(profileProvider);
        _silentRefresh();
      }
    });

    final t = ref.watch(currentThemeProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: profileAsync.when(
                loading: () => ProfileSkeleton(t: t),
                error: (e, _) => ErrorBody(
                  t: t,
                  icon: iconForError(e),
                  title: AppStrings.errLoadProfile,
                  message: sanitizeErrorMessage(e),
                  onRetry: () {
                    setShowSlowIndicator(true);
                    _silentRefresh();
                  },
                ),
                data: (p) => RefreshIndicator(
                  onRefresh: () async {
                    await _silentRefresh();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      children: [
                        _ProfileHeroCard(t: t, profile: p, ref: ref),
                        const SizedBox(height: 16),
                        _ProfileStatsGrid(t: t, profile: p),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (_, constraints) {
                            final isTablet = constraints.maxWidth > 600;
                            if (isTablet) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _LearningSummary(t: t, profile: p),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _RecentActivity(
                                      t: t,
                                      entries: p.recentXp,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _LearningSummary(t: t, profile: p),
                                const SizedBox(height: 16),
                                _RecentActivity(t: t, entries: p.recentXp),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _AccountSection(t: t, email: p.email),
                      ],
                    ),
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
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    final initials = profile.initials;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.textPrimary, width: 3),
                ),
                child: CircleAvatar(
                  radius: rs(40).roundToDouble(),
                  backgroundColor: t.bgSurface.withValues(alpha: 0.3),
                  backgroundImage: profile.avatar != null
                      ? NetworkImage(profile.avatar!)
                      : null,
                  child: profile.avatar == null
                      ? Text(
                          initials,
                          style: GoogleFonts.nunito(
                            color: t.primary,
                            fontSize: rs(28),
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  profile.name,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: rs(24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  profile.email,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent.withValues(alpha: 0.8),
                    fontSize: rs(14),
                  ),
                ),
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
                          color: t.primaryContent,
                          fontSize: rs(12),
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
                          size: rs(12),
                          color: t.primaryContent.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bergabung ${profile.daysSinceJoined} hari lalu',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontSize: rs(12),
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
                onTap: () {
                  ref.read(soundProvider).playClick();
                  _showEditProfile(context, ref, t, profile);
                },
                hitTestBehavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: t.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.textPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: t.textPrimary,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: t.secondaryContent,
                        size: rs(16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.nunito(
                          color: t.secondaryContent,
                          fontSize: rs(14),
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
            onTap: () {
              ref.read(soundProvider).playClick();
              showThemePicker(context, ref);
            },
            hitTestBehavior: HitTestBehavior.opaque,
            child: Container(
              width: rs(36),
              height: rs(36),
              decoration: BoxDecoration(
                color: t.bgSurface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.textPrimary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.palette_rounded,
                color: t.textPrimary,
                size: rs(18),
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

    final streakLabel = 'STREAK HARI INI';

    final streakValue = profile.currentStreak > 0
        ? '${profile.currentStreak} hari'
        : '0 hari';

    final streakSub = streakActive ? 'tetap konsisten!' : 'mulai lagi sekarang';

    final stats = [
      _StatData(
        label: 'TOTAL XP',
        value: formatNumber(profile.xpTotal),
        sub: 'experience points',
        icon: Icons.bolt_rounded,
        color: t.warning,
      ),
      _StatData(
        label: 'JEWELS',
        value: formatNumber(profile.jewels),
        sub: 'koin reward',
        icon: Icons.diamond_rounded,
        color: t.info,
      ),
      _StatData(
        label: streakLabel,
        value: streakValue,
        sub: streakSub,
        icon: Icons.local_fire_department_rounded,
        color: streakActive ? t.warning : t.textHint,
      ),
      _StatData(
        label: 'REKOR STREAK',
        value: '${profile.longestStreak} hari',
        sub: 'pencapaian terbaik',
        icon: Icons.emoji_events_rounded,
        color: t.primary,
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
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          data.color.withValues(alpha: 0.08),
          t.bgSurface,
        ),
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
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: data.color.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(data.icon, color: data.color, size: rs(20)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
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
              data.value,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: rs(20),
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.sub,
            style: GoogleFonts.nunito(
              color: t.textPrimary.withValues(alpha: 0.5),
              fontSize: rs(11),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Learning Summary ───────────────────────────────────────────────────────────

class _LearningSummary extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  const _LearningSummary({required this.t, required this.profile});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
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
              Icon(Icons.menu_book_rounded, color: t.primary, size: rs(20)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    'Ringkasan Belajar',
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: rs(16),
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
                  color: t.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: t.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '${profile.lessonsCompleted} lesson selesai',
                  style: GoogleFonts.nunito(
                    color: t.primary,
                    fontSize: rs(11),
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
                      bgColor: t.success.withValues(alpha: 0.1),
                      borderColor: t.success.withValues(alpha: 0.3),
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
                      bgColor: t.warning.withValues(alpha: 0.1),
                      borderColor: t.warning.withValues(alpha: 0.3),
                      label: 'Skor Terbaik',
                      value: '${profile.bestScore.round()}%',
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.check_circle_rounded,
                      iconColor: t.primary,
                      bgColor: t.primary.withValues(alpha: 0.1),
                      borderColor: t.primary.withValues(alpha: 0.3),
                      label: 'Quiz Attempt',
                      value: formatNumber(profile.quizAttempts),
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: _MiniStat(
                      t: t,
                      icon: Icons.menu_book_rounded,
                      iconColor: t.primary,
                      bgColor: t.primary.withValues(alpha: 0.1),
                      borderColor: t.textPrimary.withValues(alpha: 0.35),
                      label: 'Lesson Selesai',
                      value: formatNumber(profile.lessonsCompleted),
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
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgSurface2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: t.textSecondary.withValues(alpha: 0.6),
                  fontSize: rs(12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: rs(14),
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
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct / 100.0,
                backgroundColor: t.bgSurface3,
                valueColor: AlwaysStoppedAnimation(t.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.nunito(
              color: t.textHint,
              fontSize: rs(11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.bgSurface2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: rs(32),
            height: rs(32),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: rs(16)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: t.textSecondary.withValues(alpha: 0.55),
                      fontSize: rs(10),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: rs(14),
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
}

// ── Recent Activity ────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  final BloomTheme t;
  final List<RecentXpEntry> entries;
  const _RecentActivity({required this.t, required this.entries});

  static const _sourceConfig = {
    'quiz': {'icon': Icons.code_rounded, 'label': 'Quiz'},
    'lesson': {
      'icon': Icons.menu_book_rounded,
      'label': 'Lesson',
    },
    'bonus': {
      'icon': Icons.card_giftcard_rounded,
      'label': 'Bonus',
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
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    final totalXp = entries.fold<int>(0, (sum, e) => sum + e.xpEarned);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: t.accent, size: rs(20)),
              const SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: rs(16),
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
                  color: t.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: t.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: t.warning, size: rs(14)),
                    const SizedBox(width: 3),
                    Text(
                      '+${formatNumber(totalXp)} XP',
                      style: GoogleFonts.nunito(
                        color: t.warning,
                        fontSize: rs(11),
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
            _emptyActivity(t, w)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _buildEntry(t, entries[i], w),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  static double _rsEntry(double px, double screenW) =>
      px * (screenW / 390).clamp(0.8, 1.3);

  Widget _buildEntry(BloomTheme t, RecentXpEntry e, double screenW) {
    double rs(double px) => _rsEntry(px, screenW);
    final cfg = _sourceConfig[e.sourceType] ?? _sourceConfig['lesson']!;
    final icon = cfg['icon'] as IconData;
    final label = cfg['label'] as String;

    Color iconColor;
    Color bgColor;
    switch (e.sourceType) {
      case 'quiz':
        iconColor = t.primary;
        bgColor = t.primary.withValues(alpha: 0.1);
        break;
      case 'bonus':
        iconColor = t.secondary;
        bgColor = t.secondary.withValues(alpha: 0.1);
        break;
      default:
        iconColor = t.success;
        bgColor = t.success.withValues(alpha: 0.1);
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.bgSurface2.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: t.textPrimary.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: rs(36),
              height: rs(36),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: t.textPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(icon, color: iconColor, size: rs(16)),
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
                      fontSize: rs(14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_dateLabel(e.createdAt)} • ${_timeStr(e.createdAt)}',
                    style: GoogleFonts.nunito(
                      color: t.textHint,
                      fontSize: rs(11),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: t.textPrimary.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: t.warning, size: rs(14)),
                  const SizedBox(width: 3),
                  Text(
                    '+${formatNumber(e.xpEarned)}',
                    style: GoogleFonts.nunito(
                      color: t.warning,
                      fontSize: rs(14),
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

  Widget _emptyActivity(BloomTheme t, double screenW) {
    double rs(double px) => _rsEntry(px, screenW);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
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
        children: [
          Icon(Icons.bolt_rounded, size: rs(40), color: t.mutedText),
          const SizedBox(height: 8),
          Text(
            'Belum ada aktivitas terbaru',
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: rs(13),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selesaikan quiz atau lesson untuk mulai kumpulkan XP.',
            style: GoogleFonts.nunito(color: t.mutedText, fontSize: rs(11)),
          ),
        ],
      ),
    );
  }
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
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    final t = widget.t;
    final sound = ref.watch(soundProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.shield_rounded, color: t.accent, size: rs(20)),
              const SizedBox(width: 8),
              Text(
                'Akun & Keamanan',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: rs(16),
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
              color: t.bgSurface2.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: rs(40),
                  height: rs(40),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    Icons.email_rounded,
                    color: t.primary,
                    size: rs(20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMAIL LOGIN',
                        style: GoogleFonts.nunito(
                          color: t.textSecondary.withValues(alpha: 0.55),
                          fontSize: rs(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: rs(14),
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
              color: t.bgSurface2.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: rs(40),
                  height: rs(40),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: t.textPrimary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: t.primary,
                    size: rs(20),
                  ),
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
                          fontSize: rs(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Terima notifikasi belajar',
                        style: GoogleFonts.nunito(
                          color: t.textHint,
                          fontSize: rs(12),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return t.primary;
                    return t.textHint;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.bgSurface2.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: t.textPrimary.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: rs(40),
                      height: rs(40),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: t.textPrimary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        sound.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: t.primary,
                        size: rs(20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suara Efek',
                            style: GoogleFonts.nunito(
                              color: t.textPrimary,
                              fontSize: rs(14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Feedback suara aplikasi',
                            style: GoogleFonts.nunito(
                              color: t.textHint,
                              fontSize: rs(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !sound.isMuted,
                      onChanged: (v) {
                        if (sound.isMuted) {
                          ref.read(soundProvider).playClick();
                        }
                        ref.read(soundProvider).setMuted(!v);
                      },
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return t.primary;
                        }
                        return t.textHint;
                      }),
                    ),
                  ],
                ),
                if (!sound.isMuted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.volume_down_rounded,
                          color: t.mutedText, size: rs(16)),
                      Expanded(
                        child: Slider(
                          value: sound.volume,
                          min: 0,
                          max: 1,
                          activeColor: t.primary,
                          inactiveColor: t.border,
                          onChanged: (v) {
                            ref.read(soundProvider).setVolume(v);
                          },
                        ),
                      ),
                      Icon(Icons.volume_up_rounded,
                          color: t.mutedText, size: rs(16)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Bounceable(
                  onTap: () {
                    ref.read(soundProvider).playClick();
                    _showChangePassword(context, ref, t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: t.textPrimary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: t.textPrimary,
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
                            color: t.primaryContent,
                            size: rs(16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ubah Password',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontSize: rs(14),
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
                child: Semantics(
                  label: 'Keluar dari aplikasi',
                  child: Bounceable(
                    onTap: () {
                      ref.read(soundProvider).playClick();
                      _showLogoutConfirm(context, ref, t);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: t.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.textPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
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
                              Icons.logout_rounded,
                              color: t.bgPrimary,
                              size: rs(16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Keluar',
                              style: GoogleFonts.nunito(
                                color: t.bgPrimary,
                                fontSize: rs(14),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
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
            style: GoogleFonts.nunito(color: t.textHint, fontSize: rs(12)),
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
            border: Border.all(color: t.textPrimary, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: const Offset(3, 3),
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

                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t.textPrimary,
                                  width: 3,
                                ),
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
                                          color: t.primary,
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
                                  onTap: () {
                                    ref.read(soundProvider).playClick();
                                    setState(() {
                                      avatarFile = null;
                                      avatarUrl = null;
                                    });
                                  },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: t.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: t.textPrimary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: t.bgPrimary,
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
                            ref.read(soundProvider).playClick();
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
                              if (file != null && ctx.mounted) {
                                final cropped = await Navigator.of(ctx)
                                    .push<File>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CropScreen(imageFile: file, t: t),
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
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: t.textPrimary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: t.textPrimary,
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upload_rounded,
                                  size: 14,
                                  color: t.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  avatarFile != null || avatarUrl != null
                                      ? 'Ganti Foto Ah'
                                      : 'Upload Foto Kece',
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
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
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.nunito(color: t.textHint),
                      filled: true,
                      fillColor: t.bgSurface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.textPrimary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.textPrimary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
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
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.nunito(color: t.textHint),
                      filled: true,
                      fillColor: t.bgSurface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.textPrimary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.textPrimary, width: 2),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Game3DButton(
                          label: 'Batal',
                          color: t.secondary,
                          shadowColor: t.textPrimary,
                          textColor: t.secondaryContent,
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Game3DButton(
                          label: 'Simpan',
                          color: t.primary,
                          shadowColor: t.textPrimary,
                          textColor: t.primaryContent,
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Profil berhasil diperbarui',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          backgroundColor: t.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                          backgroundColor: t.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          isLoading: isLoading,
                        ),
                      ),
                    ],
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
    builder: (ctx) {
      bool showPassword = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            content: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.bgSurface,
                border: Border.all(color: t.textPrimary, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: t.textPrimary,
                    offset: const Offset(3, 3),
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
                          Icon(
                            Icons.lock_rounded,
                            size: 20,
                            color: t.textPrimary,
                          ),
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
                            onTap: () {
                              ref.read(soundProvider).playClick();
                              Navigator.of(ctx).pop();
                            },
                            child: Semantics(
                              label: 'Tutup dialog',
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: t.textPrimary.withValues(alpha: 0.3),
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
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password Sekarang',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Masukkan password lama'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPwController,
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Masukkan password baru';
                          }
                          if (v.length < 6) return 'Minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPwController,
                        obscureText: !showPassword,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          labelStyle: GoogleFonts.nunito(
                            color: t.textSecondary,
                          ),
                          filled: true,
                          fillColor: t.bgSurface2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: t.textPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v != newPwController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: Text(
                          'Tampilkan Password',
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: showPassword,
                        onChanged: (value) =>
                            setState(() => showPassword = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: t.textPrimary, width: 2),
                        activeColor: t.primary,
                        checkColor: t.primaryContent,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Game3DButton(
                              label: 'Batal',
                              color: t.secondary,
                              shadowColor: t.textPrimary,
                              textColor: t.secondaryContent,
                              onTap: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Game3DButton(
                              label: 'Simpan',
                              color: t.primary,
                              shadowColor: t.textPrimary,
                              textColor: t.primaryContent,
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
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
                                                backgroundColor: t.error,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        if (ctx.mounted) {
                                          Navigator.of(ctx).pop();
                                        }
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Password berhasil diubah!',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              backgroundColor: t.success,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (_) {
                                        setState(() => isLoading = false);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Terjadi kesalahan. Silakan coba lagi.',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor: t.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

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
            border: Border.all(color: t.textPrimary, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: const Offset(3, 3),
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
                style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Game3DButton(
                      label: 'Batal',
                      color: t.secondary,
                      shadowColor: t.textPrimary,
                      textColor: t.secondaryContent,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Game3DButton(
                      label: 'Keluar',
                      color: t.error,
                      shadowColor: t.textPrimary,
                      textColor: t.bgPrimary,
                      onTap: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              await ref.read(authProvider.notifier).logout();

                              invalidateGamificationProviders(ref);
                              ref.invalidate(coursesProvider);
                              ref.invalidate(courseDetailProvider);
                              ref.invalidate(storeItemsProvider);
                              ref.invalidate(inventoryProvider);
                              ref.invalidate(rewardPoolsProvider);
                              ref.read(navIndexProvider.notifier).state = 0;

                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (context.mounted) context.go('/login');
                            },
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
