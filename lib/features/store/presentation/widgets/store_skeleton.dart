import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';

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
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.tabId == 0) ..._shopSkeleton(),
        if (widget.tabId == 1) ..._inventorySkeleton(),
        if (widget.tabId == 2) ..._historySkeleton(),
      ],
    );
  }

  List<Widget> _shopSkeleton() {
    return [
      _shimmer(
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (_, c) {
          final cardWidth = c.maxWidth > 600 ? 280.0 : 240.0;
          return SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => _shimmer(
                Container(
                  width: cardWidth,
                  height: 300,
                  decoration: BoxDecoration(
                    color: widget.t.bgSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: widget.t.textPrimary, width: 2),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      _shimmer(
        Container(
          width: 60,
          height: 16,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      const SizedBox(height: 12),
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
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
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

  List<Widget> _inventorySkeleton() {
    return [
      _shimmer(
        Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      const SizedBox(height: 12),
      ...List.generate(
        4,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _shimmer(
            Container(
              height: 120,
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

  List<Widget> _historySkeleton() {
    return [
      _shimmer(
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 50,
              height: 14,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                color: widget.t.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.t.textPrimary, width: 1.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _shimmer(
        Container(
          decoration: BoxDecoration(
            color: widget.t.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.t.textPrimary, width: 2),
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                color: widget.t.bgSurface2,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _skeletonBox(width: 60)),
                    Expanded(child: _skeletonBox(width: 70)),
                    Expanded(child: _skeletonBox(width: 50)),
                    Expanded(child: _skeletonBox(width: 70)),
                  ],
                ),
              ),
              ...List.generate(
                5,
                (i) => Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: widget.t.textPrimary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _skeletonBox(width: 80)),
                      Expanded(child: _skeletonBox(width: 60)),
                      Expanded(child: _skeletonBox(width: 50)),
                      Expanded(child: _skeletonBox(width: 60)),
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

  Widget _skeletonBox({double width = 50}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: widget.t.bgSurface2,
        borderRadius: BorderRadius.circular(4),
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
