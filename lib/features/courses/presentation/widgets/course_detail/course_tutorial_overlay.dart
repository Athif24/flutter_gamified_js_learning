import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/themes/bloom_theme.dart';
import '../../../../../shared/widgets/game_3d_button.dart';
import '../../../../../core/utils/responsive_utils.dart';

class TutorialStepData {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final bool circleHighlight;
  final double extendToTop;
  final double extendToBottom;
  final double? spotlightRadius;
  final double? insetLeft;
  final double? insetRight;
  final double? insetBottom;
  final double? circleRadius;
  final Offset? circleOffset;
  const TutorialStepData({
    required this.title,
    required this.description,
    this.targetKey,
    this.circleHighlight = false,
    this.extendToTop = 0,
    this.extendToBottom = 0,
    this.spotlightRadius,
    this.insetLeft,
    this.insetRight,
    this.insetBottom,
    this.circleRadius,
    this.circleOffset,
  });
}

class CourseTutorialOverlay extends StatefulWidget {
  final Widget child;
  final BloomTheme theme;
  final List<TutorialStepData> steps;
  final VoidCallback? onComplete;
  final bool show;
  const CourseTutorialOverlay({
    super.key,
    required this.child,
    required this.theme,
    required this.steps,
    this.onComplete,
    this.show = true,
  });

  @override
  State<CourseTutorialOverlay> createState() => _CourseTutorialOverlayState();
}

class _CourseTutorialOverlayState extends State<CourseTutorialOverlay> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  TutorialStepData get _current => widget.steps[_step];
  bool get _isLast => _step == widget.steps.length - 1;
  bool get _noTarget => _current.targetKey == null;

  void _next() {
    if (_isLast) return;
    setState(() => _step++);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = widget.steps[_step].targetKey?.currentContext;
      if (ctx == null || ctx.findRenderObject() is! RenderBox) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          WidgetsBinding.instance.addPostFrameCallback((__) {
            if (mounted) setState(() {});
          });
        });
      });
    });
  }

  Future<void> _finish() async {
    widget.onComplete?.call();
    setState(() => _step = widget.steps.length);
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return widget.child;
    if (!widget.show || _step >= widget.steps.length) return widget.child;

    final t = widget.theme;
    final size = MediaQuery.of(context).size;
    Rect? targetRect;

    if (!_noTarget) {
      final ctx = _current.targetKey!.currentContext;
      if (ctx != null) {
        try {
          final renderObj = ctx.findRenderObject();
          if (renderObj is RenderBox &&
              renderObj.hasSize &&
              renderObj.attached) {
            final pos = renderObj.localToGlobal(Offset.zero);
            final s = renderObj.size;
            final padding = S.scale(context, 12);

            if (_current.circleHighlight) {
              final center = Offset(
                pos.dx + s.width / 2 + (_current.circleOffset?.dx ?? 0),
                pos.dy + s.height / 2 + (_current.circleOffset?.dy ?? 0),
              );
              final radius = _current.circleRadius != null
                  ? S.scale(context, _current.circleRadius!)
                  : s.shortestSide / 2 + padding;
              targetRect = Rect.fromCircle(center: center, radius: radius);
            } else {
              final il = _current.insetLeft ?? 0;
              final ir = _current.insetRight ?? 0;
              final ib = _current.insetBottom ?? 0;
              targetRect = Rect.fromLTWH(
                pos.dx + il,
                pos.dy - padding,
                s.width - il - ir,
                s.height + padding - ib,
              );
            }
          }
        } catch (_) {}
      }
    }

    if (targetRect != null) {
      if (_current.extendToBottom == -1) {
        targetRect = Rect.fromLTWH(
          targetRect.left,
          targetRect.top,
          targetRect.width,
          size.height - targetRect.top,
        );
      } else if (_current.extendToBottom > 0) {
        targetRect = Rect.fromLTWH(
          targetRect.left,
          targetRect.top,
          targetRect.width,
          targetRect.height + S.scale(context, _current.extendToBottom),
        );
      }
      if (_current.extendToTop > 0) {
        targetRect = Rect.fromLTWH(
          targetRect.left,
          targetRect.top - _current.extendToTop,
          targetRect.width,
          targetRect.height + _current.extendToTop,
        );
      }
    }

    final hasTarget = targetRect != null;
    final tooltipAbove = hasTarget && targetRect.center.dy > size.height * 0.55;
    final useAbove = tooltipAbove && targetRect.top > S.scale(context, 250);

    Widget overlay;
    if (hasTarget) {
      overlay = ClipPath(
        clipper: _CourseSpotlightClipper(
          targetRect: targetRect,
          circle: _current.circleHighlight,
          radius: S.scale(context, _current.spotlightRadius ?? 12),
        ),
        child: Container(color: t.textPrimary.withValues(alpha: 0.6)),
      );
    } else {
      overlay = Container(color: t.textPrimary.withValues(alpha: 0.6));
    }

    Widget tooltip;
    if (hasTarget && useAbove) {
      tooltip = Positioned(
        left: S.scale(context, 16),
        right: S.scale(context, 16),
        bottom: size.height - targetRect.top + S.scale(context, 12),
        child: _CourseTooltipCard(
          t: t,
          step: _step,
          total: widget.steps.length,
          title: _current.title,
          description: _current.description,
          isLast: _isLast,
          onNext: _next,
          onFinish: _finish,
        ),
      );
    } else if (hasTarget) {
      if (_current.extendToBottom == -1 && !useAbove) {
        tooltip = Positioned(
          left: S.scale(context, 16),
          right: S.scale(context, 16),
          bottom: S.scale(context, 24),
          child: _CourseTooltipCard(
            t: t,
            step: _step,
            total: widget.steps.length,
            title: _current.title,
            description: _current.description,
            isLast: _isLast,
            onNext: _next,
            onFinish: _finish,
          ),
        );
      } else {
        tooltip = Positioned(
          left: S.scale(context, 16),
          right: S.scale(context, 16),
          top: targetRect.bottom + S.scale(context, 12),
          child: _CourseTooltipCard(
            t: t,
            step: _step,
            total: widget.steps.length,
            title: _current.title,
            description: _current.description,
            isLast: _isLast,
            onNext: _next,
            onFinish: _finish,
          ),
        );
      }
    } else {
      tooltip = Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)),
          child: _CourseTooltipCard(
            t: t,
            step: _step,
            total: widget.steps.length,
            title: _current.title,
            description: _current.description,
            isLast: _isLast,
            onNext: _next,
            onFinish: _finish,
          ),
        ),
      );
    }

    return Stack(children: [
      widget.child,
      if (_step == 0 || _step == 1 || _step == 3)
        IgnorePointer(child: overlay)
      else
        overlay,
      tooltip,
    ]);
  }
}

