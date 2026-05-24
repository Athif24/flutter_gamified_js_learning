import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../../../achievement/data/models/achievement_model.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';

class QuizIntroScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? courseId;
  final String? lessonId;

  const QuizIntroScreen({
    super.key,
    required this.quizId,
    this.courseId,
    this.lessonId,
  });

  @override
  ConsumerState<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends ConsumerState<QuizIntroScreen> with SilentRefreshMixin<QuizIntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(quizIntroFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(quizPreviewProvider(widget.quizId));
        ref.invalidate(myQuizResultProvider(widget.quizId));
        ref.invalidate(quizAttemptProvider(widget.quizId));
        ref.invalidate(livesProvider);
        if (widget.courseId != null) {
          ref.invalidate(courseDetailProvider(widget.courseId!));
        }
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final previewAsync = ref.watch(quizPreviewProvider(widget.quizId));
    final myResultAsync = ref.watch(myQuizResultProvider(widget.quizId));
    final livesAsync = ref.watch(livesProvider);
    final attemptAsync = ref.watch(quizAttemptProvider(widget.quizId));
    final courseDetailAsync =
        widget.courseId != null ? ref.watch(courseDetailProvider(widget.courseId!)) : null;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Column(
        children: [
          SlowLoadingIndicator(
            visible: showSlowIndicator,
            t: t,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SafeArea(
              child: Center(
                child: RefreshIndicator(
                  onRefresh: _silentRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(28),
                    child: previewAsync.when(
                      loading: () => LoadingCircle(t: t),
                      error: (e, _) => ErrorBody(
                        t: t,
                        title: AppStrings.errLoadQuiz,
                        message: sanitizeErrorMessage(e),
                        onRetry: () {
                          setShowSlowIndicator(true);
                          _silentRefresh();
                        },
                      ),
                      data: (preview) => _IntroBody(
                        preview: preview,
                        myResult: myResultAsync.asData?.value,
                        attempt: attemptAsync.asData?.value,
                        lives: livesAsync.asData?.value,
                        course: courseDetailAsync?.asData?.value,
                        t: t,
                        ref: ref,
                        quizId: widget.quizId,
                        courseId: widget.courseId,
                        lessonId: widget.lessonId,
                      ),
                    ),
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

class _IntroBody extends StatefulWidget {
  final QuizPreviewModel preview;
  final MyQuizResultResponse? myResult;
  final QuizAttemptModel? attempt;
  final LivesModel? lives;
  final CourseModel? course;
  final BloomTheme t;
  final WidgetRef ref;
  final String quizId;
  final String? courseId;
  final String? lessonId;

  const _IntroBody({
    required this.preview,
    required this.myResult,
    this.attempt,
    required this.lives,
    this.course,
    required this.t,
    required this.ref,
    required this.quizId,
    required this.courseId,
    this.lessonId,
  });

  @override
  State<_IntroBody> createState() => _IntroBodyState();
}

class _IntroBodyState extends State<_IntroBody> {
  bool _isStarting = false;
  bool _isRestarting = false;
  int? _countdownSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initCountdown();
  }

  @override
  void didUpdateWidget(_IntroBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMinutes = oldWidget.lives?.minutesUntilNextLife;
    final newMinutes = widget.lives?.minutesUntilNextLife;
    if (oldMinutes != newMinutes) {
      _initCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initCountdown() {
    _countdownTimer?.cancel();
    final minutes = widget.lives?.minutesUntilNextLife;
    if (minutes != null && minutes > 0) {
      _countdownSeconds = minutes * 60;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_countdownSeconds != null && _countdownSeconds! > 0) {
            _countdownSeconds = _countdownSeconds! - 1;
          } else {
            _countdownTimer?.cancel();
          }
        });
      });
    } else {
      _countdownSeconds = null;
    }
  }

  Color get _difficultyColor {
    return switch (widget.preview.difficulty) {
      'easy' => widget.t.success,
      'hard' => widget.t.error,
      _ => widget.t.warning,
    };
  }

  bool get _isInProgress => widget.attempt?.inProgress ?? false;
  int get _currentLives => widget.lives?.current ?? 0;
  int get _maxLives => widget.lives?.max ?? 5;
  bool get _hasLives => _currentLives > 0;
  bool get _isCourseCompleted => widget.course?.isCompleted ?? false;

  bool get _showThreeButtons =>
      _isCourseCompleted &&
      widget.myResult?.isPassed == false &&
      (_isInProgress || widget.myResult?.attempted == true);

  String get _mainButtonLabel {
    if (widget.myResult?.attempted == true && !widget.myResult!.isPassed) {
      return AppStrings.retry;
    }
    return 'Mulai Quiz';
  }

  String _formatCountdown(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleStart({bool force = false}) async {
    if (!mounted) return;
    setState(() => force ? _isRestarting = true : _isStarting = true);
    try {
      final startData = await widget.ref
          .read(courseDsProvider)
          .startQuiz(widget.quizId, force: force);
      final quizData = QuizDetailModel.fromStartResponse(startData);
      widget.ref.read(quizProvider.notifier).loadFromData(quizData);
      if (!mounted) return;
      final queryParams = <String, String>{};
      if (widget.courseId != null) queryParams['courseId'] = widget.courseId!;
      if (widget.lessonId != null) queryParams['lessonId'] = widget.lessonId!;
      final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      context.pushReplacement(
        '/quiz/${widget.quizId}${queryString.isNotEmpty ? '?$queryString' : ''}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          sanitizeErrorMessage(e),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        backgroundColor: widget.t.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => force ? _isRestarting = false : _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final preview = widget.preview;
    final myResult = widget.myResult;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: t.primary, width: 4),
                color: t.primary.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.quiz_rounded, color: t.primary, size: 40),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 16),
            Text(
              preview.title,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: _difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _difficultyColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                preview.difficulty,
                style: GoogleFonts.nunito(
                  color: _difficultyColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            Text('Nyawa: ',
                style: GoogleFonts.nunito(
                    color: t.mutedText, fontSize: 12, fontWeight: FontWeight.w700)),
            ...List.generate(_maxLives, (i) {
              final filled = i < _currentLives;
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: filled ? t.error : t.bgSurface3,
                ),
              );
            }),
            const SizedBox(width: 6),
            Text(
              '$_currentLives/$_maxLives',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _currentLives > 0 ? t.success : t.error,
              ),
            ),
            if (!_hasLives) ...[
              if (_countdownSeconds != null && _countdownSeconds! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Nyawa berikutnya dalam ${_formatCountdown(_countdownSeconds!)}',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () {
                    widget.ref.read(navIndexProvider.notifier).state = 3;
                    context.go('/home');
                  },
                  child: Text(
                    'Beli Nyawa di Store',
                    style: GoogleFonts.nunito(
                      color: t.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _InfoChip(t, Icons.menu_book_rounded, '${preview.totalQuestions} Soal', t.textPrimary),
            _InfoChip(t, Icons.bolt_rounded, '+${preview.xpReward} XP', t.warning),
            if (preview.jewelReward > 0)
              _InfoChip(t, Icons.diamond_rounded, '+${preview.jewelReward} Jewel', t.info),
            if (preview.timeLimit > 0)
              _InfoChip(t, Icons.access_time_rounded, '${preview.timeLimit} menit', t.textPrimary),
          ],
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 24),
        if (myResult != null && myResult.attempted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: myResult.isPassed
                  ? t.success.withValues(alpha: 0.1)
                  : t.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: myResult.isPassed
                    ? t.success.withValues(alpha: 0.4)
                    : t.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nilai terakhirmu',
                    style: GoogleFonts.nunito(
                        color: t.mutedText, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  '${myResult.percentageScore}% ${myResult.isPassed ? '✓ Lulus' : '✗ Belum Lulus'}',
                  style: GoogleFonts.nunito(
                    color: myResult.isPassed ? t.success : t.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        Text(
          'Nilai minimum kelulusan: ',
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 700.ms),
        Text(
          '${preview.passingScore}%',
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ).animate().fadeIn(delay: 700.ms),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_isInProgress) {
              return Column(
                children: [
                  _BuildSingleButton(
                    t: t,
                    btn: _ActionBtnData(
                      label: 'Lanjutkan',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      isLoading: _isStarting,
                      onTap: _hasLives ? () => _handleStart() : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BuildSingleButton(
                          t: t,
                          btn: _ActionBtnData(
                            label: 'Mulai Ulang',
                            color: t.error.withAlpha(200),
                            shadowColor: t.textPrimary,
                            textColor: t.primaryContent,
                            isLoading: _isRestarting,
                            onTap: _hasLives ? () => _handleStart(force: true) : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BuildSingleButton(
                          t: t,
                          btn: _ActionBtnData(
                            label: 'Kembali',
                            color: t.bgSurface2,
                            shadowColor: t.textPrimary,
                            textColor: t.textPrimary,
                            onTap: (_isStarting || _isRestarting) ? null : () => context.pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            if (_showThreeButtons) {
              return Column(
                children: [
                  _BuildSingleButton(
                    t: t,
                    btn: _ActionBtnData(
                      label: 'Lanjutkan',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      isLoading: _isStarting,
                      onTap: _hasLives ? () => _handleStart() : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BuildSingleButton(
                          t: t,
                          btn: _ActionBtnData(
                            label: 'Mulai Ulang',
                            color: t.error.withAlpha(200),
                            shadowColor: t.textPrimary,
                            textColor: t.primaryContent,
                            isLoading: _isRestarting,
                            onTap: _hasLives ? () => _handleStart(force: true) : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BuildSingleButton(
                          t: t,
                          btn: _ActionBtnData(
                            label: 'Kembali',
                            color: t.bgSurface2,
                            shadowColor: t.textPrimary,
                            textColor: t.textPrimary,
                            onTap: (_isStarting || _isRestarting) ? null : () => context.pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return _BuildButtons(
              t: t,
              axis: Axis.horizontal,
              buttons: [
                _ActionBtnData(
                  label: 'Kembali',
                  color: t.bgSurface2,
                  shadowColor: t.textPrimary,
                  textColor: t.textPrimary,
                  onTap: _isStarting ? null : () => context.pop(),
                ),
                _ActionBtnData(
                  label: _mainButtonLabel,
                  color: _hasLives ? t.primary : t.bgSurface3,
                  shadowColor: t.textPrimary,
                  textColor: _hasLives ? t.primaryContent : t.mutedText,
                  isLoading: _isStarting || _isRestarting,
                  onTap: _hasLives ? () => _handleStart(force: _isInProgress) : null,
                ),
              ],
            );
          },
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.15),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ActionBtnData {
  final String label;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionBtnData({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    this.isLoading = false,
    this.onTap,
  });
}

class _BuildSingleButton extends StatelessWidget {
  final BloomTheme t;
  final _ActionBtnData btn;

  const _BuildSingleButton({
    required this.t,
    required this.btn,
  });

  @override
  Widget build(BuildContext context) {
    final noLives = btn.onTap == null && !btn.isLoading && btn.label != 'Kembali';

    return Semantics(
      button: true,
      label: btn.label,
      child: Game3DButton(
      label: noLives ? null : btn.label,
      color: btn.color,
      shadowColor: btn.shadowColor,
      textColor: btn.textColor,
      horizontalPadding: 16,
      verticalPadding: 15,
      isLoading: btn.isLoading,
      onTap: btn.onTap,
      child: noLives
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Icon(Icons.lock_rounded, size: 14, color: Color(0xFF666666)),
                  const SizedBox(width: 6),
                  Text('Nyawa Habis',
                      style: GoogleFonts.nunito(
                          color: Color(0xFF666666), fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              )
          : null,
    ),
    );
  }
}

class _BuildButtons extends StatelessWidget {
  final BloomTheme t;
  final Axis axis;
  final List<_ActionBtnData> buttons;

  const _BuildButtons({
    required this.t,
    required this.axis,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      final btn = buttons[i];
      final noLives = btn.onTap == null && !btn.isLoading && btn.label != 'Kembali';

      if (i > 0) {
        list.add(SizedBox(width: axis == Axis.horizontal ? 12 : 0, height: axis == Axis.vertical ? 10 : 0));
      }

      final btnWidget = Game3DButton(
        label: noLives ? null : btn.label,
        color: btn.color,
        shadowColor: btn.shadowColor,
        textColor: btn.textColor,
        horizontalPadding: 16,
        verticalPadding: 15,
        isLoading: btn.isLoading,
        onTap: btn.onTap,
        child: noLives
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(Icons.lock_rounded, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 6),
                    Text('Nyawa Habis',
                        style: GoogleFonts.nunito(
                            color: Color(0xFF666666), fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                )
              : null,
        );

        list.add(
          axis == Axis.horizontal
            ? Expanded(child: Semantics(button: true, label: btn.label, child: btnWidget))
            : Semantics(button: true, label: btn.label, child: btnWidget),
      );
    }

    if (axis == Axis.horizontal) {
      return Row(children: list);
    }
    return SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: list));
  }
}

class _InfoChip extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(this.t, this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: t.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.nunito(
                  color: t.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}


