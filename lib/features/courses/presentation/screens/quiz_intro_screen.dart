import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../achievement/presentation/providers/achievement_provider.dart';
import '../../../achievement/data/models/achievement_model.dart';
import '../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class QuizIntroScreen extends ConsumerWidget {
  final String quizId;
  final String? courseId;

  const QuizIntroScreen({
    super.key,
    required this.quizId,
    this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final previewAsync = ref.watch(quizPreviewProvider(quizId));
    final myResultAsync = ref.watch(myQuizResultProvider(quizId));
    final livesAsync = ref.watch(livesProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: previewAsync.when(
              loading: () => CircularProgressIndicator(color: t.accent),
              error: (e, _) => _ErrorState(t: t, message: e.toString(),
                  onRetry: () => ref.refresh(quizPreviewProvider(quizId))),
              data: (preview) => _IntroBody(
                preview: preview,
                myResult: myResultAsync.asData?.value,
                lives: livesAsync.asData?.value,
                t: t,
                ref: ref,
                quizId: quizId,
                courseId: courseId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroBody extends StatelessWidget {
  final QuizPreviewModel preview;
  final MyQuizResultResponse? myResult;
  final LivesModel? lives;
  final BloomTheme t;
  final WidgetRef ref;
  final String quizId;
  final String? courseId;

  const _IntroBody({
    required this.preview,
    required this.myResult,
    required this.lives,
    required this.t,
    required this.ref,
    required this.quizId,
    required this.courseId,
  });

  Color get _difficultyColor {
    return switch (preview.difficulty) {
      'easy' => t.success,
      'hard' => t.error,
      _ => t.warning,
    };
  }

  bool get _hasPreviousAttempt => myResult?.attempted ?? false;
  int get _currentLives => lives?.current ?? 0;
  int get _maxLives => lives?.max ?? 5;
  bool get _hasLives => _currentLives > 0;

  Future<void> _handleStart(BuildContext context) async {
    try {
      final startData = await ref.read(courseDsProvider).startQuiz(quizId);
      final quizData = QuizDetailModel.fromStartResponse(startData);
      ref.read(quizProvider.notifier).loadFromData(quizData);
      if (context.mounted) {
        context.pushReplacement('/quiz/$quizId${courseId != null ? '?courseId=$courseId' : ''}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: t.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: t.accent, width: 4),
                color: t.accent.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.quiz_rounded, color: t.accent, size: 40),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nyawa: ',
                style: GoogleFonts.nunito(
                    color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
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
        if (_hasPreviousAttempt)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: myResult!.isPassed
                  ? t.success.withValues(alpha: 0.1)
                  : t.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: myResult!.isPassed
                    ? t.success.withValues(alpha: 0.4)
                    : t.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nilai terakhirmu',
                    style: GoogleFonts.nunito(
                        color: t.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  '${myResult!.percentageScore}% ${myResult!.isPassed ? '✓ Lulus' : '✗ Belum Lulus'}',
                  style: GoogleFonts.nunito(
                    color: myResult!.isPassed ? t.success : t.error,
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
            color: t.textSecondary,
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
        Row(
          children: [
            Expanded(
              child: Game3DButton(
                label: 'Kembali',
                color: t.bgSurface2,
                shadowColor: t.border,
                textColor: t.textPrimary,
                horizontalPadding: 16,
                verticalPadding: 15,
                onTap: () => context.pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Game3DButton(
                label: _hasPreviousAttempt ? 'Coba Lagi' : 'Mulai Quiz',
                color: _hasLives ? t.accent : t.bgSurface3,
                shadowColor: _hasLives ? darken(t.accent, 0.2) : t.border,
                textColor: _hasLives ? t.accentText : t.textHint,
                horizontalPadding: 16,
                verticalPadding: 15,
                onTap: _hasLives ? () => _handleStart(context) : null,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.15),
        const SizedBox(height: 40),
      ],
    );
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

class _ErrorState extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.t, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 56),
        const SizedBox(height: 12),
        Text('Gagal memuat kuis',
            style: GoogleFonts.nunito(
                color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Text(message,
            style: GoogleFonts.nunito(color: t.textSecondary, fontSize: 12),
            textAlign: TextAlign.center),
        const SizedBox(height: 22),
        Game3DButton(
          label: 'Coba Lagi',
          color: t.accent,
          shadowColor: darken(t.accent, 0.2),
          textColor: t.accentText,
          onTap: onRetry,
        ),
      ],
    );
  }
}
