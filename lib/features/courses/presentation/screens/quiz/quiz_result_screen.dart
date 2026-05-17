import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../shared/providers/gamification_providers.dart';
import '../../providers/course_provider.dart';
import '../../../data/models/course_model.dart';
import 'quiz_review_dialog.dart';

class QuizStat extends StatelessWidget {
  final BloomTheme t;
  final String emoji, value, label;
  const QuizStat(this.t, this.emoji, this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Text(
        value,
        style: GoogleFonts.nunito(
          color: t.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.nunito(
          color: t.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class QuizResultScreen extends ConsumerWidget {
  final QuizResultModel result;
  final BloomTheme t;
  final String? courseId;
  final String quizId;
  final VoidCallback onRetry;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.t,
    required this.courseId,
    required this.quizId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = result.percentage.round();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      invalidateGamificationProviders(
        ref,
        courseId: (courseId?.isNotEmpty ?? false) ? courseId! : null,
        quizId: quizId,
      );
    });

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result.passed ? '\u{1F3C6}' : '\u{1F605}',
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 20),
                Text(
                  result.passed ? 'Luar Biasa! \u{1F389}' : 'Belum Berhasil',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  result.passed
                      ? 'Kamu berhasil melewati kuis ini!'
                      : 'Nilai kamu $pct%. Kerjakan lagi untuk mendapat nilai lebih baik.',
                  style: GoogleFonts.nunito(
                    color: t.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: result.passed
                          ? [t.accent.withValues(alpha: 0.3), t.info.withValues(alpha: 0.2)]
                          : [
                              t.error.withValues(alpha: 0.2),
                              t.error.withValues(alpha: 0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: result.passed
                          ? t.accent.withValues(alpha: 0.3)
                          : t.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuizStat(t, '\u{1F4CA}', '$pct%', 'Nilai'),
                      Container(
                        width: 1,
                        height: 50,
                        color: t.textSecondary.withValues(alpha: 0.2),
                      ),
                      QuizStat(
                        t,
                        '\u{1F3AF}',
                        '${result.score}/${result.totalPoints}',
                        'Poin',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: t.textSecondary.withValues(alpha: 0.2),
                      ),
                      QuizStat(t, '\u{2B50}', '+${result.xpEarned}', 'XP'),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15),
                if (result.questionResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Game3DButton(
                      color: Colors.transparent,
                      shadowColor: t.accent,
                      textColor: t.accent,
                      horizontalPadding: 20,
                      verticalPadding: 13,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReviewDialog(
                            questionResults: result.questionResults,
                            questions: ref.read(quizProvider).quiz?.questions ?? [],
                            t: t,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_rounded,
                              color: t.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Lihat Jawaban',
                            style: GoogleFonts.nunito(
                              color: t.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 550.ms),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Game3DButton(
                    color: t.accent,
                    shadowColor: darken(t.accent, 0.2),
                    textColor: t.accentText,
                    horizontalPadding: 20,
                    verticalPadding: 15,
                    onTap: () {
                      ref.read(quizProvider.notifier).reset();
                      context.pop();
                      context.pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, color: t.accentText, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Kembali ke Peta Belajar',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: t.accentText,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ),
                if (!result.passed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Game3DButton(
                      color: Colors.transparent,
                      shadowColor: t.accent,
                      textColor: t.accent,
                      horizontalPadding: 20,
                      verticalPadding: 15,
                      onTap: () => onRetry(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded, color: t.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Coba Lagi',
                            style: GoogleFonts.nunito(
                              color: t.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 650.ms),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
