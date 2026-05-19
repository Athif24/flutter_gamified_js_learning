import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/celebration_screen.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../providers/course_provider.dart';
import '../widgets/prose_mirror_renderer.dart';

class LessonScreen extends ConsumerWidget {
  final String lessonId;
  final String? courseId;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t           = ref.watch(currentThemeProvider);
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));
    final quizAsync   = ref.watch(lessonQuizProvider(lessonId));
    final effectiveQuizId = quizAsync.whenOrNull(data: (q) => q?.id);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: lessonAsync.when(
        loading: () => LoadingCircle(t: t),
        error: (e, _) => _ErrorBody(
            t: t, message: e.toString(),
            onRetry: () => ref.refresh(lessonDetailProvider(lessonId))),
        data: (lesson) {
          debugPrint('[FULL CONTENT] ${lesson.content}');
          return Column(children: [
          // ── AppBar ───────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                Bounceable(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: t.bgSurface2, shape: BoxShape.circle,
                        border: Border.all(color: t.border)),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: t.textPrimary, size: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(lesson.title,
                    style: GoogleFonts.nunito(
                        color: t.textPrimary, fontSize: 15,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: t.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(lesson.type.toUpperCase(),
                      style: GoogleFonts.nunito(
                          color: t.accent, fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lesson.content != null)
                        ProseMirrorRenderer(content: lesson.content!, t: t)
                            .animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom button ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: t.bgSurface,
              border: Border(top: BorderSide(color: t.border)),
            ),
            child: SafeArea(
              top: false,
              child: Bounceable(
                onTap: () => _handleBottomButton(
                    context, ref, t, effectiveQuizId),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(
                      color: t.accent.withValues(alpha: 0.4),
                      blurRadius: 12, offset: const Offset(0, 5),
                    )],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        effectiveQuizId != null
                            ? Icons.quiz_rounded
                            : Icons.check_rounded,
                        color: t.accentText, size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        effectiveQuizId != null
                            ? 'Kerjakan Quiz →'
                            : 'Tandai Selesai',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, fontSize: 15,
                            color: t.accentText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
      ),
    );
  }


  Future<void> _handleBottomButton(
    BuildContext context,
    WidgetRef ref,
    BloomTheme t,
    String? effectiveQuizId,
  ) async {
    if (effectiveQuizId != null) {
      invalidateGamificationProviders(
        ref,
        courseId: courseId,
      );
      if (context.mounted) {
        context.push('/quiz-intro/$effectiveQuizId?courseId=${courseId ?? ''}');
      }
      return;
    }

    try {
      final result = await ref.read(courseDsProvider).completeLesson(lessonId);

      invalidateGamificationProviders(
        ref,
        courseId: courseId,
      );

      if (!context.mounted) return;

      if (!result.alreadyCompleted && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CelebrationScreen(
              xpEarned: result.xpEarned,
              jewelsEarned: result.jewelsEarned,
              streak: result.streak,
              levelUp: result.levelUp,
              badges: result.badgesAwarded,
            ),
            fullscreenDialog: true,
          ),
        );
      }

      if (context.mounted) {
        context.pop();
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
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.t, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('😢', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Gagal memuat materi', style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text('Coba Lagi', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ],
  ));
}