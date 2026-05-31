import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

class HeroCardSkeleton extends StatelessWidget {
  final BloomTheme t;
  const HeroCardSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(S.scale(context, 24)),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(S.scale(context, 24)),
      border: Border.all(
        color: t.textPrimary,
        width: S.scale(context, 2),
      ),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: Offset(
            S.scale(context, 3),
            S.scale(context, 3),
          ),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: S.scale(context, 100),
                  height: S.scale(context, 14),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                Container(
                  width: S.scale(context, 80),
                  height: S.scale(context, 24),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 50)),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        SizedBox(height: S.scale(context, 8)),
        Container(
              width: S.scale(context, 160),
              height: S.scale(context, 28),
              decoration: BoxDecoration(
                color: t.bgSurface3,
                borderRadius: BorderRadius.circular(S.scale(context, 4)),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        SizedBox(height: S.scale(context, 16)),
        Container(
              width: double.infinity,
              height: S.scale(context, 24),
              decoration: BoxDecoration(
                color: t.bgSurface3,
                borderRadius: BorderRadius.circular(S.scale(context, 12)),
                border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        SizedBox(height: S.scale(context, 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) =>
                Container(
                      width: S.scale(context, 80),
                      height: S.scale(context, 70),
                      decoration: BoxDecoration(
                        color: t.bgSurface3,
                        borderRadius: BorderRadius.circular(S.scale(context, 16)),
                        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      ],
    ),
  );
}

class StatsRowSkeleton extends StatelessWidget {
  final BloomTheme t;
  const StatsRowSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
      final spacing = S.scale(context, 12);
      final totalGutter = spacing * (crossAxisCount - 1);
      final childWidth = (constraints.maxWidth - totalGutter) / crossAxisCount;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: childWidth,
            child:
                Container(
                      padding: EdgeInsets.all(S.scale(context, 16)),
                      decoration: BoxDecoration(
                        color: t.bgSurface2,
                        borderRadius: BorderRadius.circular(
                          S.scale(context, 16),
                        ),
                        border: Border.all(
                          color: t.textPrimary,
                          width: S.scale(context, 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: Offset(
                              S.scale(context, 3),
                              S.scale(context, 3),
                            ),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: S.scale(context, 40),
                            height: S.scale(context, 40),
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(
                                S.scale(context, 12),
                              ),
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
                            ),
                          ),
                          SizedBox(height: S.scale(context, 12)),
                          Container(
                            width: S.scale(context, 60),
                            height: S.scale(context, 11),
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(S.scale(context, 4)),
                            ),
                          ),
                          SizedBox(height: S.scale(context, 6)),
                          Container(
                            width: S.scale(context, 80),
                            height: S.scale(context, 20),
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(S.scale(context, 4)),
                            ),
                          ),
                          SizedBox(height: S.scale(context, 6)),
                          Container(
                            width: S.scale(context, 70),
                            height: S.scale(context, 11),
                            decoration: BoxDecoration(
                              color: t.bgSurface3,
                              borderRadius: BorderRadius.circular(S.scale(context, 4)),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      );
    },
  );
}

class LevelSkeleton extends StatelessWidget {
  final BloomTheme t;
  const LevelSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(S.scale(context, 20)),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(S.scale(context, 24)),
      border: Border.all(
        color: t.textPrimary,
        width: S.scale(context, 2),
      ),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: Offset(
            S.scale(context, 3),
            S.scale(context, 3),
          ),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: S.scale(context, 20),
                  height: S.scale(context, 20),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(width: S.scale(context, 8)),
                Container(
                  width: S.scale(context, 80),
                  height: S.scale(context, 16),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                const Spacer(),
                Container(
                  width: S.scale(context, 60),
                  height: S.scale(context, 14),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        SizedBox(height: S.scale(context, 20)),
        ...List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < 2 ? S.scale(context, 12) : 0),
            child:
                Row(
                      children: [
                        Container(
                          width: S.scale(context, 28),
                          height: S.scale(context, 28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.bgSurface3,
                            border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
                          ),
                        ),
                        SizedBox(width: S.scale(context, 16)),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(S.scale(context, 16)),
                            decoration: BoxDecoration(
                              color: t.bgSurface3.withAlpha(50),
                              borderRadius: BorderRadius.circular(
                                S.scale(context, 16),
                              ),
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: S.scale(context, 100),
                                  height: S.scale(context, 14),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                                  ),
                                ),
                                SizedBox(height: S.scale(context, 8)),
                                Container(
                                  width: S.scale(context, 80),
                                  height: S.scale(context, 8),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms, color: t.bgSurface3),
          ),
        ),
      ],
    ),
  );
}

