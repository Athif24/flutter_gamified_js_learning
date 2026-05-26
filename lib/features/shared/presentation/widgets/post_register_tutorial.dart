import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/bloom_theme.dart';
import '../../../../shared/widgets/game_3d_button.dart';

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
        } catch (_) {
          // RenderObject sudah tidak tersedia, lewati spotlight
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
        left: 16,
        right: 16,
        bottom: size.height - center.dy + radius + 12,
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
        left: 16,
        right: 16,
        top: center.dy + radius + 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${step + 1}/$total',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: t.primaryContent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: t.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Game3DButton(
              label: isLast ? 'Selesai' : 'Berikutnya',
              color: t.primary,
              shadowColor: t.textPrimary,
              textColor: t.primaryContent,
              horizontalPadding: 16,
              onTap: isLast ? onFinish : onNext,
            ),
          ),
        ],
      ),
    );
  }
}