import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/celebration_screen.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';
import '../widgets/quiz/questions/question_card.dart';
import '../widgets/quiz/questions/choice_question.dart';
import '../widgets/quiz/questions/essay_question.dart';
import '../widgets/quiz/questions/arrange_question.dart';
import '../widgets/quiz/quiz_timer.dart';
import '../widgets/quiz/quiz_feedback_popup.dart';
import '../widgets/quiz/bottom_bar.dart';
import 'quiz_result_screen.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../shared/widgets/volume_control.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? courseId;
  final String? lessonId;

  const QuizScreen({
    super.key,
    required this.quizId,
    this.courseId,
    this.lessonId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _showCelebration = true;
  int? _previousLivesRemaining;

  @override
  void initState() {
    super.initState();
  }

  bool _shouldCelebrate(QuizResultModel result) {
    return result.passed &&
        (result.xpEarned > 0 ||
            result.jewelsEarned > 0 ||
            result.levelUp != null ||
            result.badgesAwarded.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final quiz = ref.watch(quizProvider);
    final sound = ref.watch(soundProvider);
    final livesAsync = ref.watch(livesProvider);

    ref.listen<QuizState>(quizProvider, (prev, next) {
      debugPrint('[SOUND] prev?.lastAnswerResult=${prev?.lastAnswerResult?.isCorrect} '
          'next.lastAnswerResult=${next.lastAnswerResult?.isCorrect}');
      if (next.lastAnswerResult != null &&
          prev?.lastAnswerResult != next.lastAnswerResult) {
        debugPrint('[SOUND] >>> calling ${next.lastAnswerResult!.isCorrect ? "playCorrect" : "playWrong"}');
        if (next.lastAnswerResult!.isCorrect) {
          sound.playCorrect();
        } else {
          sound.playWrong();
        }
      }
    });

    final backButton = Semantics(
      button: true,
      label: 'Kembali',
      child: Bounceable(
        onTap: () {
          sound.playClick();
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        child: Container(
          width: S.scale(context, 38),
          height: S.scale(context, 38),
          decoration: BoxDecoration(
            color: t.bgSurface2,
            shape: BoxShape.circle,
            border: Border.all(color: t.textPrimary, width: 2),
            boxShadow: [
              BoxShadow(
                color: t.textPrimary,
                offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: t.textPrimary,
            size: S.scale(context, 15),
          ),
        ),
      ),
    );

    if (quiz.quiz == null && quiz.error == null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: SafeArea(
          child: Column(
            children: [
              SlowLoadingIndicator(visible: true, t: t),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 12),
                  S.scale(context, 8),
                  S.scale(context, 12),
                  0,
                ),
                child: Row(
                  children: [
                    backButton,
                    SizedBox(width: S.scale(context, 12)),
                    Expanded(
                      child: Text(
                        'Memuat Kuis...',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 15),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(child: LoadingCircle(t: t)),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz.error != null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: SafeArea(
          child: Column(
            children: [
              SlowLoadingIndicator(visible: false, t: t),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.scale(context, 12),
                  S.scale(context, 8),
                  S.scale(context, 12),
                  0,
                ),
                child: Row(
                  children: [
                    backButton,
                    SizedBox(width: S.scale(context, 12)),
                    Expanded(
                      child: Text(
                        'Kuis',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 15),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(S.scale(context, 32)),
                    child: ErrorBody(
                      t: t,
                      icon: iconForError(quiz.error!),
                      title: AppStrings.errLoadQuiz,
                      message: sanitizeErrorMessage(quiz.error!),
                      onRetry: () {
                        ref.read(quizProvider.notifier).reset();
                        context.pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz.isFinished) {
      final result = quiz.result!;
      if (_showCelebration && _shouldCelebrate(result)) {
        return Scaffold(
          backgroundColor: t.bgPrimary,
          body: CelebrationScreen(
            xpEarned: result.xpEarned,
            jewelsEarned: result.jewelsEarned,
            streak: result.streak,
            levelUp: result.levelUp,
            badges: result.badgesAwarded,
            courseId: widget.courseId,
            quizId: widget.quizId,
            onContinue: () => setState(() => _showCelebration = false),
          ),
        );
      }
      return QuizResultScreen(
        result: result,
        t: t,
        courseId: widget.courseId,
        quizId: widget.quizId,
        lessonId: widget.lessonId,
        onRetry: () {
          ref.read(quizProvider.notifier).reset();
          final uri = Uri(
            path: '/quiz-intro/${widget.quizId}',
            queryParameters: {
              if (widget.courseId != null) 'courseId': widget.courseId,
              if (widget.lessonId != null) 'lessonId': widget.lessonId,
            },
          );
          context.pushReplacement(uri.toString());
        },
        onBackToMap: () {
          ref.read(quizProvider.notifier).reset();
          if (widget.courseId != null) {
            context.go('/course/${widget.courseId}');
          } else {
            while (context.canPop()) {
              context.pop();
            }
          }
        },
      );
    }

    if (quiz.quiz == null || quiz.quiz!.questions.isEmpty) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: S.scale(context, 56),
                color: t.mutedText,
              ),
              SizedBox(height: S.scale(context, 12)),
              Text(
                'Belum ada soal',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: S.font(context, 16),
                ),
              ),
              SizedBox(height: S.scale(context, 8)),
              Text(
                'Soal untuk kuis ini belum ditambahkan.',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.font(context, 13),
                ),
              ),
              SizedBox(height: S.scale(context, 22)),
              Semantics(
                button: true,
                label: 'Kembali',
                child: Game3DButton(
                  label: 'Kembali',
                  color: t.primary,
                  shadowColor: darken(t.primary, 0.2),
                  textColor: t.primaryContent,
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final questions = quiz.quiz!.questions;
    final current = quiz.current!;
    final progress = (quiz.currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                S.scale(context, 16),
                S.scale(context, 12),
                S.scale(context, 16),
                0,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Tutup kuis',
                    child: Bounceable(
                      onTap: () {
                        sound.playClick();
                        _confirmExit(context, t);
                      },
                      child: Container(
                        width: S.scale(context, 36),
                        height: S.scale(context, 36),
                        decoration: BoxDecoration(
                          color: t.bgSurface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.border),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: t.textPrimary,
                          size: S.scale(context, 18),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: S.scale(context, 12)),
                  Expanded(
                    child: Text(
                      quiz.quiz!.title,
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontSize: S.font(context, 14),
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (quiz.quiz!.timeLimit > 0) ...[
                    QuizTimer(
                      timeLimitMinutes: quiz.quiz!.timeLimit,
                      t: t,
                      onTimeUp: () =>
                          ref.read(quizProvider.notifier).submit(widget.quizId),
                    ),
                    SizedBox(width: S.scale(context, 10)),
                  ],
                  VolumeButton(t: t),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                S.scale(context, 16),
                S.scale(context, 12),
                S.scale(context, 16),
                0,
              ),
              child: Row(
                children: [
                  Text(
                    '${quiz.currentIndex + 1}',
                    style: GoogleFonts.nunito(
                      color: t.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: S.font(context, 14),
                    ),
                  ),
                  Text(
                    '/${questions.length}',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: S.font(context, 14),
                    ),
                  ),
                  SizedBox(width: S.scale(context, 10)),
                  Expanded(
                    child: LinearPercentIndicator(
                      percent: progress,
                      lineHeight: S.scale(context, 10),
                      backgroundColor: t.bgSurface3,
                      progressColor: t.primary,
                      barRadius: Radius.circular(S.scale(context, 5)),
                      padding: EdgeInsets.zero,
                      animation: true,
                      animateFromLastPercent: true,
                    ),
                  ),
                  if (livesAsync.asData != null) ...[
                    SizedBox(width: S.scale(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 10),
                        vertical: S.scale(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: t.bgSurface3,
                        borderRadius: BorderRadius.circular(S.scale(context, 50)),
                        border: Border.all(color: t.border),
                      ),
                      child: Semantics(
                        label: 'Nyawa ${livesAsync.asData!.value.current} dari ${livesAsync.asData!.value.max}',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: S.scale(context, 14),
                              color: t.error,
                            ),
                            SizedBox(width: S.scale(context, 4)),
                            Text(
                              '${livesAsync.asData!.value.current}',
                              style: GoogleFonts.nunito(
                                color: t.textPrimary,
                                fontSize: S.font(context, 12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: S.isTablet(context) ? 600 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(S.scale(context, 20)),
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        final isLandscape =
                            orientation == Orientation.landscape;

                        Widget questionWidget = QuestionCard(
                          type: current.type,
                          arrangeVariant: current.arrangeVariant,
                          text: current.text,
                          codeSnippet: current.codeSnippet,
                          t: t,
                        ).animate().fadeIn().slideY(begin: -0.05);

                        Widget answersWidget;
                        if (current.type == 'choice') {
                          answersWidget = ChoiceQuestion(
                            options: current.optionObjects,
                            selectedId: quiz.answers[current.id]?.toString(),
                            t: t,
                            onSelect: (optionId) => ref
                                .read(quizProvider.notifier)
                                .answer(current.id, optionId),
                          );
                        } else if (current.type == 'arrange' ||
                            current.type == 'complete_word') {
                          answersWidget = ArrangeQuestion(
                            questionId: current.id,
                            variant: current.type == 'complete_word'
                                ? 'complete_word'
                                : current.arrangeVariant,
                            options: current.optionObjects,
                            blocks: current.blocks,
                            questionText: current.text,
                            t: t,
                            onAnswer: (answer) => ref
                                .read(quizProvider.notifier)
                                .answer(current.id, answer),
                          );
                        } else {
                          answersWidget = EssayQuestion(
                            key: ValueKey(current.id),
                            t: t,
                            onChanged: (v) => ref
                                .read(quizProvider.notifier)
                                .answer(current.id, v),
                          );
                        }

                        if (isLandscape) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: questionWidget),
                              SizedBox(width: S.scale(context, 16)),
                              Expanded(flex: 3, child: answersWidget),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            questionWidget,
                            SizedBox(height: S.scale(context, 18)),
                            answersWidget,
                            SizedBox(height: S.scale(context, 32)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (quiz.lastAnswerResult != null)
              QuizFeedbackPopup(
                result: quiz.lastAnswerResult!,
                t: t,
                isLast: quiz.isLast,
                currentQuestion: quiz.current,
                currentStreak: quiz.currentStreak,
                livesRemaining: quiz.lastAnswerResult!.livesRemaining,
                previousLivesRemaining: _previousLivesRemaining,
                onLanjut: () {
                  _previousLivesRemaining =
                      quiz.lastAnswerResult!.livesRemaining;
                  final lives = quiz.lastAnswerResult!.livesRemaining;
                  if (lives != null &&
                      lives <= 0 &&
                      !quiz.isLast &&
                      !quiz.lastAnswerResult!.isCorrect) {
                    sound.playGameOver();
                    _showGameOverDialog(context, t);
                    return;
                  }
                  ref.read(quizProvider.notifier).clearLastAnswerResult();
                  if (quiz.isLast) {
                    ref.read(quizProvider.notifier).submit(widget.quizId);
                  } else {
                    ref.read(quizProvider.notifier).next();
                  }
                },
              )
            else
              BottomBar(quiz: quiz, quizId: widget.quizId, t: t),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, BloomTheme t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.scale(context, 16)),
          side: BorderSide(color: t.textPrimary, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.favorite_rounded,
              color: t.error,
              size: S.scale(context, 24),
            ),
            SizedBox(width: S.scale(context, 8)),
            Text(
              'Nyawa Habis!',
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nyawa kamu habis. Beli nyawa di Store untuk melanjutkan kuis.',
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 13),
              ),
            ),
            SizedBox(height: S.scale(context, 20)),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Keluar dari kuis',
                    child: Game3DButton(
                      label: 'Keluar',
                      color: t.bgSurface2,
                      shadowColor: t.textPrimary,
                      textColor: t.textPrimary,
                      horizontalPadding: S.scale(context, 16),
                      verticalPadding: S.scale(context, 10),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(quizProvider.notifier).reset();
                        context.pop();
                      },
                    ),
                  ),
                ),
                SizedBox(width: S.scale(context, 12)),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Beli nyawa di Store',
                    child: Game3DButton(
                      label: 'Beli Nyawa',
                      color: t.error,
                      shadowColor: t.textPrimary,
                      textColor: Colors.white,
                      horizontalPadding: S.scale(context, 16),
                      verticalPadding: S.scale(context, 10),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(quizProvider.notifier).clearLastAnswerResult();
                        ref.read(navIndexProvider.notifier).state = 3;
                        context.go('/home');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context, BloomTheme t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.scale(context, 16)),
          side: BorderSide(color: t.textPrimary, width: 2),
        ),
        title: Text(
          'Keluar dari Kuis?',
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Progres kuis sudah tersimpan. Kamu dapat melanjutkan kuis ini kapan saja.',
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 13),
              ),
            ),
            SizedBox(height: S.scale(context, 20)),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Lanjut mengerjakan kuis',
                    child: Game3DButton(
                      label: 'Lanjut',
                      color: t.primary,
                      shadowColor: t.textPrimary,
                      textColor: t.primaryContent,
                      horizontalPadding: S.scale(context, 16),
                      verticalPadding: S.scale(context, 10),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                SizedBox(width: S.scale(context, 12)),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Keluar dari kuis',
                    child: Game3DButton(
                      label: 'Keluar',
                      color: t.error,
                      shadowColor: darken(t.error, 0.25),
                      textColor: Colors.white,
                      horizontalPadding: S.scale(context, 16),
                      verticalPadding: S.scale(context, 10),
                      onTap: () {
                        Navigator.pop(context);
                        context.pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}