class BadgeGridSkeleton extends StatelessWidget {
  final BloomTheme t;
  const BadgeGridSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(S.scale(context, 20)),
    decoration: BoxDecoration(
      color: t.bgSurface2,
      borderRadius: BorderRadius.circular(S.scale(context, 24)),
      border: Border.all(
        color: t.textPrimary,
        width: S.scale(context, 2),
      ),
      boxShadow: [
        BoxShadow(
          color: t.textPrimary,
          offset: Offset(
            S.scale(context, 3),
            S.scale(context, 3),
          ),
          blurRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: S.scale(context, 20),
                  height: S.scale(context, 20),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(width: S.scale(context, 8)),
                Container(
                  width: S.scale(context, 100),
                  height: S.scale(context, 16),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                const Spacer(),
                Container(
                  width: S.scale(context, 40),
                  height: S.scale(context, 14),
                  decoration: BoxDecoration(
                    color: t.bgSurface3,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: t.bgSurface3),
        SizedBox(height: S.scale(context, 12)),
        Row(
          children: List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(right: S.scale(context, 8)),
              child:
                  Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: S.scale(context, 14),
                          vertical: S.scale(context, 6),
                        ),
                        decoration: BoxDecoration(
                          color: t.bgSurface3.withAlpha(50),
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 50),
                          ),
                          border: Border.all(
                            color: t.textPrimary,
                            width: S.scale(context, 2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: S.scale(context, 40),
                              height: S.scale(context, 13),
                              decoration: BoxDecoration(
                                color: t.bgSurface3,
                                borderRadius: BorderRadius.circular(S.scale(context, 4)),
                              ),
                            ),
                            SizedBox(width: S.scale(context, 6)),
                            Container(
                              width: S.scale(context, 20),
                              height: S.scale(context, 13),
                              decoration: BoxDecoration(
                                color: t.bgSurface3,
                                borderRadius: BorderRadius.circular(S.scale(context, 4)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 1200.ms, color: t.bgSurface3),
            ),
          ),
        ),
        SizedBox(height: S.scale(context, 12)),
        LayoutBuilder(
          builder: (_, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            final spacing = S.scale(context, 12);
            final totalGutter = spacing * (crossAxisCount - 1);
            final childWidth =
                (constraints.maxWidth - totalGutter) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                crossAxisCount,
                (_) => SizedBox(
                  width: childWidth,
                  child:
                      Container(
                            padding: EdgeInsets.all(S.scale(context, 16)),
                            decoration: BoxDecoration(
                              color: t.bgSurface3.withAlpha(50),
                              borderRadius: BorderRadius.circular(
                                S.scale(context, 16),
                              ),
                              border: Border.all(
                                color: t.textPrimary,
                                width: S.scale(context, 2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: S.scale(context, 56),
                                  height: S.scale(context, 56),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(
                                      S.scale(context, 16),
                                    ),
                                    border: Border.all(
                                      color: t.textPrimary,
                                      width: S.scale(context, 2),
                                    ),
                                  ),
                                ),
                                SizedBox(height: S.scale(context, 12)),
                                Container(
                                  width: S.scale(context, 60),
                                  height: S.scale(context, 14),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                                  ),
                                ),
                                SizedBox(height: S.scale(context, 4)),
                                Container(
                                  width: S.scale(context, 50),
                                  height: S.scale(context, 11),
                                  decoration: BoxDecoration(
                                    color: t.bgSurface3,
                                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 1200.ms, color: t.bgSurface3),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
