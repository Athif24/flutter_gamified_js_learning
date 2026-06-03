import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/themes/theme_provider.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/utils/error_helper.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';

class CourseCard extends ConsumerStatefulWidget {
  final CourseModel course;
  final int index;
  final BloomTheme t;
  const CourseCard({
    super.key,
    required this.course,
    required this.index,
    required this.t,
  });

  @override
  ConsumerState<CourseCard> createState() => CourseCardState();
}

class CourseCardState extends ConsumerState<CourseCard> {
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
            content: Text(
              'Gagal enroll: ${sanitizeErrorMessage(e)}',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: widget.t.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.scale(context, 12)),
            ),
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
      margin: EdgeInsets.only(bottom: S.scale(context, 16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 24)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'course-thumb-${course.id}',
            child: Container(
              height: S.scale(context, 144),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(S.scale(context, 23)),
                ),
                image: course.thumbnail != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(course.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (course.thumbnail == null)
                    Center(
                      child: Icon(
                        Icons.menu_book,
                        size: S.scale(context, 56),
                        color: headerFg.withValues(alpha: 0.8),
                      ),
                    ),
                  if (isCompleted)
                    Positioned(
                      right: S.scale(context, 12),
                      top: S.scale(context, 12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: S.scale(context, 8),
                          vertical: S.scale(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 50),
                          ),
                          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: S.scale(context, 12),
                              color: t.primary,
                            ),
                            SizedBox(width: S.scale(context, 4)),
                            Text(
                              'Selesai',
                              style: GoogleFonts.nunito(
                                color: t.primary,
                                fontSize: S.font(context, 10),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isEnrolled && !isCompleted)
                    Positioned(
                      right: S.scale(context, 12),
                      top: S.scale(context, 12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: S.scale(context, 8),
                          vertical: S.scale(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 50),
                          ),
                          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                        ),
                        child: Text(
                          'Enrolled',
                          style: GoogleFonts.nunito(
                            color: t.textPrimary,
                            fontSize: S.font(context, 10),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              S.scale(context, 16),
              S.scale(context, 12),
              S.scale(context, 16),
              S.scale(context, 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'course-title-${course.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      course.title,
                      style: GoogleFonts.nunito(
                        color: t.textPrimary,
                        fontSize: S.font(context, 16),
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (course.description != null &&
                    course.description!.isNotEmpty) ...[
                  SizedBox(height: S.scale(context, 4)),
                  Text(
                    course.description!,
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: S.font(context, 12),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: S.scale(context, 4)),
                Text(
                  '${course.totalLessons} lesson',
                  style: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: S.font(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEnrolled) ...[
                  SizedBox(height: S.scale(context, 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.nunito(
                          color: t.mutedText,
                          fontSize: S.font(context, 11),
                        ),
                      ),
                      Text(
                        '$progressPct%',
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontSize: S.font(context, 11),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: S.scale(context, 4)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: t.bgSurface2,
                      valueColor: AlwaysStoppedAnimation(t.primary),
                      minHeight: S.scale(context, 10),
                    ),
                  ),
                ],
                SizedBox(height: S.scale(context, 12)),
                if (isEnrolled)
                  Semantics(
                    label: isCompleted
                        ? 'Ulangi kursus ${course.title}'
                        : 'Lanjutkan kursus ${course.title}',
                    child: Bounceable(
                      onTap: () {
                      context.push('/course/${course.id}');
                      },
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: S.scale(context, 48),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: S.scale(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: t.bgSurface,
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 16),
                          ),
                          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: Offset(
                                S.scale(context, 3),
                                S.scale(context, 3),
                              ),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                Icon(
                                  Icons.check,
                                  size: S.scale(context, 16),
                                  color: t.success,
                                ),
                              Text(
                                isCompleted ? ' Ulangi' : 'Lanjutkan',
                                style: GoogleFonts.nunito(
                                  color: t.textPrimary,
                                  fontSize: S.font(context, 13),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (!isCompleted) ...[
                                SizedBox(width: S.scale(context, 4)),
                                Icon(
                                  Icons.arrow_forward,
                                  size: S.scale(context, 16),
                                  color: t.textPrimary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isEnrolled)
                  Semantics(
                    label: _isEnrolling
                        ? 'Memproses pendaftaran'
                        : 'Mulai kursus ${course.title}',
                    child: Bounceable(
                      onTap: _isEnrolling
                          ? null
                          : () {
                               _enroll();
                            },
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: S.scale(context, 48),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: S.scale(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 16),
                          ),
                          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                          boxShadow: [
                            BoxShadow(
                              color: t.textPrimary,
                              offset: Offset(
                                S.scale(context, 3),
                                S.scale(context, 3),
                              ),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isEnrolling
                              ? SizedBox(
                                  width: S.scale(context, 18),
                                  height: S.scale(context, 18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: S.scale(context, 2),
                                    color: t.primaryContent,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Mulai',
                                      style: GoogleFonts.nunito(
                                        color: t.primaryContent,
                                        fontSize: S.font(context, 13),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: S.scale(context, 4)),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: S.scale(context, 16),
                                      color: t.primaryContent,
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
        ],
      ),
    );
    return card;
  }
}
