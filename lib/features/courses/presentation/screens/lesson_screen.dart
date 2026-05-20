import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/celebration_screen.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/course_provider.dart';
import '../widgets/prose_mirror_renderer.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String? courseId;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.courseId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> with SilentRefreshMixin<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(lessonFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(lessonDetailProvider(widget.lessonId));
        ref.invalidate(lessonQuizProvider(widget.lessonId));
        await ref.read(lessonDetailProvider(widget.lessonId).future);
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t           = ref.watch(currentThemeProvider);
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));
    final quizAsync   = ref.watch(lessonQuizProvider(widget.lessonId));
    final effectiveQuizId = quizAsync.whenOrNull(data: (q) => q?.id);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Column(
        children: [
          SlowLoadingIndicator(
            visible: showSlowIndicator,
            t: t,
          ),
          SafeArea(
            bottom: false,
            child: lessonAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (lesson) => Padding(
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
          ),
          Expanded(
            child: lessonAsync.when(
              loading: () => LoadingCircle(t: t),
              error: (e, _) => _ErrorBody(
                  t: t, message: e.toString(),
                  onRetry: () => ref.refresh(lessonDetailProvider(widget.lessonId))),
              data: (lesson) {
                debugPrint('[FULL CONTENT] ${lesson.content}');
                return Column(children: [
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
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: t.border, width: 2),
                            boxShadow: [BoxShadow(
                              color: t.border,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
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
                                    : AppStrings.markComplete,
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
          ),
        ],
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
        courseId: widget.courseId,
      );
      if (context.mounted) {
        context.push('/quiz-intro/$effectiveQuizId?courseId=${widget.courseId ?? ''}');
      }
      return;
    }

    try {
      final result = await ref.read(courseDsProvider).completeLesson(widget.lessonId);

      invalidateGamificationProviders(
        ref,
        courseId: widget.courseId,
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
          content: Text(sanitizeErrorMessage(e),
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
      Text(AppStrings.errLoadLesson, style: GoogleFonts.nunito(
          color: t.textPrimary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text(AppStrings.retry, style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ],
  ));
}