import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/services/sound_service.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../data/models/course_model.dart';

class HeaderCard extends StatefulWidget {
  final CourseModel course;
  final double progress;
  final int progressPct;
  final int completedUnits;
  final BloomTheme t;
  const HeaderCard({
    super.key,
    required this.course,
    required this.progress,
    required this.progressPct,
    required this.completedUnits,
    required this.t,
  });

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cBg = widget.t.primary;
    final cFg = widget.t.primaryContent;

    return Container(
      margin: EdgeInsets.fromLTRB(
        S.scale(context, 16),
        S.scale(context, 12),
        S.scale(context, 16),
        0,
      ),
      decoration: BoxDecoration(
        color: cBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.t.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.t.textPrimary,
            offset: const Offset(3, 3),
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
                    tag: 'course-title-${widget.course.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.course.title,
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ProviderScope.containerOf(
                      context,
                    ).read(soundProvider).playClick();
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: cFg.withValues(alpha: 0.15),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: cFg,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.course.description != null &&
                      widget.course.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.course.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: cFg.withValues(alpha: 0.8),
                        fontSize: S.font(context, 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.t.textPrimary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book,
                                    color: cFg,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.course.totalLessons}',
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: widget.t.textPrimary.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: cFg,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.completedUnits}/${widget.course.units.length}',
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: widget.t.textPrimary.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: cFg.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cFg.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.percent_rounded,
                                    color: cFg,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.progressPct}%',
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.progress.clamp(0.0, 1.0),
                      backgroundColor: cFg.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(cFg),
                      minHeight: 12,
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