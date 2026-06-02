import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/course_model.dart';

class HeaderCard extends StatelessWidget {
  final CourseModel course;
  final double progress;
  final int progressPct;
  final int completedUnits;
  final BloomTheme t;
  final bool isExpanded;
  final VoidCallback onToggle;
  const HeaderCard({
    super.key,
    required this.course,
    required this.progress,
    required this.progressPct,
    required this.completedUnits,
    required this.t,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cBg = t.primary;
    final cFg = t.primaryContent;

    return Container(
      margin: EdgeInsets.fromLTRB(
        S.scale(context, 16),
        S.scale(context, 12),
        S.scale(context, 16),
        0,
      ),
      decoration: BoxDecoration(
        color: cBg,
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
      child: Padding(
        padding: EdgeInsets.all(S.scale(context, 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'course-title-${course.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          course.title,
                          style: GoogleFonts.nunito(
                            color: cFg,
                            fontSize: S.font(context, 24),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: S.scale(context, 8)),
                GestureDetector(
                  onTap: onToggle,
                  child: CircleAvatar(
                    radius: S.scale(context, 16),
                    backgroundColor: cFg.withValues(alpha: 0.15),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: cFg,
                      size: S.scale(context, 20),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.description != null &&
                      course.description!.isNotEmpty) ...[
                    SizedBox(height: S.scale(context, 4)),
                    Text(
                      course.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: cFg.withValues(alpha: 0.8),
                        fontSize: S.font(context, 13),
                      ),
                    ),
                  ],
                  SizedBox(height: S.scale(context, 16)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: S.scale(context, 12),
                      horizontal: S.isTablet(context)
                          ? S.scale(context, 32)
                          : S.scale(context, 16),
                    ),
                    decoration: BoxDecoration(
                      color: cFg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(S.scale(context, 16)),
                      border: Border.all(
                        color: t.textPrimary.withValues(alpha: 0.5),
                        width: S.scale(context, 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: S.scale(context, 32),
                                height: S.scale(context, 32),
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: S.scale(context, 1.5),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book,
                                    color: cFg,
                                    size: S.scale(context, 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: S.scale(context, 8)),
                              Text(
                                '${course.totalLessons}',
                                style: GoogleFonts.nunito(
                                  color: cFg,
                                  fontSize: S.font(context, 18),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'LESSON',
                                style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8),
                                  fontSize: S.font(context, 10),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: S.scale(context, 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: S.scale(context, 1),
                          height: S.scale(context, 40),
                          color: t.textPrimary.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: S.scale(context, 32),
                                height: S.scale(context, 32),
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: S.scale(context, 1.5),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: cFg,
                                    size: S.scale(context, 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: S.scale(context, 8)),
                              Text(
                                '$completedUnits/${course.units.length}',
                                style: GoogleFonts.nunito(
                                  color: cFg,
                                  fontSize: S.font(context, 18),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'UNIT SELESAI',
                                style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8),
                                  fontSize: S.font(context, 10),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: S.scale(context, 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: S.scale(context, 1),
                          height: S.scale(context, 40),
                          color: t.textPrimary.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: S.scale(context, 32),
                                height: S.scale(context, 32),
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: S.scale(context, 1.5),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.percent_rounded,
                                    color: cFg,
                                    size: S.scale(context, 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: S.scale(context, 8)),
                              Text(
                                '$progressPct%',
                                style: GoogleFonts.nunito(
                                  color: cFg,
                                  fontSize: S.font(context, 18),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'PROGRES',
                                style: GoogleFonts.nunito(
                                  color: cFg.withValues(alpha: 0.8),
                                  fontSize: S.font(context, 10),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: S.scale(context, 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: S.scale(context, 16)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(S.scale(context, 6)),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: cFg.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(cFg),
                      minHeight: S.scale(context, 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}