class _CourseSpotlightClipper extends CustomClipper<Path> {
  final Rect targetRect;
  final bool circle;
  final double radius;
  const _CourseSpotlightClipper({
    required this.targetRect,
    this.circle = false,
    this.radius = 12,
  });

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path();
    if (circle) {
      hole.addOval(Rect.fromCircle(
        center: targetRect.center,
        radius: targetRect.shortestSide / 2,
      ));
    } else {
      hole.addRRect(RRect.fromRectAndRadius(
        targetRect,
        Radius.circular(radius),
      ));
    }
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _CourseSpotlightClipper old) =>
      old.targetRect != targetRect || old.circle != circle || old.radius != radius;
}

class _CourseTooltipCard extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final String description;
  final bool isLast;
  final int step;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _CourseTooltipCard({
    required this.t,
    required this.title,
    required this.description,
    required this.isLast,
    required this.step,
    required this.total,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 20)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 8), vertical: S.scale(context, 3)),
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(S.scale(context, 6)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${step + 1}/$total',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: S.font(context, 11),
                      color: t.primaryContent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: S.scale(context, 10)),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: S.font(context, 16),
                    color: t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 10)),
          Text(
            description,
            style: GoogleFonts.nunito(
              fontSize: S.font(context, 13),
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: S.scale(context, 16)),
          SizedBox(
            width: double.infinity,
            child: Game3DButton(
              label: isLast ? 'Selesai' : 'Berikutnya',
              color: t.primary,
              shadowColor: t.textPrimary,
              textColor: t.primaryContent,
              horizontalPadding: S.scale(context, 16),
              onTap: isLast ? onFinish : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> isCourseTutorialSeen(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('course_tutorial_seen_$userId') ?? false;
}

Future<void> markCourseTutorialSeen(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('course_tutorial_seen_$userId', true);
}
