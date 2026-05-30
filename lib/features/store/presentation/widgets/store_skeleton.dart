import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/responsive_utils.dart';

class StoreSkeleton extends StatefulWidget {
  final BloomTheme t;
  final int tabId;
  const StoreSkeleton({super.key, required this.t, this.tabId = 0});

  @override
  State<StoreSkeleton> createState() => _StoreSkeletonState();
}

class _StoreSkeletonState extends State<StoreSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmer(Widget child) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => _ShimmerOverlay(
        progress: _animation.value,
        baseColor: widget.t.bgSurface2,
        child: child,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(S.scale(context, 20)),
      children: [
        if (widget.tabId == 0) ..._shopSkeleton(context),
        if (widget.tabId == 1) ..._inventorySkeleton(context),
        if (widget.tabId == 2) ..._historySkeleton(context),
      ],
    );
  }

  List<Widget> _shopSkeleton(BuildContext c) {
    return [
      _shimmer(
        Row(
          children: [
            Container(
              width: S.scale(c, 20),
              height: S.scale(c, 20),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(S.scale(c, 4)),
              ),
            ),
            SizedBox(width: S.scale(c, 8)),
            Container(
              width: S.scale(c, 100),
              height: S.scale(c, 16),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(S.scale(c, 4)),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: S.scale(c, 12)),
      LayoutBuilder(
        builder: (_, constraints) {
          final cardWidth = constraints.maxWidth > 600
              ? S.scale(c, 280)
              : S.scale(c, 240);
          return SizedBox(
            height: S.scale(c, 300),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(width: S.scale(c, 14)),
              itemBuilder: (_, __) => _shimmer(
                Container(
                  width: cardWidth,
                  height: S.scale(c, 300),
                  decoration: BoxDecoration(
                    color: widget.t.bgSurface,
                    borderRadius: BorderRadius.circular(S.scale(c, 18)),
                    border: Border.all(
                      color: widget.t.textPrimary,
                      width: S.scale(c, 2),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      SizedBox(height: S.scale(c, 24)),
      _shimmer(
        Container(
          width: S.scale(c, 60),
          height: S.scale(c, 16),
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(S.scale(c, 4)),
          ),
        ),
      ),
      SizedBox(height: S.scale(c, 12)),
      LayoutBuilder(
        builder: (_, constraints) {
          final crossAxisCount = constraints.maxWidth > 600
              ? (constraints.maxWidth > 900 ? 4 : 3)
              : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: S.scale(c, 14),
              crossAxisSpacing: S.scale(c, 14),
              childAspectRatio: 0.78,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmer(
              Container(
                decoration: BoxDecoration(
                  color: widget.t.bgSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.t.textPrimary, width: 2),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _inventorySkeleton(BuildContext c) {
    return [
      _shimmer(
        Container(
          width: S.scale(c, 100),
          height: S.scale(c, 16),
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(S.scale(c, 4)),
          ),
        ),
      ),
      SizedBox(height: S.scale(c, 12)),
      ...List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: S.scale(c, 14)),
          child: _shimmer(
            Container(
              height: S.scale(c, 120),
              decoration: BoxDecoration(
                color: widget.t.bgSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: widget.t.textPrimary, width: 2),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _historySkeleton(BuildContext c) {
    return [
      _shimmer(
        Row(
          children: [
            Container(
              width: S.scale(c, 16),
              height: S.scale(c, 16),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(S.scale(c, 4)),
              ),
            ),
            SizedBox(width: S.scale(c, 6)),
            Container(
              width: S.scale(c, 50),
              height: S.scale(c, 14),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(S.scale(c, 4)),
              ),
            ),
            SizedBox(width: S.scale(c, 8)),
            Container(
              width: S.scale(c, 120),
              height: S.scale(c, 36),
              decoration: BoxDecoration(
                color: widget.t.bgSurface,
                borderRadius: BorderRadius.circular(S.scale(c, 12)),
                border: Border.all(
                  color: widget.t.textPrimary,
                  width: S.scale(c, 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: S.scale(c, 16)),
      _shimmer(
        Container(
          decoration: BoxDecoration(
            color: widget.t.bgSurface,
            borderRadius: BorderRadius.circular(S.scale(c, 16)),
            border: Border.all(
              color: widget.t.textPrimary,
              width: S.scale(c, 2),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: S.scale(c, 40),
                color: widget.t.bgSurface2,
                padding: EdgeInsets.symmetric(horizontal: S.scale(c, 16)),
                child: Row(
                  children: [
                    Expanded(
                      child: _skeletonBox(c: c, width: S.scale(c, 60)),
                    ),
                    Expanded(
                      child: _skeletonBox(c: c, width: S.scale(c, 70)),
                    ),
                    Expanded(
                      child: _skeletonBox(c: c, width: S.scale(c, 50)),
                    ),
                    Expanded(
                      child: _skeletonBox(c: c, width: S.scale(c, 70)),
                    ),
                  ],
                ),
              ),
              ...List.generate(
                5,
                (i) => Container(
                  height: S.scale(c, 48),
                  padding: EdgeInsets.symmetric(horizontal: S.scale(c, 16)),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: widget.t.textPrimary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _skeletonBox(c: c, width: S.scale(c, 80)),
                      ),
                      Expanded(
                        child: _skeletonBox(c: c, width: S.scale(c, 60)),
                      ),
                      Expanded(
                        child: _skeletonBox(c: c, width: S.scale(c, 50)),
                      ),
                      Expanded(
                        child: _skeletonBox(c: c, width: S.scale(c, 60)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _skeletonBox({required BuildContext c, double width = 50}) {
    return Container(
      height: S.scale(c, 12),
      width: width,
      decoration: BoxDecoration(
        color: widget.t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(c, 4)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHIMMER OVERLAY
// ════════════════════════════════════════════════════════════════════════════

class _ShimmerOverlay extends StatelessWidget {
  final double progress;
  final Color baseColor;
  final Widget child;
  const _ShimmerOverlay({
    required this.progress,
    required this.baseColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: 0.6,
            child: CustomPaint(
              painter: _ShimmerPainter(
                progress: progress,
                baseColor: baseColor,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  _ShimmerPainter({required this.progress, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerColor = Color.lerp(baseColor, Colors.white, 0.3)!;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        shimmerColor.withValues(alpha: 0),
        shimmerColor.withValues(alpha: 0.5),
        shimmerColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(progress * size.width, 0, size.width, size.height),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}