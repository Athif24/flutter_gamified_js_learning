import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../shared/widgets/main_screen.dart';
import '../../../../../../core/utils/error_helper.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/utils/responsive_utils.dart';

import '../../../../data/models/course_model.dart';
import '../../../../../achievement/data/models/achievement_model.dart';
import '../../../providers/course_provider.dart';
import 'action_btn_data.dart';
import 'build_single_button.dart';
import 'build_buttons.dart';
import 'info_chip.dart';

class IntroBody extends StatefulWidget {
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

  const IntroBody({
    super.key,
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
  State<IntroBody> createState() => IntroBodyState();
}

class IntroBodyState extends State<IntroBody> {
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
  void didUpdateWidget(IntroBody oldWidget) {
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
      final uri = Uri(
        path: '/quiz/${widget.quizId}',
        queryParameters: {
          if (widget.courseId != null) 'courseId': widget.courseId,
          if (widget.lessonId != null) 'lessonId': widget.lessonId,
        },
      );
      context.pushReplacement(uri.toString());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sanitizeErrorMessage(e),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: widget.t.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(S.scale(context, 12)),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => force ? _isRestarting = false : _isStarting = false);
      }
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
        SizedBox(height: S.scale(context, 20)),
        Column(
          children: [
            Container(
              width: S.scale(context, 80),
              height: S.scale(context, 80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.primary,
                  width: S.scale(context, 4),
                ),
                color: t.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.quiz_rounded,
                color: t.primary,
                size: S.scale(context, 40),
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            SizedBox(height: S.scale(context, 16)),
            Text(
              preview.title,
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontSize: S.font(context, 22),
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: S.scale(context, 10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: S.scale(context, 16),
                vertical: S.scale(context, 5),
              ),
              decoration: BoxDecoration(
                color: _difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(S.scale(context, 50)),
                border: Border.all(
                  width: S.scale(context, 1),
                  color: _difficultyColor.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                preview.difficulty,
                style: GoogleFonts.nunito(
                  color: _difficultyColor,
                  fontSize: S.font(context, 11),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
        SizedBox(height: S.scale(context, 28)),
        Wrap(
          spacing: S.scale(context, 4),
          runSpacing: S.scale(context, 4),
          alignment: WrapAlignment.center,
          children: [
            Text(
              'Nyawa: ',
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 12),
                fontWeight: FontWeight.w700,
              ),
            ),
            ...List.generate(_maxLives, (i) {
              final filled = i < _currentLives;
              return Padding(
                padding: EdgeInsets.only(right: S.scale(context, 2)),
                child: Icon(
                  Icons.favorite_rounded,
                  size: S.scale(context, 20),
                  color: filled ? t.error : t.bgSurface3,
                ),
              );
            }),
            SizedBox(width: S.scale(context, 6)),
            Text(
              '$_currentLives/$_maxLives',
              style: GoogleFonts.nunito(
                fontSize: S.font(context, 12),
                fontWeight: FontWeight.w800,
                color: _currentLives > 0 ? t.success : t.error,
              ),
            ),
            if (!_hasLives) ...[
              if (_countdownSeconds != null && _countdownSeconds! > 0)
                Padding(
                  padding: EdgeInsets.only(top: S.scale(context, 6)),
                  child: Text(
                    'Nyawa berikutnya dalam ${_formatCountdown(_countdownSeconds!)}',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: S.font(context, 11),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: S.scale(context, 4)),
                child: GestureDetector(
                  onTap: () {
                    widget.ref.read(navIndexProvider.notifier).state = 3;
                    context.go('/home');
                  },
                  child: Text(
                    'Beli Nyawa di Store',
                    style: GoogleFonts.nunito(
                      color: t.primary,
                      fontSize: S.font(context, 11),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: S.scale(context, 20)),
        Wrap(
          spacing: S.scale(context, 10),
          runSpacing: S.scale(context, 10),
          alignment: WrapAlignment.center,
          children: [
            InfoChip(
              t,
              Icons.menu_book_rounded,
              '${preview.totalQuestions} Soal',
              t.textPrimary,
            ),
            InfoChip(
              t,
              Icons.bolt_rounded,
              '+${preview.xpReward} XP',
              t.warning,
            ),
            if (preview.jewelReward > 0)
              InfoChip(
                t,
                Icons.diamond_rounded,
                '+${preview.jewelReward} Jewel',
                t.info,
              ),
            if (preview.timeLimit > 0)
              InfoChip(
                t,
                Icons.access_time_rounded,
                '${preview.timeLimit} menit',
                t.textPrimary,
              ),
          ],
        ).animate().fadeIn(delay: 500.ms),
        SizedBox(height: S.scale(context, 24)),
        if (myResult != null && myResult.attempted)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: S.scale(context, 20),
              vertical: S.scale(context, 12),
            ),
            decoration: BoxDecoration(
              color: myResult.isPassed
                  ? t.success.withValues(alpha: 0.1)
                  : t.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(S.scale(context, 16)),
              border: Border.all(
                width: S.scale(context, 1),
                color: myResult.isPassed
                    ? t.success.withValues(alpha: 0.4)
                    : t.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nilai terakhirmu',
                  style: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: S.font(context, 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${myResult.percentageScore}% ${myResult.isPassed ? '✓ Lulus' : '✗ Belum Lulus'}',
                  style: GoogleFonts.nunito(
                    color: myResult.isPassed ? t.success : t.error,
                    fontSize: S.font(context, 14),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
        SizedBox(height: S.scale(context, 16)),
        Text(
          'Nilai minimum kelulusan: ',
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontSize: S.font(context, 12),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 700.ms),
        Text(
          '${preview.passingScore}%',
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontSize: S.font(context, 20),
            fontWeight: FontWeight.w900,
          ),
        ).animate().fadeIn(delay: 700.ms),
        SizedBox(height: S.scale(context, 32)),
        LayoutBuilder(
          builder: (context, constraints) {
            if (_isInProgress) {
              return Column(
                children: [
                  BuildSingleButton(
                    t: t,
                    btn: ActionBtnData(
                      label: 'Lanjutkan',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      isLoading: _isStarting,
                      onTap: _hasLives ? () => _handleStart() : null,
                    ),
                  ),
                  SizedBox(height: S.scale(context, 12)),
                  Row(
                    children: [
                      Expanded(
                        child: BuildSingleButton(
                          t: t,
                          btn: ActionBtnData(
                            label: 'Mulai Ulang',
                            color: t.error.withValues(alpha: 0.78),
                            shadowColor: t.textPrimary,
                            textColor: t.primaryContent,
                            isLoading: _isRestarting,
                            onTap: _hasLives
                                ? () => _handleStart(force: true)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: S.scale(context, 12)),
                      Expanded(
                        child: BuildSingleButton(
                          t: t,
                          btn: ActionBtnData(
                            label: 'Kembali',
                            color: t.bgSurface2,
                            shadowColor: t.textPrimary,
                            textColor: t.textPrimary,
                            onTap: (_isStarting || _isRestarting)
                                ? null
                                : () => context.pop(),
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
                  BuildSingleButton(
                    t: t,
                    btn: ActionBtnData(
                      label: 'Lanjutkan',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      isLoading: _isStarting,
                      onTap: _hasLives ? () => _handleStart() : null,
                    ),
                  ),
                  SizedBox(height: S.scale(context, 12)),
                  Row(
                    children: [
                      Expanded(
                        child: BuildSingleButton(
                          t: t,
                          btn: ActionBtnData(
                            label: 'Mulai Ulang',
                            color: t.error.withValues(alpha: 0.78),
                            shadowColor: t.textPrimary,
                            textColor: t.primaryContent,
                            isLoading: _isRestarting,
                            onTap: _hasLives
                                ? () => _handleStart(force: true)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: S.scale(context, 12)),
                      Expanded(
                        child: BuildSingleButton(
                          t: t,
                          btn: ActionBtnData(
                            label: 'Kembali',
                            color: t.bgSurface2,
                            shadowColor: t.textPrimary,
                            textColor: t.textPrimary,
                            onTap: (_isStarting || _isRestarting)
                                ? null
                                : () => context.pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return BuildButtons(
              t: t,
              axis: Axis.horizontal,
              buttons: [
                ActionBtnData(
                  label: 'Kembali',
                  color: t.bgSurface2,
                  shadowColor: t.textPrimary,
                  textColor: t.textPrimary,
                  onTap: _isStarting ? null : () => context.pop(),
                ),
                ActionBtnData(
                  label: _mainButtonLabel,
                  color: _hasLives ? t.primary : t.bgSurface3,
                  shadowColor: t.textPrimary,
                  textColor: _hasLives ? t.primaryContent : t.mutedText,
                  isLoading: _isStarting || _isRestarting,
                  onTap: _hasLives
                      ? () => _handleStart(force: _isInProgress)
                      : null,
                ),
              ],
            );
          },
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.15),
        SizedBox(height: S.scale(context, 40)),
      ],
    );
  }
}