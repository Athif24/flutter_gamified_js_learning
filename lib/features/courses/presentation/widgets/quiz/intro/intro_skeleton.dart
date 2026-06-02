import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../shared/themes/theme_provider.dart';
import '../../../../../../core/utils/responsive_utils.dart';

class IntroSkeleton extends StatelessWidget {
  final BloomTheme t;
  const IntroSkeleton({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final sh = t.bgSurface3;
    return SingleChildScrollView(
      padding: EdgeInsets.all(S.scale(context, 28)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: S.scale(context, 20)),
          Container(
                width: S.scale(context, 80),
                height: S.scale(context, 80),
                decoration: BoxDecoration(shape: BoxShape.circle, color: sh),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 16)),
          Container(
                width: S.scale(context, 140),
                height: S.scale(context, 22),
                decoration: BoxDecoration(
                  color: sh,
                  borderRadius: BorderRadius.circular(S.scale(context, 6)),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 10)),
          Container(
                width: S.scale(context, 100),
                height: S.scale(context, 22),
                decoration: BoxDecoration(
                  color: sh,
                  borderRadius: BorderRadius.circular(S.scale(context, 50)),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 28)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: S.scale(context, 20),
                    height: S.scale(context, 20),
                    decoration: BoxDecoration(
                      color: sh,
                      borderRadius: BorderRadius.circular(S.scale(context, 4)),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: sh),
              SizedBox(width: S.scale(context, 6)),
              Container(
                    width: S.scale(context, 40),
                    height: S.scale(context, 14),
                    decoration: BoxDecoration(
                      color: sh,
                      borderRadius: BorderRadius.circular(S.scale(context, 4)),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: sh),
            ],
          ),
          SizedBox(height: S.scale(context, 20)),
          Wrap(
            spacing: S.scale(context, 10),
            runSpacing: S.scale(context, 8),
            children: List.generate(3, (i) {
              final widths = [90.0, 120.0, 80.0];
              return Container(
                    height: S.scale(context, 28),
                    width: S.scale(context, widths[i]),
                    decoration: BoxDecoration(
                      color: sh,
                      borderRadius: BorderRadius.circular(S.scale(context, 50)),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: sh);
            }),
          ),
          SizedBox(height: S.scale(context, 24)),
          Container(
                width: S.scale(context, 140),
                height: S.scale(context, 12),
                decoration: BoxDecoration(
                  color: sh,
                  borderRadius: BorderRadius.circular(S.scale(context, 4)),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 6)),
          Container(
                width: S.scale(context, 60),
                height: S.scale(context, 20),
                decoration: BoxDecoration(
                  color: sh,
                  borderRadius: BorderRadius.circular(S.scale(context, 4)),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 32)),
          Container(
                width: double.infinity,
                height: S.scale(context, 48),
                decoration: BoxDecoration(
                  color: sh,
                  borderRadius: BorderRadius.circular(S.scale(context, 12)),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: sh),
          SizedBox(height: S.scale(context, 40)),
        ],
      ),
    );
  }
}