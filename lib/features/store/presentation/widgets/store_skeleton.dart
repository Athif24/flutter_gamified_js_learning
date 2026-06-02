import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class StoreSkeleton extends StatelessWidget {
  final BloomTheme t;
  final int tabId;
  const StoreSkeleton({super.key, required this.t, this.tabId = 0});

  static const double _cardAspectRatio = 0.78;

  @override
  Widget build(BuildContext context) {
    final shimmerColor = t.bgSurface3;
    final items = switch (tabId) {
      0 => _shopSkeleton(context, shimmerColor),
      1 => _inventorySkeleton(context, shimmerColor),
      2 => _historySkeleton(context, shimmerColor),
      _ => <Widget>[],
    };
    return Padding(
      padding: EdgeInsets.all(S.scale(context, 20)),
      child: SingleChildScrollView(child: Column(children: items)),
    );
  }

  List<Widget> _shopSkeleton(BuildContext c, Color shimmerColor) {
    return [
      Row(
            children: [
              _box(c: c, size: 20, color: shimmerColor),
              SizedBox(width: S.scale(c, 8)),
              _box(c: c, width: 100, height: 16, color: shimmerColor),
            ],
          )
          .animate(onPlay: (p) => p.repeat())
          .shimmer(duration: 1200.ms, color: shimmerColor),
      SizedBox(height: S.scale(c, 12)),
      SizedBox(
        height: S.scale(c, 300),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: S.scale(c, 14)),
          itemBuilder: (_, __) =>
              Container(
                    width: S.scale(c, 240),
                    height: S.scale(c, 300),
                    decoration: BoxDecoration(
                      color: t.bgSurface,
                      borderRadius: BorderRadius.circular(S.scale(c, 18)),
                      border: Border.all(
                        color: t.textPrimary,
                        width: S.scale(c, 2),
                      ),
                    ),
                  )
                  .animate(onPlay: (p) => p.repeat())
                  .shimmer(duration: 1200.ms, color: shimmerColor),
        ),
      ),
      SizedBox(height: S.scale(c, 24)),
      _box(c: c, width: 60, height: 16, color: shimmerColor)
          .animate(onPlay: (p) => p.repeat())
          .shimmer(duration: 1200.ms, color: shimmerColor),
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
              childAspectRatio: _cardAspectRatio,
            ),
            itemCount: 4,
            itemBuilder: (ctx, __) =>
                Container(
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(S.scale(ctx, 18)),
                        border: Border.all(
                          color: t.textPrimary,
                          width: S.scale(ctx, 2),
                        ),
                      ),
                    )
                    .animate(onPlay: (p) => p.repeat())
                    .shimmer(duration: 1200.ms, color: shimmerColor),
          );
        },
      ),
    ];
  }

  List<Widget> _inventorySkeleton(BuildContext c, Color shimmerColor) {
    return [
      _box(c: c, width: 100, height: 16, color: shimmerColor)
          .animate(onPlay: (p) => p.repeat())
          .shimmer(duration: 1200.ms, color: shimmerColor),
      SizedBox(height: S.scale(c, 12)),
      ...List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: S.scale(c, 14)),
          child:
              Container(
                    height: S.scale(c, 120),
                    decoration: BoxDecoration(
                      color: t.bgSurface,
                      borderRadius: BorderRadius.circular(S.scale(c, 18)),
                      border: Border.all(
                        color: t.textPrimary,
                        width: S.scale(c, 2),
                      ),
                    ),
                  )
                  .animate(onPlay: (p) => p.repeat())
                  .shimmer(duration: 1200.ms, color: shimmerColor),
        ),
      ),
    ];
  }

  List<Widget> _historySkeleton(BuildContext c, Color shimmerColor) {
    return [
      Row(
            children: [
              _box(c: c, size: 16, color: shimmerColor),
              SizedBox(width: S.scale(c, 6)),
              _box(c: c, width: 50, height: 14, color: shimmerColor),
              SizedBox(width: S.scale(c, 8)),
              _box(c: c, width: 120, height: 36, color: shimmerColor),
            ],
          )
          .animate(onPlay: (p) => p.repeat())
          .shimmer(duration: 1200.ms, color: shimmerColor),
      SizedBox(height: S.scale(c, 16)),
      Container(
            decoration: BoxDecoration(
              color: t.bgSurface,
              borderRadius: BorderRadius.circular(S.scale(c, 16)),
              border: Border.all(color: t.textPrimary, width: S.scale(c, 2)),
            ),
            child: Column(
              children: [
                Container(
                  height: S.scale(c, 40),
                  color: t.bgSurface2,
                  padding: EdgeInsets.symmetric(horizontal: S.scale(c, 16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: _box(c: c, width: 60, color: shimmerColor),
                      ),
                      Expanded(
                        child: _box(c: c, width: 70, color: shimmerColor),
                      ),
                      Expanded(
                        child: _box(c: c, width: 50, color: shimmerColor),
                      ),
                      Expanded(
                        child: _box(c: c, width: 70, color: shimmerColor),
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
                          color: t.textPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _box(c: c, width: 80, color: shimmerColor),
                        ),
                        Expanded(
                          child: _box(c: c, width: 60, color: shimmerColor),
                        ),
                        Expanded(
                          child: _box(c: c, width: 50, color: shimmerColor),
                        ),
                        Expanded(
                          child: _box(c: c, width: 60, color: shimmerColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate(onPlay: (p) => p.repeat())
          .shimmer(duration: 1200.ms, color: shimmerColor),
    ];
  }

  Widget _box({
    required BuildContext c,
    double? width,
    double? height,
    double? size,
    required Color color,
  }) {
    final w = size ?? width ?? 50;
    final h = size ?? height ?? 12;
    return Container(
      height: S.scale(c, h),
      width: S.scale(c, w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(S.scale(c, 4)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// STORE HEADER SKELETON
// ════════════════════════════════════════════════════════════════════════════

class StoreHeaderSkeleton extends StatelessWidget {
  final BloomTheme t;
  const StoreHeaderSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = t.bgSurface3;
    return Container(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        S.scale(context, 16),
        S.scale(context, 20),
        0,
      ),
      color: t.bgPrimary,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(S.scale(context, 24)),
            decoration: BoxDecoration(
              color: t.bgSurface,
              borderRadius: BorderRadius.circular(S.scale(context, 24)),
              border: Border.all(
                color: t.textPrimary,
                width: S.scale(context, 2),
              ),
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
                Row(
                      children: [
                        _headerBox(c: context, s: 24, color: shimmerColor),
                        SizedBox(width: S.scale(context, 10)),
                        _headerBox(
                          c: context,
                          w: 80,
                          h: 24,
                          color: shimmerColor,
                        ),
                      ],
                    )
                    .animate(onPlay: (p) => p.repeat())
                    .shimmer(duration: 1200.ms, color: shimmerColor),
                SizedBox(height: S.scale(context, 8)),
                _headerBox(c: context, w: 200, h: 14, color: shimmerColor)
                    .animate(onPlay: (p) => p.repeat())
                    .shimmer(duration: 1200.ms, color: shimmerColor),
                SizedBox(height: S.scale(context, 14)),
                Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: S.scale(context, 20),
                        vertical: S.scale(context, 12),
                      ),
                      decoration: BoxDecoration(
                        color: t.bgSurface2.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          S.scale(context, 16),
                        ),
                        border: Border.all(
                          color: t.textPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _headerBox(c: context, s: 24, color: shimmerColor),
                          SizedBox(width: S.scale(context, 8)),
                          _headerBox(
                            c: context,
                            w: 80,
                            h: 24,
                            color: shimmerColor,
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (p) => p.repeat())
                    .shimmer(duration: 1200.ms, color: shimmerColor),
              ],
            ),
          ),
          SizedBox(height: S.scale(context, 14)),
          SizedBox(
                height: S.scale(context, 40),
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) SizedBox(width: S.scale(context, 8)),
                      Container(
                        width: S.scale(context, 100),
                        height: S.scale(context, 40),
                        decoration: BoxDecoration(
                          color: t.bgSurface2,
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate(onPlay: (p) => p.repeat())
              .shimmer(duration: 1200.ms, color: shimmerColor),
          SizedBox(height: S.scale(context, 10)),
          Container(
            height: S.scale(context, 2),
            decoration: BoxDecoration(color: t.bgSurface2),
          ),
          SizedBox(height: S.scale(context, 14)),
        ],
      ),
    );
  }

  Widget _headerBox({
    required BuildContext c,
    double? w,
    double? h,
    double? s,
    required Color color,
  }) {
    final width = s ?? w ?? 50;
    final height = s ?? h ?? 12;
    return Container(
      width: S.scale(c, width),
      height: S.scale(c, height),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(S.scale(c, 6)),
      ),
    );
  }
}