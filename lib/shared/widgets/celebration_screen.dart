import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import '../../features/courses/data/models/gamification_models.dart';
import '../providers/gamification_providers.dart';
import '../services/sound_service.dart';
import '../../core/utils/responsive_utils.dart';

class CelebrationScreen extends ConsumerStatefulWidget {
  final int xpEarned;
  final int jewelsEarned;
  final StreakInfo? streak;
  final LevelUpInfo? levelUp;
  final List<BadgeInfo> badges;
  final VoidCallback? onContinue;
  final String? courseId;
  final String? quizId;

  const CelebrationScreen({
    super.key,
    required this.xpEarned,
    this.jewelsEarned = 0,
    this.streak,
    this.levelUp,
    this.badges = const [],
    this.onContinue,
    this.courseId,
    this.quizId,
  });

  @override
  ConsumerState<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends ConsumerState<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  bool _showContent = false;

  bool get _hasLevelUp => widget.levelUp?.leveledUp == true;
  bool get _hasBadges => widget.badges.isNotEmpty;
  bool get _hasStreakMilestone =>
      widget.streak != null && _isStreakMilestone(widget.streak!.currentStreak);
  bool get _isSuperCelebration =>
      _hasLevelUp ||
      widget.badges.length >= 2 ||
      (widget.streak?.currentStreak ?? 0) >= 14 ||
      widget.xpEarned >= 120;

  String get _title {
    if (_hasLevelUp) return 'Naik Level! 🚀';
    if (_isSuperCelebration) return 'Legendary Finish! 🌟';
    if (_hasBadges) return 'Lencana Baru! 🏅';
    return 'Bagus Sekali! 🎉';
  }

  String get _subtitle {
    if (_hasLevelUp) {
      return 'Selamat, kamu naik ke ${widget.levelUp!.newLevelName ?? "level baru"}!';
    }
    if (_isSuperCelebration) {
      return 'Performa kamu lagi panas. Pertahankan momentumnya!';
    }
    return 'Kamu telah menyelesaikan sesi belajar.';
  }

  bool _isStreakMilestone(int n) => [3, 7, 14, 30, 60, 100].contains(n);

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.forward();

