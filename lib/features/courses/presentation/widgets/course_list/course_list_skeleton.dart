import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';

class HeaderBannerSkeleton extends StatelessWidget {
  final BloomTheme t;
  const HeaderBannerSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = t.bgSurface3;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        S.scale(context, 12),
        S.scale(context, 20),
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: t.bgSurface2,
          borderRadius: BorderRadius.circular(S.scale(context, 24)),
          border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
          boxShadow: [
            BoxShadow(
              color: t.textPrimary,
              offset: Offset(S.scale(context, 3), S.scale(context, 3)),
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
                children: [
                  Container(
                    width: S.scale(context, 24),
                    height: S.scale(context, 24),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(S.scale(context, 6)),
                    ),
                  ),
                  SizedBox(width: S.scale(context, 8)),
                  Container(
                    width: S.scale(context, 140),
                    height: S.scale(context, 14),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(S.scale(context, 4)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: S.scale(context, 6)),
              Container(
                width: S.scale(context, 220),
                height: S.scale(context, 12),
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(S.scale(context, 4)),
                ),
              ),
              SizedBox(height: S.scale(context, 14)),
              Container(
                width: S.scale(context, 130),
                height: S.scale(context, 26),
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(S.scale(context, 50)),
                ),
              ),
            ],
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: shimmerColor),
        ),
      ),
    );
  }
}

class CourseCardSkeleton extends StatelessWidget {
  final BloomTheme t;
  const CourseCardSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = t.bgSurface3;
    return Container(
      margin: EdgeInsets.only(bottom: S.scale(context, 16)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 24)),
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
        children: [
          Container(
            height: S.scale(context, 144),
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(S.scale(context, 23)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(S.scale(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: S.scale(context, 180),
                  height: S.scale(context, 14),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(height: S.scale(context, 6)),
                Container(
                  width: S.scale(context, 250),
                  height: S.scale(context, 12),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(height: S.scale(context, 4)),
                Container(
                  width: S.scale(context, 200),
                  height: S.scale(context, 12),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(height: S.scale(context, 10)),
                Container(
                  width: S.scale(context, 80),
                  height: S.scale(context, 12),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(S.scale(context, 4)),
                  ),
                ),
                SizedBox(height: S.scale(context, 12)),
                Container(
                  width: double.infinity,
                  height: S.scale(context, 48),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(S.scale(context, 14)),
                  ),
                ),
              ],
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: shimmerColor),
          ),
        ],
      ),
    );
  }
}
