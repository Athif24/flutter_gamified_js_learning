import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../data/models/lesson_model.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../shared/widgets/celebration_screen.dart';
import '../../../../shared/widgets/volume_control.dart';
import '../../../../shared/providers/gamification_providers.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/course_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/services/sound_service.dart';
import '../widgets/prose_mirror_renderer.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String? courseId;

  const LessonScreen({super.key, required this.lessonId, this.courseId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with SilentRefreshMixin<LessonScreen> {
  bool _isProcessing = false;

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
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final sound = ref.watch(soundProvider);
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));
    final quizAsync = ref.watch(lessonQuizProvider(widget.lessonId));
    final effectiveQuizId = quizAsync.whenOrNull(data: (q) => q?.id);
    final lessonData = lessonAsync.whenOrNull(data: (l) => l);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            return Column(
              children: [
                SlowLoadingIndicator(visible: showSlowIndicator, t: t),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    S.scale(context, 12),
                    S.scale(context, isLandscape ? 4 : 8),
                    S.scale(context, 12),
                    0,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Kembali',
                        child: Bounceable(
                          onTap: () {
                            sound.playClick();
                            if (context.canPop()) {
                              context.pop();
                            } else if (widget.courseId != null) {
                              context.go('/course/${widget.courseId}');
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
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
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
                      ),
                      lessonAsync.whenOrNull(
                            data: (lesson) => Expanded(
                              child: Row(
                                children: [
                                  SizedBox(width: S.scale(context, 12)),
                                  Semantics(
                                    label: '${lesson.title}, ${lesson.type}',
                                    child: Text(
                                      lesson.title,
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontSize: S.font(context, 15),
                                        fontWeight: FontWeight.w800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  VolumeButton(t: t),
                                  SizedBox(width: S.scale(context, 8)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: S.scale(context, 10),
                                      vertical: S.scale(context, 5),
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(S.scale(context, 50)),
                                      border: Border.all(
                                        color: t.textPrimary,
                                        width: S.scale(context, 2),
                                      ),
                                    ),
                                    child: Text(
                                      lesson.type.toUpperCase(),
                                      style: GoogleFonts.nunito(
                                        color: t.primary,
                                        fontSize: S.font(context, 10),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ) ??
                          const Spacer(),
                    ],
                  ),
                ),
                if (lessonData != null) _buildRewardBadges(t, lessonData),
                Expanded(
                  child: lessonAsync.when(
                    loading: () => LoadingCircle(t: t),
                    error: (e, _) => ErrorBody(
                      t: t,
                      icon: iconForError(e),
                      title: AppStrings.errLoadLesson,
                      message: sanitizeErrorMessage(e),
                      onRetry: () {
                        setShowSlowIndicator(true);
                        ref.invalidate(lessonDetailProvider(widget.lessonId));
                        ref.invalidate(lessonQuizProvider(widget.lessonId));
                      },
                    ),
                    data: (lesson) {
                      final isCompleted = lesson.isCompleted;
                      return Column(
                        children: [
                          // ── Content ──────────────────────────────────────────────────
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(
                                  lessonDetailProvider(widget.lessonId),
                                );
                                ref.invalidate(
                                  lessonQuizProvider(widget.lessonId),
                                );
                              },
                              child: LayoutBuilder(
                                builder: (_, constraints) =>
                                    SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        S.scale(context, 20),
                                        S.scale(context, 16),
                                        S.scale(context, 20),
                                        S.scale(context, 20),
                                      ),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: S.isTablet(context)
                                                ? 600
                                                : double.infinity,
                                            minHeight: constraints.maxHeight,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (lesson.content != null)
                                                ProseMirrorRenderer(
                                                  content: lesson.content!,
                                                  t: t,
                                                ).animate().fadeIn(
                                                  delay: 100.ms,
                                                )
                                              else
                                                _buildEmptyContent(t),
                                              SizedBox(height: S.scale(context, 32)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),

                          // ── Bottom button ─────────────────────────────────────────────
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              S.scale(context, 20),
                              S.scale(context, 12),
                              S.scale(context, 20),
                              S.scale(context, 28),
                            ),
                            decoration: BoxDecoration(
                              color: t.bgSurface,
                              border: Border(
                                top: BorderSide(color: t.textPrimary, width: S.scale(context, 2)),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: t.textPrimary,
                                  offset: Offset(0, S.scale(context, -3)),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: SafeArea(
                              top: false,
                              child: Semantics(
                                button: true,
                                label: isCompleted
                                    ? 'Selesai'
                                    : effectiveQuizId != null
                                    ? 'Kerjakan Quiz'
                                    : AppStrings.markComplete,
                                child: Bounceable(
                                  onTap: _isProcessing || isCompleted
                                      ? null
                                      : () {
                                          sound.playClick();
                                          _handleBottomButton(
                                            context,
                                            ref,
                                            t,
                                            effectiveQuizId,
                                          );
                                        },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: S.scale(context, 15),
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? t.success.withValues(alpha: 0.2)
                                          : t.primary,
                                      borderRadius: BorderRadius.circular(S.scale(context, 10)),
                                      border: Border.all(
                                        color: isCompleted
                                            ? t.success.withValues(alpha: 0.4)
                                            : t.textPrimary,
                                        width: S.scale(context, 2),
                                      ),
                                      boxShadow: isCompleted
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: t.textPrimary,
                                                offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                                                blurRadius: 0,
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isProcessing)
                                          SizedBox(
                                            width: S.scale(context, 18),
                                            height: S.scale(context, 18),
                                            child: CircularProgressIndicator(
                                              strokeWidth: S.scale(context, 2),
                                              color: t.primaryContent,
                                            ),
                                          )
                                        else ...[
                                          Icon(
                                            isCompleted
                                                ? Icons.check_circle_rounded
                                                : effectiveQuizId != null
                                                ? Icons.quiz_rounded
                                                : Icons.check_rounded,
                                            color: isCompleted
                                                ? t.success
                                                : t.primaryContent,
                                            size: S.scale(context, 18),
                                          ),
                                          SizedBox(width: S.scale(context, 8)),
                                          Text(
                                            isCompleted
                                                ? 'Selesai!'
                                                : effectiveQuizId != null
                                                ? 'Kerjakan Quiz →'
                                                : AppStrings.markComplete,
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w800,
                                              fontSize: S.font(context, 15),
                                              color: isCompleted
                                                  ? t.success
                                                  : t.primaryContent,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRewardBadges(BloomTheme t, LessonModel lesson) {
    final hasXp = lesson.xpReward > 0;
    final hasJewel = lesson.jewelReward > 0;
    if (!hasXp && !hasJewel) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 20),
        vertical: S.scale(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasXp)
            _badgeChip(
              t,
              Icons.bolt_rounded,
              lesson.xpReward.toString(),
              'XP',
              t.warning,
            ),
          if (hasXp && hasJewel) SizedBox(width: S.scale(context, 8)),
          if (hasJewel)
            _badgeChip(
              t,
              Icons.diamond_rounded,
              lesson.jewelReward.toString(),
              'Jewel',
              t.primary,
            ),
        ],
      ),
    );
  }

  Widget _badgeChip(
    BloomTheme t,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 10),
        vertical: S.scale(context, 5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(S.scale(context, 50)),
        border: Border.all(color: color.withValues(alpha: 0.3), width: S.scale(context, 1.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: S.font(context, 14), color: color),
          SizedBox(width: S.scale(context, 4)),
          Text(
            '$value $label',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: S.font(context, 11),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BloomTheme t) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: S.scale(context, 48)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: S.scale(context, 48),
              color: t.mutedText.withValues(alpha: 0.2),
            ),
            SizedBox(height: S.scale(context, 16)),
            Text(
              'Konten materi belum tersedia.',
              style: GoogleFonts.nunito(
                color: t.mutedText,
                fontSize: S.font(context, 14),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBottomButton(
    BuildContext context,
    WidgetRef ref,
    BloomTheme t,
    String? effectiveQuizId,
  ) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (effectiveQuizId != null) {
        invalidateGamificationProviders(ref, courseId: widget.courseId);
        if (context.mounted) {
          context.push(
            Uri(
              path: '/quiz-intro/$effectiveQuizId',
              queryParameters: {
                if (widget.courseId != null) 'courseId': widget.courseId,
                'lessonId': widget.lessonId,
              },
            ).toString(),
          );
        }
        return;
      }

      final result = await ref
          .read(courseDsProvider)
          .completeLesson(widget.lessonId);

      invalidateGamificationProviders(ref, courseId: widget.courseId);

      if (!context.mounted) return;

      if (!result.alreadyCompleted && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => CelebrationScreen(
              xpEarned: result.xpEarned,
              jewelsEarned: result.jewelsEarned,
              streak: result.streak,
              levelUp: result.levelUp,
              badges: result.badgesAwarded,
              onContinue: () => Navigator.of(ctx).pop(),
            ),
            fullscreenDialog: true,
          ),
        );
      }

      if (context.mounted) {
        context.pop();
        if (widget.courseId != null) {
          ref.invalidate(courseDetailProvider(widget.courseId!));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sanitizeErrorMessage(e),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: t.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
