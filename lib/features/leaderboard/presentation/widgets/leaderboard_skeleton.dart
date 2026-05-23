import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';

class LeaderboardSkeleton extends StatefulWidget {
  final BloomTheme t;
  const LeaderboardSkeleton({super.key, required this.t});

  @override
  State<LeaderboardSkeleton> createState() => _LeaderboardSkeletonState();
}

class _LeaderboardSkeletonState extends State<LeaderboardSkeleton>
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

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildHeaderSkeleton(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildUserCardSkeleton(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildPodiumSkeleton(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildSearchSkeleton(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildTableSkeleton(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildFooterSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 180,
              height: 28,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 280,
          height: 14,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 18,
            decoration: BoxDecoration(
              color: widget.t.bgSurface2,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      color: widget.t.bgSurface2,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 28,
                      color: widget.t.bgSurface2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      color: widget.t.bgSurface2,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 28,
                      color: widget.t.bgSurface2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 160, height: 18, color: widget.t.bgSurface2),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _podiumBlock(height: 48)),
            const SizedBox(width: 8),
            Expanded(child: _podiumBlock(height: 80)),
            const SizedBox(width: 8),
            Expanded(child: _podiumBlock(height: 40)),
          ],
        ),
      ],
    );
  }

  Widget _podiumBlock({required double height}) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 50, height: 10, color: widget.t.bgSurface2),
        const SizedBox(height: 4),
        Container(width: 30, height: 10, color: widget.t.bgSurface2),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 80, height: 12, color: widget.t.bgSurface2),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: widget.t.bgPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.t.bgSurface2,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 120, height: 20, color: widget.t.bgSurface2),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 32, height: 24, color: widget.t.bgSurface2),
                  const SizedBox(width: 12),
                  Container(width: 32, height: 32, color: widget.t.bgSurface2),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 14, color: widget.t.bgSurface2),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 60, height: 14, color: widget.t.bgSurface2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Row(
        children: [
          Expanded(child: _footerItem()),
          Expanded(child: _footerItem()),
          Expanded(child: _footerItem()),
        ],
      ),
    );
  }

  Widget _footerItem() {
    return Column(
      children: [
        Container(width: 60, height: 10, color: widget.t.bgSurface2),
        const SizedBox(height: 8),
        Container(width: 40, height: 20, color: widget.t.bgSurface2),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHIMMER OVERLAY
// ════════════════════════════════════════════════════════════════════════════

class _Shimmer extends StatelessWidget {
  final double progress;
  final BloomTheme t;
  final Widget child;
  const _Shimmer({
    required this.progress,
    required this.t,
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
                baseColor: t.bgSurface2,
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
      stops: [0.0, 0.5, 1.0],
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
