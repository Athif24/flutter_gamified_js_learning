import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../shared/widgets/celebration_screen.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';
import 'quiz/question_card.dart';
import 'quiz/choice_question.dart';
import 'quiz/essay_question.dart';
import 'quiz/arrange_question.dart';
import 'quiz/coding_question.dart';
import 'quiz/quiz_timer.dart';
import 'quiz/quiz_feedback_popup.dart';
import 'quiz/bottom_bar.dart';
import 'quiz/quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? courseId;

  const QuizScreen({super.key, required this.quizId, this.courseId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _showCelebration = true;

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

    if (quiz.quiz == null && quiz.error == null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }

    if (quiz.error != null) {
      return Scaffold(
        backgroundColor: t.bgPrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u{1F622}', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat kuis',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.error!,
                  style: GoogleFonts.nunito(
                    color: t.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Game3DButton(
                  label: 'Kembali',
                  color: t.accent,
                  shadowColor: darken(t.accent, 0.2),
                  textColor: t.accentText,
                  onTap: () {
                    ref.read(quizProvider.notifier).reset();
                    context.pop();
                  },
                ),
              ],
            ),
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
        onRetry: () {
          ref.read(quizProvider.notifier).reset();
          context.pushReplacement(
            '/quiz-intro/${widget.quizId}${widget.courseId != null ? '?courseId=${widget.courseId}' : ''}',
          );
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
              const Text('\u{1F4CB}', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Belum ada soal',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Soal untuk kuis ini belum ditambahkan.',
                style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Game3DButton(
                label: 'Kembali',
                color: t.accent,
                shadowColor: darken(t.accent, 0.2),
                textColor: t.accentText,
                onTap: () => context.pop(),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Bounceable(
                    onTap: () => _confirmExit(context, t),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: t.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quiz.quiz!.title,
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (quiz.quiz!.timeLimit > 0) ...[
                    QuizTimer(
                      timeLimitMinutes: quiz.quiz!.timeLimit,
                      t: t,
                      onTimeUp: () => ref.read(quizProvider.notifier).submit(widget.quizId),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: t.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '\u{2B50} +${current.points} XP',
                      style: GoogleFonts.nunito(
                        color: t.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    '${quiz.currentIndex + 1}',
                    style: GoogleFonts.nunito(
                      color: t.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '/${questions.length}',
                    style: GoogleFonts.nunito(
                      color: t.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearPercentIndicator(
                      percent: progress,
                      lineHeight: 10,
                      backgroundColor: t.bgSurface3,
                      progressColor: t.accent,
                      barRadius: const Radius.circular(5),
                      padding: EdgeInsets.zero,
                      animation: true,
                      animateFromLastPercent: true,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionCard(
                      type: current.type,
                      arrangeVariant: current.arrangeVariant,
                      text: current.text,
                      codeSnippet: current.codeSnippet,
                      t: t,
                    ).animate().fadeIn().slideY(begin: -0.05),
                    const SizedBox(height: 18),
                    if (current.type == 'choice')
                      ChoiceQuestion(
                        options: current.optionObjects,
                        selectedId: quiz.answers[current.id]?.toString(),
                        t: t,
                        onSelect: (optionId) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, optionId),
                      )
                    else if (current.type == 'arrange' || current.type == 'complete_word')
                      ArrangeQuestion(
                        variant: current.type == 'complete_word' ? 'complete_word' : current.arrangeVariant,
                        options: current.optionObjects,
                        blocks: current.blocks,
                        questionText: current.text,
                        t: t,
                        onAnswer: (answer) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, answer),
                      )
                    else if (current.type == 'coding')
                      CodingQuestion(
                        t: t,
                        codeSnippet: current.codeSnippet,
                        codeTemplate: current.codeTemplate,
                        onChanged: (v) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, v),
                      )
                    else
                      EssayQuestion(
                        t: t,
                        onChanged: (v) => ref
                            .read(quizProvider.notifier)
                            .answer(current.id, v),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (quiz.lastAnswerResult != null)
              QuizFeedbackPopup(
                result: quiz.lastAnswerResult!,
                t: t,
                isLast: quiz.isLast,
                currentQuestion: quiz.current,
                onLanjut: () {
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

  void _confirmExit(BuildContext context, BloomTheme t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar dari Kuis?',
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Progress kuis akan hilang.',
          style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Lanjut',
              style: GoogleFonts.nunito(
                color: t.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Game3DButton(
            label: 'Keluar',
            color: t.error,
            shadowColor: darken(t.error, 0.25),
            textColor: Colors.white,
            horizontalPadding: 16,
            verticalPadding: 8,
            onTap: () {
              ref.read(quizProvider.notifier).reset();
              Navigator.pop(context);
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
