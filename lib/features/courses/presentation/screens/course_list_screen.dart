import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../../../../shared/widgets/slow_loading_indicator.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/silent_refresh_mixin.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shared/presentation/providers/fetch_state_providers.dart';
import '../providers/course_provider.dart';

import '../../data/models/course_model.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> with SilentRefreshMixin<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    final fetchState = ref.read(courseListFetchProvider.notifier);
    if (!fetchState.shouldRefresh) return;

    silentFetch(
      fetch: () async {
        ref.invalidate(coursesProvider);
        ref.invalidate(enrolledCoursesProvider);
        await Future.wait([
          ref.read(coursesProvider.future),
          ref.read(enrolledCoursesProvider.future),
        ]);
      },
      fetchState: fetchState,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 0 && next == 0) {
        ref.invalidate(coursesProvider);
        ref.invalidate(enrolledCoursesProvider);
        _silentRefresh();
      }
    });

    final t            = ref.watch(currentThemeProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final enrolledAsync = ref.watch(enrolledCoursesProvider);

    ref.listen(enrolledCoursesProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(sanitizeErrorMessage(e),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                backgroundColor: t.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            SlowLoadingIndicator(
              visible: showSlowIndicator,
              t: t,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _silentRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Header banner ─────────────────────────────────────────────
                    SliverToBoxAdapter(child: _HeaderBanner(
                      courseCount: coursesAsync.maybeWhen(
                        data: (courses) => courses.length,
                        orElse: () => 0,
                      ),
                      t: t,
                    )),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // ── Courses list ───────────────────────────────────────────────
                    coursesAsync.when(
                        loading: () => SliverFillRemaining(
                          child: LoadingCircle(t: t),
                        ),
                      error: (e, _) => SliverFillRemaining(
                        child: ErrorBody(
                          t: t,
                          icon: iconForError(e),
                          title: AppStrings.errLoadCourses,
                          message: sanitizeErrorMessage(e),
                          onRetry: () {
                            setShowSlowIndicator(true);
                            ref.invalidate(coursesProvider);
                          },
                        ),
                      ),
                      data: (courses) {
                        return enrolledAsync.when(
                            loading: () => SliverFillRemaining(
                              child: LoadingCircle(t: t),
                            ),
                          error: (_, __) => _buildCourseList(
                            context, ref, courses, t,
                          ),
                          data: (enrollmentMap) => _buildCourseList(
                            context, ref,
                            getEnrichedCourses(courses, enrollmentMap),
                            t,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(
    BuildContext context,
    WidgetRef ref,
    List<CourseModel> courses,
    BloomTheme t,
  ) {
    if (courses.isEmpty) {
      return SliverFillRemaining(child: _EmptyState(t: t));
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final course = courses[i];
            return _CourseCard(
              course: course,
              index: i,
              t: t,
            ).animate().fadeIn(delay: (60 * i).ms)
             .slideY(begin: 0.08, end: 0);
          },
          childCount: courses.length,
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final int courseCount;
  final BloomTheme t;
  const _HeaderBanner({required this.courseCount, required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: t.primary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, size: 24, color: t.primaryContent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Pilih Kursusmu',
                        style: GoogleFonts.nunito(
                            color: t.primaryContent,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Mulai perjalanan belajarmu dan kuasai skill baru!',
                  style: GoogleFonts.nunito(
                      color: t.primaryContent.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: t.primaryContent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.textPrimary, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: t.primaryContent.withValues(alpha: 0.9)),
                    const SizedBox(width: 6),
                    Text('$courseCount Kursus Tersedia',
                        style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final BloomTheme t;
  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80),
        decoration: BoxDecoration(
          color: t.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.textPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.menu_book, size: 64, color: t.mutedText.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Belum ada kursus nih',
              style: GoogleFonts.nunito(color: t.textPrimary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Sabar ya, admin lagi nyiapin kursus kece buat kamu!',
              style: GoogleFonts.nunito(color: t.mutedText, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

class _CourseCard extends ConsumerStatefulWidget {
  final CourseModel course;
  final int index;
  final BloomTheme t;
  const _CourseCard({required this.course, required this.index, required this.t});

  @override
  ConsumerState<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<_CourseCard> {
  bool _isEnrolling = false;

  Future<void> _enroll() async {
    setState(() => _isEnrolling = true);
    try {
      await ref.read(courseDsProvider).enrollCourse(widget.course.id);
      ref.invalidate(coursesProvider);
      ref.invalidate(enrolledCoursesProvider);
      if (mounted) context.push('/course/${widget.course.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal enroll: ${sanitizeErrorMessage(e)}',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              backgroundColor: widget.t.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final index = widget.index;
    final t = widget.t;
    final isEnrolled = course.isEnrolled;
    final isCompleted = course.isCompleted;
    final progress = course.progress > 0
        ? course.progress
        : (course.totalLessons > 0
            ? course.completedLessons / course.totalLessons
            : 0.0);
    final progressPct = (progress * 100).toInt();

    // DaisyUI cycling header colors
    final palettes = <(Color, Color)>[
      (t.primary, t.primaryContent),
      (t.success, t.primaryContent),
      (t.warning, Colors.white),
      (t.info, t.primaryContent),
      (t.success, Colors.white),
      (t.info, t.primaryContent),
    ];
    final (headerBg, headerFg) = palettes[index % palettes.length];

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail / Gradient header
          Hero(
            tag: 'course-thumb-${course.id}',
            child: Container(
              height: 144,
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                image: course.thumbnail != null
                    ? DecorationImage(
                        image: NetworkImage(course.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            child: Stack(
              children: [
                // Book icon
                if (course.thumbnail == null)
                  Center(
                    child: Icon(Icons.menu_book, size: 56, color: headerFg.withValues(alpha: 0.8)),
                  ),
                // Status badges top-right
                if (isCompleted)
                  Positioned(
                    right: 12, top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: t.textPrimary, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: t.primary),
                          const SizedBox(width: 4),
                          Text('Selesai',
                              style: GoogleFonts.nunito(
                                  color: t.primary, fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                if (isEnrolled && !isCompleted)
                  Positioned(
                    right: 12, top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: t.textPrimary, width: 2),
                      ),
                      child: Text('Enrolled',
                          style: GoogleFonts.nunito(
                              color: t.primary, fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          ), // Hero
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'course-title-${course.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(course.title,
                        style: GoogleFonts.nunito(
                            color: t.textPrimary, fontSize: 16,
                            fontWeight: FontWeight.w800),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
                if (course.description != null && course.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(course.description!,
                      style: GoogleFonts.nunito(
                          color: t.mutedText, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Text('${course.totalLessons} lesson',
                    style: GoogleFonts.nunito(
                        color: t.mutedText, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (isEnrolled) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress',
                          style: GoogleFonts.nunito(
                              color: t.mutedText, fontSize: 11)),
                      Text('$progressPct%',
                          style: GoogleFonts.nunito(
                              color: t.textPrimary, fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: t.bgSurface2,
                      valueColor: AlwaysStoppedAnimation(t.primary),
                      minHeight: 10,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // CTA
                if (isEnrolled)
                  Semantics(
                    label: isCompleted ? 'Ulangi kursus ${course.title}' : 'Lanjutkan kursus ${course.title}',
                    child: Bounceable(
                      onTap: () => context.push('/course/${course.id}'),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: t.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.textPrimary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                Icon(Icons.check, size: 16, color: t.success),
                              Text(
                                isCompleted ? ' Ulangi' : 'Lanjutkan',
                                style: GoogleFonts.nunito(
                                    color: t.textPrimary, fontSize: 13,
                                    fontWeight: FontWeight.w800),
                              ),
                              if (!isCompleted) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 16, color: t.textPrimary),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isEnrolled)
                  Semantics(
                    label: _isEnrolling ? 'Memproses pendaftaran' : 'Mulai kursus ${course.title}',
                    child: Bounceable(
                      onTap: _isEnrolling ? null : _enroll,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.textPrimary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isEnrolling
                              ? SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: t.primaryContent,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Mulai',
                                        style: GoogleFonts.nunito(
                                            color: t.primaryContent, fontSize: 13,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 16, color: t.primaryContent),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return card;
  }
}


