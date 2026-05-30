import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/course_list/header_banner.dart';
import '../widgets/course_list/empty_state.dart';
import '../widgets/course_list/course_card.dart';
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
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/course_model.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen>
    with SilentRefreshMixin<CourseListScreen> {
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
            SlowLoadingIndicator(visible: showSlowIndicator, t: t),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _silentRefresh,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: S.isTablet(context) ? 600 : double.infinity,
                    ),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // ── Header banner ─────────────────────────────────────────────
                        SliverToBoxAdapter(
                          child: HeaderBanner(
                            courseCount: coursesAsync.maybeWhen(
                              data: (courses) => courses.length,
                              orElse: () => 0,
                            ),
                            t: t,
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: SizedBox(height: S.scale(context, 24)),
                        ),

                        // ── Courses list ───────────────────────────────────────────────
                        coursesAsync.when(
                          loading: () =>
                              SliverFillRemaining(child: LoadingCircle(t: t)),
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
                              error: (_, __) =>
                                  _buildCourseList(context, ref, courses, t),
                              data: (enrollmentMap) => _buildCourseList(
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

  Widget _buildCourseList(
    BuildContext context,
    WidgetRef ref,
    List<CourseModel> courses,
    BloomTheme t,
  ) {
    if (courses.isEmpty) {
      return SliverFillRemaining(child: EmptyState(t: t));
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        0,
        S.scale(context, 20),
        S.scale(context, 32),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((_, i) {
          final course = courses[i];
          return CourseCard(
            course: course,
            index: i,
            t: t,
          ).animate().fadeIn(delay: (60 * i).ms).slideY(begin: 0.08, end: 0);
        }, childCount: courses.length),
      ),
    );
  }
}
