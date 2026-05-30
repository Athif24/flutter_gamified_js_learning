import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/bloom_theme.dart';
import '../../../../shared/widgets/game_3d_button.dart';
import '../../../../core/utils/responsive_utils.dart';

class TutorialStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  const TutorialStep({
    required this.title,
    required this.description,
    this.targetKey,
  });
}

class PostRegisterTutorial extends StatefulWidget {
  final List<TutorialStep> steps;
  final BloomTheme theme;
  final Widget child;
  final VoidCallback? onComplete;
  const PostRegisterTutorial({
    super.key,
    required this.steps,
    required this.theme,
    required this.child,
    this.onComplete,
  });

  @override
  State<PostRegisterTutorial> createState() => _PostRegisterTutorialState();
}

class _PostRegisterTutorialState extends State<PostRegisterTutorial> {
  int _step = 0;

  TutorialStep get _current => widget.steps[_step];
  bool get _isLast => _step == widget.steps.length - 1;
  bool get _noTarget => _current.targetKey == null;

  void _next() {
    if (_isLast) return;
    setState(() => _step++);
  }

  void _finish() {
    widget.onComplete?.call();
    setState(() => _step = widget.steps.length);
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return widget.child;
    if (_step >= widget.steps.length) return widget.child;

    final t = widget.theme;
    final size = MediaQuery.of(context).size;
    Offset? center;
    double radius = 0;

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
            center = Offset(pos.dx + s.width / 2, pos.dy + s.height / 2);
            radius = (s.width > s.height ? s.width : s.height) / 2 + 28;
          }
        } catch (e) {
          if (!kReleaseMode) debugPrint('[PostRegisterTutorial] findRenderObject error: $e');
        }
      }
    }

    final hasTarget = center != null;
    final tooltipAbove = hasTarget && center.dy > size.height * 0.55;

    Widget overlay;
    if (hasTarget) {
      overlay = ClipPath(
        clipper: _SpotlightClipper(center: center, radius: radius),
        child: Container(color: t.textPrimary.withValues(alpha: 0.6)),
      );
    } else {
      overlay = Container(color: t.textPrimary.withValues(alpha: 0.6));
    }

    Widget tooltip;
    if (hasTarget && tooltipAbove) {
      tooltip = Positioned(
        left: S.scale(context, 16),
        right: S.scale(context, 16),
        bottom: size.height - center.dy + radius + S.scale(context, 12),
        child: _TooltipCard(
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
      tooltip = Positioned(
        left: S.scale(context, 16),
        right: S.scale(context, 16),
        top: center.dy + radius + S.scale(context, 12),
        child: _TooltipCard(
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
      tooltip = Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: S.scale(context, 24)),
          child: _TooltipCard(
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

    return Stack(children: [widget.child, overlay, tooltip]);
  }
}

class _SpotlightClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;
  const _SpotlightClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _SpotlightClipper old) =>
      old.center != center || old.radius != radius;
}

class _TooltipCard extends StatelessWidget {
  final BloomTheme t;
  final String title;
  final String description;
  final bool isLast;
  final int step;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _TooltipCard({
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
