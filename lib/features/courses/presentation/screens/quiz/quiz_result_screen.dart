import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../shared/providers/gamification_providers.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../providers/course_provider.dart';
import '../../../data/models/course_model.dart';
import 'quiz_review_dialog.dart';
import '../../../../../shared/services/sound_service.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final QuizResultModel result;
  final BloomTheme t;
  final String? courseId;
  final String quizId;
  final String? lessonId;
  final VoidCallback onRetry;
  final VoidCallback? onBackToMap;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.t,
    required this.courseId,
    required this.quizId,
    this.lessonId,
    required this.onRetry,
    this.onBackToMap,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  int _displayPct = 0;
  bool _hasInvalidated = false;
  late final AnimationController _scoreAnimController;

  bool get _isSuperResult =>
      widget.result.passed &&
      (widget.result.percentage >= 95 ||
          widget.result.score == widget.result.totalPoints);

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scoreAnimController.addListener(_onScoreTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _scoreAnimController.forward();
      });
      if (!_hasInvalidated) {
        _hasInvalidated = true;
        invalidateGamificationProviders(
          ref,
          courseId: (widget.courseId?.isNotEmpty ?? false) ? widget.courseId! : null,
          quizId: widget.quizId,
        );
      }
    });
  }

  void _onScoreTick() {
    final targetPct = widget.result.percentage.round();
    final eased = 1 - (1 - _scoreAnimController.value) *
        (1 - _scoreAnimController.value) *
        (1 - _scoreAnimController.value);
    setState(() {
      _displayPct = (targetPct * eased).round();
    });
  }

  @override
  void dispose() {
    _scoreAnimController.removeListener(_onScoreTick);
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.t.bgPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isSuperResult 
                  ? widget.t.warning.withValues(alpha: 0.08) 
                  : widget.t.bgPrimary,
              widget.t.bgPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: S.isTablet(context) ? 600 : double.infinity),
                  child: SingleChildScrollView(
                padding: EdgeInsets.all(S.scale(context, 28)),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(S.scale(context, 22)),
                      decoration: BoxDecoration(
                        color: widget.result.passed
                            ? (_isSuperResult
                                ? widget.t.warning.withValues(alpha: 0.15)
                                : widget.t.success.withValues(alpha: 0.15))
                            : widget.t.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: widget.result.passed
                              ? (_isSuperResult
                                  ? widget.t.warning
                                  : widget.t.success)
                              : widget.t.error,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.result.passed
                                ? (_isSuperResult
                                    ? widget.t.warning.withValues(alpha: 0.3)
                                    : widget.t.success.withValues(alpha: 0.3))
                                : widget.t.error.withValues(alpha: 0.3),
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_isSuperResult) _buildLegendaryBadge(widget.t),
                          if (_isSuperResult) const SizedBox(height: 12),

                          Semantics(
                            label: widget.result.passed ? 'Lulus' : 'Belum lulus',
                            child: Container(
                              width: S.scale(context, 88),
                              height: S.scale(context, 88),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.result.passed
                                    ? (_isSuperResult
                                        ? widget.t.warning.withValues(alpha: 0.2)
                                        : widget.t.success.withValues(alpha: 0.2))
                                    : widget.t.error.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: widget.result.passed
                                      ? (_isSuperResult
                                          ? widget.t.warning
                                          : widget.t.success)
                                      : widget.t.error,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                widget.result.passed
                                    ? Icons.emoji_events_rounded
                                    : Icons.close_rounded,
                                size: S.scale(context, 44),
                                color: widget.result.passed
                                    ? (_isSuperResult
                                        ? widget.t.warning
                                        : widget.t.success)
                                    : widget.t.error,
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                                duration: 700.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 12),

                          Text(
                            widget.result.passed
                                ? 'Luar Biasa! 🎉'
                                : 'Belum Lulus 😢',
                            style: GoogleFonts.nunito(
                              color: widget.t.textPrimary,
                              fontSize: S.font(context, 24),
                              fontWeight: FontWeight.w900,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 300.ms),
                          const SizedBox(height: 8),

                          Text(
                            widget.result.passed
                                ? 'Kamu berhasil melewati batas nilai!'
                                : 'Nilai minimum: ${widget.result.passingScore}%. Coba lagi!',
                            style: GoogleFonts.nunito(
                              color: widget.t.textSecondary,
                              fontSize: S.font(context, 13),
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 400.ms),

                          if (widget.result.passed) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Lesson selesai! Kamu bisa lanjut ke lesson berikutnya.',
                              style: GoogleFonts.nunito(
                                color: widget.t.success,
                                fontSize: S.font(context, 13),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 500.ms),
                          ],

                          const SizedBox(height: 24),

                          _ScoreRing(
                            pct: _displayPct,
                            isPassed: widget.result.passed,
                            isSuper: _isSuperResult,
                            t: widget.t,
                            ringBgColor: widget.t.bgSurface2,
                            size: S.isTablet(context) ? 160 : 112,
                          )
                              .animate()
                              .fadeIn(delay: 350.ms)
                              .scale(begin: const Offset(0.8, 0.8)),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: _StatBadge(
                                  t: widget.t,
                                  icon: Icons.check_circle_rounded,
                                  value: '${widget.result.questionResults.where((q) => q.isCorrect).length}/${widget.result.questionResults.length}',
                                  label: 'Benar',
                                  color: widget.t.success,
                                  delay: 700,
                                ),
                              ),
                              if (widget.result.xpEarned > 0)
                                Expanded(
                                  child: _StatBadge(
                                    t: widget.t,
                                    icon: Icons.bolt_rounded,
                                    value: '+${widget.result.xpEarned}',
                                    label: 'XP',
                                    color: widget.t.warning,
                                    delay: 780,
                                  ),
                                ),
                              if (widget.result.jewelsEarned > 0)
                                Expanded(
                                  child: _StatBadge(
                                    t: widget.t,
                                    icon: Icons.diamond_rounded,
                                    value: '+${widget.result.jewelsEarned}',
                                    label: 'Jewel',
                                    color: widget.t.info,
                                    delay: 860,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (widget.result.questionResults.isNotEmpty)
                      Semantics(
                        button: true,
                        label: 'Lihat Jawaban',
                        child: SizedBox(
                          width: double.infinity,
                          child: Game3DButton(
                            color: widget.t.bgSurface2,
                            shadowColor: widget.t.textPrimary,
                            textColor: widget.t.primary,
                            horizontalPadding: S.scale(context, 20),
                            verticalPadding: S.scale(context, 13),
                            onTap: () {
                              ref.read(soundProvider).playClick();
                              showDialog(
                                context: context,
                                builder: (_) => ReviewDialog(
                                  questionResults: widget.result.questionResults,
                                  questions: ref.read(quizProvider).quiz?.questions ?? [],
                                  t: widget.t,
                                ),
                              );
                            },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_turned_in_rounded,
                                  color: widget.t.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Lihat Jawaban',
                                style: GoogleFonts.nunito(
                                  color: widget.t.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.font(context, 14),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 1100.ms),
                      ),
                    ),

                    if (widget.result.questionResults.isNotEmpty)
                      const SizedBox(height: 12),

                    Semantics(
                      button: true,
                      label: 'Kembali ke Peta Belajar',
                      child: SizedBox(
                        width: double.infinity,
                        child: Game3DButton(
                          color: widget.t.primary,
                          shadowColor: widget.t.textPrimary,
                          textColor: widget.t.primaryContent,
                          horizontalPadding: S.scale(context, 20),
                          verticalPadding: S.scale(context, 15),
                          onTap: () {
                            ref.read(soundProvider).playClick();
                            ref.read(quizProvider.notifier).reset();
                            if (widget.courseId != null) {
                              context.go('/course/${widget.courseId}');
                            } else if (widget.onBackToMap != null) {
                              widget.onBackToMap!();
                            } else {
                              while (context.canPop()) {
                                context.pop();
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, color: widget.t.primaryContent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Kembali ke Peta Belajar',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  fontSize: S.font(context, 15),
                                  color: widget.t.primaryContent,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 1200.ms),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
              ),
            ),

              if (_isSuperResult) ..._buildMiniConfetti(widget.t),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMiniConfetti(BloomTheme t) {
    final size = MediaQuery.of(context).size;
    final colors = [t.warning, t.info, t.success, t.primary];
    
    return List.generate(6, (i) {
      final random = Random(i * 7);
      final startX = random.nextDouble() * size.width;
      final color = colors[i % colors.length];
      
      return Positioned(
        left: startX,
        top: -10,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 200 + i * 100))
          .slideY(begin: 0, end: 1.2, duration: 2000.ms)
          .fade(begin: 0.6, end: 0, duration: 2000.ms),
      );
    });
  }

  Widget _buildLegendaryBadge(BloomTheme t) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: S.scale(context, 12), vertical: S.scale(context, 4)),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: t.textPrimary, width: 2),
      ),
      child: Text(
        'LEGENDARY SCORE',
        style: GoogleFonts.nunito(
          color: t.warning,
          fontSize: S.font(context, 10),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 160.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}

class _ScoreRing extends StatelessWidget {
  final int pct;
  final bool isPassed;
  final bool isSuper;
  final BloomTheme t;
  final Color ringBgColor;
  final double size;

  const _ScoreRing({
    required this.pct,
    required this.isPassed,
    required this.isSuper,
    required this.t,
    required this.ringBgColor,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          pct: pct / 100.0,
          color: isPassed ? t.success : t.error,
          strokeWidth: 10,
          ringBgColor: ringBgColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 24),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SKOR',
                style: GoogleFonts.nunito(
            color: t.textSecondary,
                  fontSize: S.font(context, 10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final double strokeWidth;
  final Color ringBgColor;

  _RingPainter({
    required this.pct,
    required this.color,
    required this.strokeWidth,
    required this.ringBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = ringBgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      3.14159 * 2 * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.pct != pct ||
        oldDelegate.color != color ||
        oldDelegate.ringBgColor != ringBgColor;
  }
}

class _StatBadge extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String value, label;
  final Color color;
  final int delay;

  const _StatBadge({
    required this.t,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: S.font(context, 18),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontSize: S.font(context, 10),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.6, 0.6));
  }
}