      final sound = ref.read(soundProvider);
      sound.playReward().catchError(
        (e) => debugPrint('[Celebration] playReward: $e'),
      );
      if (_hasLevelUp) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            sound.playLevelUp().catchError(
              (e) => debugPrint('[Celebration] playLevelUp: $e'),
            );
          }
        });
      }

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showContent = true);
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.accent.withAlpha(230), t.bgPrimary],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (_isSuperCelebration)
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, _) {
                      final s = MediaQuery.of(context).size;
                      return CustomPaint(
                        painter: _ConfettiPainter(
                          particles: _getParticles(t, s),
                          progress: _confettiController.value,
                        ),
                        size: s,
                      );
                    },
                  ),
                ),

              if (_isSuperCelebration) _buildScreenFlash(t),

              if (_showContent)
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeroIcon(t),
                        SizedBox(height: S.scale(context, 20)),
                        if (_isSuperCelebration) _buildSuperBadge(t),
                        Text(
                          _title,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: S.font(context, 32),
                            fontWeight: FontWeight.w900,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        SizedBox(height: S.scale(context, 8)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _subtitle,
                            style: GoogleFonts.nunito(
                              color: Colors.white.withAlpha(200),
                              fontSize: S.font(context, 13),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        SizedBox(height: S.scale(context, 32)),

                        if (widget.xpEarned > 0 || widget.jewelsEarned > 0)
                          _buildRewardRow(t),
                        if (widget.xpEarned > 0 || widget.jewelsEarned > 0)
                          SizedBox(height: S.scale(context, 12)),

                        if (_hasLevelUp) ...[
                          _buildLevelUpCard(t),
                          SizedBox(height: S.scale(context, 12)),
                        ],

                        if (_hasStreakMilestone && widget.streak != null) ...[
                          _buildStreakMilestoneCard(t),
                          SizedBox(height: S.scale(context, 12)),
                        ],
                        if (!_hasStreakMilestone &&
                            widget.streak != null &&
                            widget.streak!.currentStreak > 1) ...[
                          _buildStreakSimpleCard(t),
                          SizedBox(height: S.scale(context, 12)),
                        ],

                        if (_hasBadges) ...[
                          _buildBadgesSection(t),
                          SizedBox(height: S.scale(context, 12)),
                        ],

                        SizedBox(height: S.scale(context, 40)),
                        _buildContinueButton(t),
                        SizedBox(height: S.scale(context, 32)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }





  // ── Confetti helpers ──────────────────────────────────────────────────────

  List<_ConfettiParticle>? _particles;
  Size? _lastConfettiSize;

  List<_ConfettiParticle> _getParticles(BloomTheme t, Size s) {
    if (_particles == null || _lastConfettiSize != s) {
      _particles = _generateParticles(t, s);
      _lastConfettiSize = s;
    }
    return _particles!;
  }

  List<_ConfettiParticle> _generateParticles(BloomTheme t, Size s) {
    final rng = Random(42);
    final list = <_ConfettiParticle>[];
    var index = 0;

    void addLayer({
      required int count,
      required double minDelay,
      required double maxDelay,
      required int minDrift,
      required int maxDrift,
      required double minSize,
      required double maxSize,
      required List<Color> colors,
      required double rectWHRatio,
      required double endYFrac,
    }) {
      const emojis = ['⭐', '🎁', '💎', '🔥', '✨'];
      for (int i = 0; i < count; i++) {
        list.add(_ConfettiParticle(
          startX: rng.nextDouble() * s.width,
          delay: minDelay + rng.nextDouble() * (maxDelay - minDelay),
          drift: minDrift + rng.nextDouble() * (maxDrift - minDrift),
          size: minSize + rng.nextDouble() * (maxSize - minSize),
          isEmoji: rng.nextDouble() > 0.5,
          emoji: emojis[rng.nextInt(emojis.length)],
          color: colors[rng.nextInt(colors.length)],
          isRound: rng.nextBool(),
          rectWHRatio: rectWHRatio,
          endYFrac: endYFrac,
          index: index++,
        ));
      }
    }

    addLayer(
      count: 80, minDelay: 0, maxDelay: 0.28,
      minDrift: -22, maxDrift: 22,
      minSize: 5, maxSize: 10,
      colors: [t.accent, t.info, t.warning, t.success],
      rectWHRatio: 1.5, endYFrac: 0.8,
    );
    addLayer(
      count: 72, minDelay: 0, maxDelay: 0.28,
      minDrift: -22, maxDrift: 22,
      minSize: 5, maxSize: 10,
      colors: [t.accent, t.info, t.warning, t.success],
      rectWHRatio: 1.5, endYFrac: 0.8,
    );
    addLayer(
      count: 80, minDelay: 0.3, maxDelay: 0.6,
      minDrift: -30, maxDrift: 30,
      minSize: 6, maxSize: 10,
      colors: [t.warning.withAlpha(200), t.success.withAlpha(200)],
      rectWHRatio: 1.0, endYFrac: 0.85,
    );

    return list;
  }

  Widget _buildScreenFlash(BloomTheme t) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: Container(color: Colors.white.withAlpha(150))
              .animate()
              .then(delay: 600.ms)
              .fade(begin: 0, end: 1, duration: 400.ms)
              .then(delay: 400.ms)
              .fade(begin: 1, end: 0, duration: 400.ms),
        ),
        Container(color: t.warning.withAlpha(100))
            .animate()
            .then(delay: 1200.ms)
            .fade(begin: 0, end: 0.5, duration: 300.ms)
            .then(delay: 300.ms)
            .fade(begin: 0.5, end: 0, duration: 300.ms),
      ],
    );
  }

  Widget _buildHeroIcon(BloomTheme t) {
    return Container(
      width: S.scale(context, 96),
      height: S.scale(context, 96),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _isSuperCelebration ? t.warning : t.accent,
          width: S.scale(context, 4),
        ),
        color: (_isSuperCelebration ? t.warning : t.accent).withAlpha(25),
        boxShadow: _isSuperCelebration
            ? [
                BoxShadow(
                  color: t.warning.withAlpha(150),
                  blurRadius: S.scale(context, 30),
                  spreadRadius: S.scale(context, 5),
                ),
              ]
            : null,
      ),
      child: ExcludeSemantics(
        child: Icon(
          _hasLevelUp ? Icons.auto_awesome_rounded : Icons.emoji_events_rounded,
          size: S.scale(context, 48),
          color: _hasLevelUp ? t.warning : t.accent,
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.82, 0.82),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildSuperBadge(BloomTheme t) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 12),
        vertical: S.scale(context, 4),
      ),
      decoration: BoxDecoration(
        color: t.warning.withAlpha(40),
        borderRadius: BorderRadius.circular(S.scale(context, 50)),
        border: Border.all(
          color: t.warning.withAlpha(100),
          width: S.scale(context, 1),
        ),
      ),
      child: Text(
        'SUPER CELEBRATION',
        style: GoogleFonts.nunito(
          color: t.warning,
          fontSize: S.font(context, 10),
          fontWeight: FontWeight.w900,
          letterSpacing: S.scale(context, 1.8),
        ),
      ),
    ).animate().fadeIn(delay: 220.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildRewardRow(BloomTheme t) {
    return Row(
      children: [
        if (widget.xpEarned > 0)
          Expanded(
            child: _AnimatedRewardCard(
              t: t,
              emoji: '⚡',
              label: 'XP',
              targetValue: widget.xpEarned,
              color: t.warning,
              delay: 500,
              isSuper: _isSuperCelebration,
            ),
          ),
        if (widget.xpEarned > 0 && widget.jewelsEarned > 0)
          SizedBox(width: S.scale(context, 12)),
        if (widget.jewelsEarned > 0)
          Expanded(
            child: _AnimatedRewardCard(
              t: t,
              emoji: '💎',
              label: 'JEWEL',
              targetValue: widget.jewelsEarned,
              color: t.info,
              delay: 580,
              isSuper: _isSuperCelebration,
            ),
          ),
      ],
    );
  }

  Widget _buildLevelUpCard(BloomTheme t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 20),
        vertical: S.scale(context, 14),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.accent.withAlpha(60), t.info.withAlpha(40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(
          color: t.accent.withAlpha(100),
          width: S.scale(context, 1),
        ),
        boxShadow: _isSuperCelebration
            ? [
                BoxShadow(
                  color: t.accent.withAlpha(100),
                  blurRadius: S.scale(context, 20),
                  spreadRadius: S.scale(context, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: t.accent.withAlpha(50),
                  offset: Offset(S.scale(context, 4), S.scale(context, 4)),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            'LEVEL UP',
            style: GoogleFonts.nunito(
              color: t.accent.withAlpha(150),
              fontSize: S.font(context, 10),
              fontWeight: FontWeight.w900,
              letterSpacing: S.scale(context, 1.5),
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Sebelumnya',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withAlpha(100),
                        fontSize: S.font(context, 11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.levelUp!.previousLevelName ?? '—',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withAlpha(150),
                        fontSize: S.font(context, 14),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: S.scale(context, 16)),
                Text(
                  '→',
                  style: GoogleFonts.nunito(
                    color: t.accent,
                    fontSize: S.font(context, 24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: S.scale(context, 16)),
                Column(
                  children: [
                    Text(
                      'Sekarang',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withAlpha(100),
                        fontSize: S.font(context, 11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.levelUp!.newLevelName ?? '—',
                      style: GoogleFonts.nunito(
                        color: t.accent,
                        fontSize: S.font(context, 18),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.levelUp!.jewelsAwarded > 0) ...[
            SizedBox(height: S.scale(context, 12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: S.scale(context, 12),
                vertical: S.scale(context, 4),
              ),
              decoration: BoxDecoration(
                color: t.info.withAlpha(25),
                borderRadius: BorderRadius.circular(S.scale(context, 50)),
                border: Border.all(
                  color: t.info.withAlpha(100),
                  width: S.scale(context, 1),
                ),
              ),
              child: Text(
                '+${widget.levelUp!.jewelsAwarded} Jewel Bonus',
                style: GoogleFonts.nunito(
                  color: t.info,
                  fontSize: S.font(context, 12),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildStreakMilestoneCard(BloomTheme t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 20),
        vertical: S.scale(context, 14),
      ),
      decoration: BoxDecoration(
        color: t.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(
          color: t.accent.withAlpha(100),
          width: S.scale(context, 1),
        ),
        boxShadow: [
          BoxShadow(
            color: t.accent.withAlpha(50),
            offset: Offset(S.scale(context, 4), S.scale(context, 4)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: S.font(context, 40))),
          SizedBox(width: S.scale(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.streak!.currentStreak} hari berturut-turut!',
                    style: GoogleFonts.nunito(
                      color: t.accent,
                      fontSize: S.font(context, 16),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Streak terpanjangmu: ${widget.streak!.longestStreak} hari',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(130),
                      fontSize: S.font(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildStreakSimpleCard(BloomTheme t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 20),
        vertical: S.scale(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: S.scale(context, 1),
        ),
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: S.font(context, 20))),
          SizedBox(width: S.scale(context, 12)),
          Text(
            'Streak: ${widget.streak!.currentStreak} hari',
            style: GoogleFonts.nunito(
              color: Colors.white.withAlpha(180),
              fontSize: S.font(context, 14),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1);
  }

  Widget _buildBadgesSection(BloomTheme t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lencana Baru',
          style: GoogleFonts.nunito(
            color: Colors.white.withAlpha(100),
            fontSize: S.font(context, 10),
            fontWeight: FontWeight.w900,
            letterSpacing: S.scale(context, 1.5),
          ),
        ),
        SizedBox(height: S.scale(context, 8)),
        ...widget.badges.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(bottom: S.scale(context, 8)),
            child:
                Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 16),
                        vertical: S.scale(context, 12),
                      ),
                      decoration: BoxDecoration(
                        color: t.info.withAlpha(25),
                        borderRadius: BorderRadius.circular(
                          S.scale(context, 16),
                        ),
                        border: Border.all(
                          color: t.info.withAlpha(60),
                          width: S.scale(context, 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.info.withAlpha(25),
                            offset: Offset(
                              S.scale(context, 4),
                              S.scale(context, 4),
                            ),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: S.scale(context, 44),
                            height: S.scale(context, 44),
                            decoration: BoxDecoration(
                              color: t.warning.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.warning.withAlpha(80),
                                width: S.scale(context, 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '🏅',
                                style: TextStyle(fontSize: S.font(context, 22)),
                              ),
                            ),
                          ),
                          SizedBox(width: S.scale(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    e.value.name,
                                    style: GoogleFonts.nunito(
                                      color: t.info,
                                      fontSize: S.font(context, 14),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (e.value.description != null)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      e.value.description!,
                                      style: GoogleFonts.nunito(
                                        color: Colors.white.withAlpha(130),
                                        fontSize: S.font(context, 11),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (e.value.jewelsEarned > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: S.scale(context, 8),
                                vertical: S.scale(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: t.info.withAlpha(25),
                                borderRadius: BorderRadius.circular(
                                  S.scale(context, 50),
                                ),
                                border: Border.all(
                                  color: t.info.withAlpha(80),
                                  width: S.scale(context, 1),
                                ),
                              ),
                              child: Text(
                                '+${e.value.jewelsEarned}',
                                style: GoogleFonts.nunito(
                                  color: t.info,
                                  fontSize: S.font(context, 12),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 950 + e.key * 120))
                    .slideX(begin: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BloomTheme t) {
    final isFromQuiz = widget.quizId != null;
    final ctaLabel = isFromQuiz ? 'Lihat Hasil' : 'Lanjutkan';

    return Semantics(
      button: true,
      label: 'Reward',
      child: Bounceable(
        onTap: () {
          invalidateGamificationProviders(
            ref,
            courseId: widget.courseId,
            quizId: widget.quizId,
          );
          widget.onContinue?.call();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: S.scale(context, 16)),
          decoration: BoxDecoration(
            color: _isSuperCelebration ? t.warning : t.accent,
            borderRadius: BorderRadius.circular(S.scale(context, 10)),
            border: Border.all(
              color: t.textPrimary,
              width: S.scale(context, 2),
            ),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: Offset(S.scale(context, 2), S.scale(context, 2)),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            ctaLabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: t.bgPrimary,
              fontSize: S.font(context, 16),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3),
    );
  }
}

class _AnimatedRewardCard extends StatefulWidget {
  final BloomTheme t;
  final String emoji, label;
  final int targetValue;
  final Color color;
  final int delay;
  final bool isSuper;

  const _AnimatedRewardCard({
    required this.t,
    required this.emoji,
    required this.label,
    required this.targetValue,
    required this.color,
    required this.delay,
    required this.isSuper,
  });

  @override
  State<_AnimatedRewardCard> createState() => _AnimatedRewardCardState();
}

class _AnimatedRewardCardState extends State<_AnimatedRewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _animation = IntTween(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.symmetric(
            horizontal: S.scale(context, 20),
            vertical: S.scale(context, 14),
          ),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(25),
            borderRadius: BorderRadius.circular(S.scale(context, 16)),
            border: Border.all(
              color: widget.color.withAlpha(80),
              width: S.scale(context, 1),
            ),
            boxShadow: widget.isSuper
                ? [
                    BoxShadow(
                      color: widget.color.withAlpha(100),
                      blurRadius: S.scale(context, 20),
                      spreadRadius: S.scale(context, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.color.withAlpha(50),
                      offset: Offset(S.scale(context, 4), S.scale(context, 4)),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.emoji,
                    style: TextStyle(fontSize: S.font(context, 24)),
                  ),
                  SizedBox(width: S.scale(context, 8)),
                  Text(
                    widget.label,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(180),
                      fontSize: S.font(context, 12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: S.scale(context, 8)),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '+${_animation.value}',
                      style: GoogleFonts.nunito(
                        color: widget.color,
                        fontSize: S.font(context, 22),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideX(begin: 0.1);
  }
}

// ── Confetti particle data and painter ──────────────────────────────────────

class _ConfettiParticle {
  final double startX;
  final double delay;
  final double drift;
  final double size;
  final bool isEmoji;
  final String emoji;
  final Color color;
  final bool isRound;
  final double rectWHRatio;
  final double endYFrac;
  final int index;

  const _ConfettiParticle({
    required this.startX,
    required this.delay,
    required this.drift,
    required this.size,
    required this.isEmoji,
    required this.emoji,
    required this.color,
    required this.isRound,
    required this.rectWHRatio,
    required this.endYFrac,
    required this.index,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (progress < p.delay) continue;

      final adj = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      final endY = size.height * p.endYFrac;
      final y = -50 + (endY + 50) * adj;
      final wobble = sin(adj * 4 * pi + p.index) * p.drift * adj;
      final opacity = (1 - adj).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(p.startX + wobble, y);
      canvas.rotate(adj * 4 * pi + p.index);

      if (p.isEmoji) {
        _drawEmoji(canvas, p.emoji, p.size, opacity);
      } else {
        final paint = Paint()..color = p.color.withValues(alpha: opacity);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * p.rectWHRatio,
        );
        if (p.isRound) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(p.size / 2)),
            paint,
          );
        } else {
          canvas.drawRect(rect, paint);
        }
      }

      canvas.restore();
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, double size, double opacity) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size, color: Colors.white.withValues(alpha: opacity)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
