import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/loading_circle.dart';
import '../providers/course_provider.dart';

import '../../data/models/course_model.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 0 && next == 0) {
        ref.invalidate(coursesProvider);
        ref.invalidate(enrolledCoursesProvider);
      }
    });

    final t            = ref.watch(currentThemeProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final enrolledAsync = ref.watch(enrolledCoursesProvider);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.invalidate(coursesProvider);
            ref.invalidate(enrolledCoursesProvider);
            return Future.value();
          },
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
                  child: _ErrorView(t: t, message: e.toString(),
                      onRetry: () => ref.refresh(coursesProvider)),
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
          color: t.accent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.border,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // Decorative blur circles
              Positioned(
                right: -40, top: -40,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accentText.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -32, bottom: -32,
                child: Container(
                  width: 128, height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accentDark.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, size: 24, color: t.accentText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Pilih Kursusmu',
                              style: GoogleFonts.nunito(
                                  color: t.accentText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Mulai perjalanan belajarmu dan kuasai skill baru!',
                        style: GoogleFonts.nunito(
                            color: t.accentText.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: t.accentText.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: t.accentText.withValues(alpha: 0.9)),
                          const SizedBox(width: 6),
                          Text('$courseCount Kursus Tersedia',
                              style: GoogleFonts.nunito(
                                  color: t.accentText.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: t.border.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.menu_book, size: 64, color: t.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Belum ada kursus nih',
              style: GoogleFonts.nunito(color: t.textPrimary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Sabar ya, admin lagi nyiapin kursus kece buat kamu!',
              style: GoogleFonts.nunito(color: t.textHint, fontSize: 13),
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
          SnackBar(content: Text('Gagal enroll: $e')),
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
      (t.accent, t.accentText),
      (t.success, t.accentText),
      (t.warning, Colors.white),
      (t.info, t.accentText),
      (t.success, Colors.white),
      (t.info, t.accentText),
    ];
    final (headerBg, headerFg) = palettes[index % palettes.length];

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: t.border,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail / Gradient header
          Container(
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
                        color: t.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: t.accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: t.accent),
                          const SizedBox(width: 4),
                          Text('Selesai',
                              style: GoogleFonts.nunito(
                                  color: t.accent, fontSize: 10,
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
                        color: t.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: t.accent.withValues(alpha: 0.4)),
                      ),
                      child: Text('Enrolled',
                          style: GoogleFonts.nunito(
                              color: t.accent, fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: GoogleFonts.nunito(
                        color: t.textPrimary, fontSize: 16,
                        fontWeight: FontWeight.w800),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                if (course.description != null && course.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(course.description!,
                      style: GoogleFonts.nunito(
                          color: t.textSecondary, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Text('${course.totalLessons} lesson',
                    style: GoogleFonts.nunito(
                        color: t.textSecondary, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (isEnrolled) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress',
                          style: GoogleFonts.nunito(
                              color: t.textSecondary, fontSize: 11)),
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
                      valueColor: AlwaysStoppedAnimation(t.accent),
                      minHeight: 10,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // CTA
                if (isEnrolled)
                  Bounceable(
                    onTap: () => context.push('/course/${course.id}'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
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
                if (!isEnrolled)
                  Bounceable(
                    onTap: _isEnrolling ? null : _enroll,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.border,
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
                                  color: t.accentText,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Mulai',
                                      style: GoogleFonts.nunito(
                                          color: t.accentText, fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16, color: t.accentText),
                                ],
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

class _ErrorView extends StatelessWidget {
  final BloomTheme t;
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.t, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('😢', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Gagal memuat kursus',
          style: GoogleFonts.nunito(color: t.textPrimary,
              fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 8),
      Text(message, style: GoogleFonts.nunito(
          color: t.textSecondary, fontSize: 12),
          textAlign: TextAlign.center, maxLines: 3),
      const SizedBox(height: 22),
      Bounceable(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
              color: t.accent, borderRadius: BorderRadius.circular(50)),
          child: Text('Coba Lagi', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: t.accentText)),
        ),
      ),
    ]),
  ));
}
