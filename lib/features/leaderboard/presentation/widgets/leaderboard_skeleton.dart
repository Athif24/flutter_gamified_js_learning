import 'package:flutter/material.dart';
import '../../../../shared/themes/theme_provider.dart';

class LeaderboardSkeleton extends StatefulWidget {
  final BloomTheme t;
  final double screenW;
  const LeaderboardSkeleton({super.key, required this.t, required this.screenW});

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
    final w = widget.screenW;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(20), rs(20), rs(20), rs(32)),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildHeaderSkeleton(rs),
          ),
          SizedBox(height: rs(16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildUserCardSkeleton(rs),
          ),
          SizedBox(height: rs(16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildPodiumSkeleton(rs),
          ),
          SizedBox(height: rs(16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildSearchSkeleton(rs),
          ),
          SizedBox(height: rs(16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildTableSkeleton(rs),
          ),
          SizedBox(height: rs(16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                _Shimmer(progress: _animation.value, t: t, child: child!),
            child: _buildFooterSkeleton(rs),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(double Function(double) rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rs(32),
              height: rs(32),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(8)),
              ),
            ),
            SizedBox(width: rs(8)),
            Container(
              width: rs(180),
              height: rs(28),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(8)),
              ),
            ),
          ],
        ),
        SizedBox(height: rs(8)),
        Container(
          width: rs(280),
          height: rs(14),
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.circular(rs(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCardSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(24)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(rs(24)),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: rs(120),
            height: rs(18),
            decoration: BoxDecoration(
              color: widget.t.bgSurface2,
              borderRadius: BorderRadius.circular(rs(6)),
            ),
          ),
          SizedBox(height: rs(16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: rs(60),
                      height: rs(10),
                      color: widget.t.bgSurface2,
                    ),
                    SizedBox(height: rs(8)),
                    Container(
                      width: rs(80),
                      height: rs(28),
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
                      width: rs(60),
                      height: rs(10),
                      color: widget.t.bgSurface2,
                    ),
                    SizedBox(height: rs(8)),
                    Container(
                      width: rs(100),
                      height: rs(28),
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

  Widget _buildPodiumSkeleton(double Function(double) rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rs(22),
              height: rs(22),
              decoration: BoxDecoration(
                color: widget.t.bgSurface2,
                borderRadius: BorderRadius.circular(rs(4)),
              ),
            ),
            SizedBox(width: rs(8)),
            Container(width: rs(160), height: rs(18), color: widget.t.bgSurface2),
          ],
        ),
        SizedBox(height: rs(16)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _podiumBlock(rs, height: rs(48))),
            SizedBox(width: rs(8)),
            Expanded(child: _podiumBlock(rs, height: rs(80))),
            SizedBox(width: rs(8)),
            Expanded(child: _podiumBlock(rs, height: rs(40))),
          ],
        ),
      ],
    );
  }

  Widget _podiumBlock(double Function(double) rs, {required double height}) {
    return Column(
      children: [
        Container(
          width: rs(44),
          height: rs(44),
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: rs(8)),
        Container(width: rs(50), height: rs(10), color: widget.t.bgSurface2),
        SizedBox(height: rs(4)),
        Container(width: rs(30), height: rs(10), color: widget.t.bgSurface2),
        SizedBox(height: rs(8)),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: widget.t.bgSurface2,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(rs(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(rs(18)),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: rs(80), height: rs(12), color: widget.t.bgSurface2),
          SizedBox(height: rs(8)),
          Container(
            height: rs(40),
            decoration: BoxDecoration(
              color: widget.t.bgPrimary,
              borderRadius: BorderRadius.circular(rs(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(rs(24)),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: rs(28),
                height: rs(28),
                decoration: BoxDecoration(
                  color: widget.t.bgSurface2,
                  borderRadius: BorderRadius.circular(rs(6)),
                ),
              ),
              SizedBox(width: rs(8)),
              Container(width: rs(120), height: rs(20), color: widget.t.bgSurface2),
            ],
          ),
          SizedBox(height: rs(16)),
          ...List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: rs(8)),
              child: Row(
                children: [
                  Container(width: rs(32), height: rs(24), color: widget.t.bgSurface2),
                  SizedBox(width: rs(12)),
                  Container(width: rs(32), height: rs(32), color: widget.t.bgSurface2),
                  SizedBox(width: rs(8)),
                  Expanded(
                    child: Container(height: rs(14), color: widget.t.bgSurface2),
                  ),
                  SizedBox(width: rs(12)),
                  Container(width: rs(60), height: rs(14), color: widget.t.bgSurface2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSkeleton(double Function(double) rs) {
    return Container(
      padding: EdgeInsets.all(rs(16)),
      decoration: BoxDecoration(
        color: widget.t.bgSurface,
        borderRadius: BorderRadius.circular(rs(18)),
        border: Border.all(color: widget.t.textPrimary, width: 2),
      ),
      child: Row(
        children: [
          Expanded(child: _footerItem(rs)),
          Expanded(child: _footerItem(rs)),
          Expanded(child: _footerItem(rs)),
        ],
      ),
    );
  }

  Widget _footerItem(double Function(double) rs) {
    return Column(
      children: [
        Container(width: rs(60), height: rs(10), color: widget.t.bgSurface2),
        SizedBox(height: rs(8)),
        Container(width: rs(40), height: rs(20), color: widget.t.bgSurface2),
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
