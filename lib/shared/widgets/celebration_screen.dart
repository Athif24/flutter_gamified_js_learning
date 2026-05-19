import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/theme_provider.dart';
import '../providers/gamification_providers.dart';
import '../../features/courses/data/models/course_model.dart';

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

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.forward();
      _animateXpCounter();
    });
  }

  void _animateXpCounter() {
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _showContent = true);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              t.accent.withAlpha(230),
              t.bgPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti particles
              ...List.generate(20, (i) => _ConfettiParticle(
                controller: _confettiController,
                index: i,
                color: [t.accent, t.info, t.warning, t.success][i % 4],
              )),

              // Main content
              if (_showContent)
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji + title
                        Text('🎉', style: TextStyle(fontSize: size.width * 0.2))
                            .animate()
                            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Text('Selesai!',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text('Kamu telah menyelesaikan materi ini',
                            style: GoogleFonts.nunito(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            )).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 32),

                        // XP earned card
                        _RewardCard(
                          t: t,
                          emoji: '⭐',
                          label: 'XP',
                          value: '+${widget.xpEarned}',
                          color: t.accent,
                          delay: 500,
                        ),

                        if (widget.jewelsEarned > 0) ...[
                          const SizedBox(height: 12),
                          _RewardCard(
                            t: t,
                            emoji: '💎',
                            label: 'Jewel',
                            value: '+${widget.jewelsEarned}',
                            color: const Color(0xFF4A90E2),
                            delay: 600,
                          ),
                        ],

                        // Streak
                        if (widget.streak != null) ...[
                          const SizedBox(height: 12),
                          _RewardCard(
                            t: t,
                            emoji: '🔥',
                            label: 'Streak',
                            value: '${widget.streak!.currentStreak} hari',
                            color: t.warning,
                            delay: 700,
                          ),
                        ],

                        // Level up
                        if (widget.levelUp != null && widget.levelUp!.leveledUp) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [t.accent.withAlpha(60), t.info.withAlpha(40)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: t.accent.withAlpha(100)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🚀', style: TextStyle(fontSize: 28))
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .moveY(begin: 0, end: -5, duration: 600.ms),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LEVEL UP!',
                                        style: GoogleFonts.nunito(
                                          color: t.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        )),
                                    const SizedBox(height: 2),
                                    Text('${widget.levelUp!.previousLevelName ?? ""} → ${widget.levelUp!.newLevelName ?? ""}',
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),
                        ],

                        // Badges
                        if (widget.badges.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ...widget.badges.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: t.info.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.info.withAlpha(60)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🏅', style: TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Text('Badge: ${e.value.name}',
                                      style: GoogleFonts.nunito(
                                        color: t.info,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),
                            ).animate().fadeIn(
                              delay: Duration(milliseconds: 900 + e.key * 150),
                            ).slideX(begin: 0.1),
                          )),
                        ],

                        const SizedBox(height: 40),

                        // Continue button
                        Bounceable(
                          onTap: () {
                            invalidateGamificationProviders(
                              ref,
                              courseId: widget.courseId,
                              quizId: widget.quizId,
                            );
                            widget.onContinue?.call();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text('Lanjut Belajar',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: t.bgPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                )),
                          ),
                        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3),

                        const SizedBox(height: 32),
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
}

// ── Confetti particle ──────────────────────────────────────────────────────────

class _ConfettiParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Color color;

  const _ConfettiParticle({
    required this.controller,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(index * 7);
    final startX = random.nextDouble() * MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final progress = controller.value;
        final endY = MediaQuery.of(context).size.height * 0.8;
        final currentY = -50 + (endY + 50) * progress;
        final wobble = sin(progress * 4 * pi + index);
        final opacity = (1 - progress).clamp(0.0, 1.0);
        return Positioned(
          left: startX + wobble * 20,
          top: currentY,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: progress * 4 * pi + index,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(random.nextBool() ? 4 : 0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Reward card ────────────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  final BloomTheme t;
  final String emoji, label, value;
  final Color color;
  final int delay;

  const _RewardCard({
    required this.t,
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(20),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withAlpha(40)),
    ),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      Expanded(child: Text(label,
          style: GoogleFonts.nunito(
            color: Colors.white.withAlpha(180),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ))),
      Text(value,
          style: GoogleFonts.nunito(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          )),
    ]),
  ).animate()
    .fadeIn(delay: Duration(milliseconds: delay))
    .slideX(begin: 0.1, duration: 400.ms);
}
