import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/utils/accessibility.dart';
import '../../data/models/reward_pool_model.dart';

enum _RevealPhase { box, reveal }

class MysteryBoxRevealOverlay extends StatefulWidget {
  final MysteryBoxResult result;
  final String poolName;
  final String? poolIcon;
  final VoidCallback onDismiss;
  final VoidCallback onOpenAgain;
  final bool canOpenAgain;
  final BloomTheme t;

  const MysteryBoxRevealOverlay({
    super.key,
    required this.result,
    required this.poolName,
    this.poolIcon,
    required this.onDismiss,
    required this.onOpenAgain,
    required this.canOpenAgain,
    required this.t,
  });

  @override
  State<MysteryBoxRevealOverlay> createState() =>
      _MysteryBoxRevealOverlayState();
}

class _MysteryBoxRevealOverlayState extends State<MysteryBoxRevealOverlay>
    with SingleTickerProviderStateMixin {
  _RevealPhase _phase = _RevealPhase.box;
  bool _showFlash = false;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Timeline: box (0-1400ms) -> flash (1400-1800ms) -> reveal (1800ms+)
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showFlash = true);
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _phase = _RevealPhase.reveal);
        _confettiController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String get _boxIcon {
    if (widget.poolIcon != null && widget.poolIcon!.isNotEmpty) {
      return widget.poolIcon!;
    }
    if (widget.poolName.toLowerCase().contains('legendary')) return '👑';
    if (widget.poolName.toLowerCase().contains('premium')) return '🎀';
    return '🎁';
  }

  Color get _rewardColor {
    switch (widget.result.rewardType) {
      case 'xp':
        return widget.t.success;
      case 'jewels':
        return widget.t.info;
      case 'item':
        return widget.t.accent;
      default:
        return widget.t.primary;
    }
  }

  IconData get _rewardIcon {
    switch (widget.result.rewardType) {
      case 'xp':
        return Icons.bolt_rounded;
      case 'jewels':
        return Icons.diamond_rounded;
      case 'item':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.t.bgPrimary,
              widget.t.bgSurface,
              widget.t.bgSurface2,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Confetti particles (skipped if reduced motion)
            if (_phase == _RevealPhase.reveal &&
                widget.result.isGoodReward &&
                !a11yReduceMotion(context))
              ...List.generate(
                20,
                (i) => _ConfettiParticle(
                  controller: _confettiController,
                  index: i,
                  color: [
                    widget.t.primary,
                    widget.t.secondary,
                    widget.t.accent,
                    widget.t.success,
                    widget.t.info,
                  ][i % 5],
                ),
              ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: rs(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Box phase
                    if (_phase == _RevealPhase.box)
                      Column(
                        children: [
                          _boxIcon.startsWith('http')
                              ?                               CachedNetworkImage(
                                  imageUrl: _boxIcon,
                                  width: rs(128),
                                  height: rs(128),
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => Text(
                                    _boxIcon,
                                    style: TextStyle(fontSize: rs(128)),
                                  ),
                                  errorWidget: (_, __, ___) => Text(
                                    _boxIcon,
                                    style: TextStyle(fontSize: rs(128)),
                                  ),
                                )
                              : Text(
                                      _boxIcon,
                                      style: TextStyle(fontSize: rs(128)),
                                    )
                                    .animate(
                                      onPlay: (c) => a11yReduceMotion(context)
                                          ? null
                                          : c.repeat(),
                                    )
                                    .shake(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      hz: 3,
                                      rotation: 0.15,
                                      curve: Curves.easeInOut,
                                    ),
                          SizedBox(height: rs(16)),
                          Text(
                            widget.poolName,
                            style: GoogleFonts.nunito(
                              color: widget.t.textPrimary.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: rs(18),
                              fontWeight: FontWeight.w800,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),

                    // Flash
                    if (_showFlash)
                      Container(color: widget.t.primary.withValues(alpha: 0.3))
                          .animate(
                            onComplete: (c) {
                              if (mounted) {
                                setState(() => _showFlash = false);
                              }
                            },
                          )
                          .fadeIn(duration: 100.ms)
                          .fadeOut(
                            duration: 300.ms,
                            delay: const Duration(milliseconds: 100),
                          ),

                    // Reveal phase
                    if (_phase == _RevealPhase.reveal)
                      _RewardReveal(
                        result: widget.result,
                        rewardColor: _rewardColor,
                        rewardIcon: _rewardIcon,
                        onDismiss: widget.onDismiss,
                        onOpenAgain: widget.onOpenAgain,
                        canOpenAgain: widget.canOpenAgain,
                        t: widget.t,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardReveal extends StatefulWidget {
  final MysteryBoxResult result;
  final Color rewardColor;
  final IconData rewardIcon;
  final VoidCallback onDismiss;
  final VoidCallback onOpenAgain;
  final bool canOpenAgain;
  final BloomTheme t;

  const _RewardReveal({
    required this.result,
    required this.rewardColor,
    required this.rewardIcon,
    required this.onDismiss,
    required this.onOpenAgain,
    required this.canOpenAgain,
    required this.t,
  });

  @override
  State<_RewardReveal> createState() => _RewardRevealState();
}

class _RewardRevealState extends State<_RewardReveal> {
  int _displayAmount = 0;

  @override
  void initState() {
    super.initState();
    _animateCounter();
  }

  Future<void> _animateCounter() async {
    const duration = Duration(milliseconds: 1200);
    const steps = 60;
    final stepDuration = duration.inMilliseconds ~/ steps;

    for (int i = 0; i <= steps; i++) {
      if (!mounted) return;
      final progress = i / steps;
      final eased = 1 - pow(1 - progress, 3);
      setState(() {
        _displayAmount = (widget.result.amount * eased).round();
      });
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji
        Text('🎉', style: TextStyle(fontSize: rs(48)))
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
        SizedBox(height: rs(24)),

        // Reward icon circle
        Container(
          width: rs(128),
          height: rs(128),
          decoration: BoxDecoration(
            color: widget.rewardColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.rewardColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child:
                widget.result.rewardType == 'item' &&
                    widget.result.itemIcon != null
                ?                     CachedNetworkImage(
                    imageUrl: widget.result.itemIcon!,
                    width: rs(80),
                    height: rs(80),
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Icon(
                      widget.rewardIcon,
                    size: rs(64),
                    color: widget.rewardColor,
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    widget.rewardIcon,
                    size: rs(64),
                      color: widget.rewardColor,
                    ),
                  )
                : Icon(widget.rewardIcon, size: rs(64), color: widget.rewardColor),
          ),
        ).animate().scale(
          delay: 300.ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ),

        SizedBox(height: rs(16)),

        // "Kamu mendapatkan"
        Text(
          'Kamu mendapatkan',
          style: GoogleFonts.nunito(
            color: widget.t.mutedText,
            fontSize: rs(12),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

        SizedBox(height: rs(4)),

        // Reward display label
        Text(
          widget.result.displayLabel,
          style: GoogleFonts.nunito(
            color: widget.rewardColor,
            fontSize: rs(28),
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

        SizedBox(height: rs(8)),

        // Animated counter
        Text(
          '+$_displayAmount ${widget.result.rewardLabel}',
          style: GoogleFonts.nunito(
            color: widget.t.textSecondary,
            fontSize: rs(18),
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn(delay: 800.ms),

        SizedBox(height: rs(32)),

        // Buttons
        if (widget.canOpenAgain) ...[
          Bounceable(
            onTap: () {
              ProviderScope.containerOf(context).read(soundProvider).playClick();
              Navigator.of(context).pop();
              widget.onOpenAgain();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rs(16)),
              decoration: BoxDecoration(
                color: widget.t.primary,
                borderRadius: BorderRadius.circular(rs(10)),
                border: Border.all(
                  color: widget.t.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.t.textPrimary.withValues(alpha: 0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'Buka Lagi',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: widget.t.primaryContent,
                  fontSize: rs(16),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
          SizedBox(height: rs(12)),
        ],

        // Button TUTUP
        Bounceable(
              onTap: () {
                ProviderScope.containerOf(context).read(soundProvider).playClick();
                widget.onDismiss();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: rs(16)),
                decoration: BoxDecoration(
                  color: widget.t.bgSurface2,
                  borderRadius: BorderRadius.circular(rs(10)),
                  border: Border.all(
                    color: widget.t.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.t.textPrimary.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'Tutup',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: widget.t.primaryContent,
                    fontSize: rs(14),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: widget.canOpenAgain ? 1100.ms : 1000.ms)
            .slideY(begin: 0.3),

        SizedBox(height: rs(24)),
      ],
    );
  }
}

// ── Confetti particle ──────────────────────────────────────────────────

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
                  borderRadius: BorderRadius.circular(
                    random.nextBool() ? 4 : 0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
