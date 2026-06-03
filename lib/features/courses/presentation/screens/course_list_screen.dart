import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/course_list/header_banner.dart';
import '../widgets/course_list/empty_state.dart';
import '../widgets/course_list/course_card.dart';
import '../widgets/course_list/course_list_skeleton.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/main_screen.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/course_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/course_model.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listenManual<int>(navIndexProvider, (prev, next) {
      if (prev != null && prev != 0 && next == 0) {
        ref.invalidate(coursesProvider);
        ref.invalidate(enrolledCoursesProvider);
      }
    });

    final t = ref.watch(currentThemeProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final enrolledAsync = ref.watch(enrolledCoursesProvider);

    ref.listen(enrolledCoursesProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  sanitizeErrorMessage(e),
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(coursesProvider);
                  ref.invalidate(enrolledCoursesProvider);
                  await Future.wait([
                    ref.read(coursesProvider.future),
                    ref.read(enrolledCoursesProvider.future),
                  ]);
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: S.isTablet(context) ? 600 : double.infinity,
                    ),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        coursesAsync.when(
                          loading: () => _buildSkeletonSliver(context, t),
                          error: (e, _) => SliverFillRemaining(
                            child: ErrorBody(
                              t: t,
                              icon: iconForError(e),
                              title: AppStrings.errLoadCourses,
                              message: sanitizeErrorMessage(e),
                              onRetry: () => ref.invalidate(coursesProvider),
                            ),
                          ),
                          data: (courses) {
                            return enrolledAsync.when(
                              loading: () => _buildSkeletonSliver(
                                context,
                                t,
                                count: courses.length,
                              ),
                              error: (_, __) =>
                                  _buildLoadedSliver(context, ref, courses, t),
                              data: (enrollmentMap) => _buildLoadedSliver(
                                context,
                                ref,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedSliver(
    BuildContext context,
    WidgetRef ref,
    List<CourseModel> courses,
    BloomTheme t,
  ) {
    if (courses.isEmpty) {
      return SliverFillRemaining(child: EmptyState(t: t));
    }
    return SliverPadding(
      padding: EdgeInsets.only(bottom: S.scale(context, 32)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((_, i) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderBanner(courseCount: courses.length, t: t),
                SizedBox(height: S.scale(context, 24)),
              ],
            );
          }
          final course = courses[i - 1];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: S.scale(context, 20)),
            child: CourseCard(course: course, index: i - 1, t: t)
                .animate()
                .fadeIn(delay: (60 * (i - 1)).ms)
                .slideY(begin: 0.08, end: 0),
          );
        }, childCount: courses.length + 1),
      ),
    );
  }

  Widget _buildSkeletonSliver(
    BuildContext context,
    BloomTheme t, {
    int count = 6,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, _) => Column(
          children: [
            HeaderBannerSkeleton(t: t),
            SizedBox(height: S.scale(context, 24)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                S.scale(context, 20),
                0,
                S.scale(context, 20),
                S.scale(context, 32),
              ),
              child: Column(
                children: List.generate(count, (_) => CourseCardSkeleton(t: t)),
              ),
            ),
          ],
        ),
        childCount: 1,
      ),
    );
  }
}