import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../shared/services/sound_service.dart';
import '../../../../../core/utils/responsive_utils.dart';
import 'map_item.dart';
import 'unit_header.dart';
import 'lesson_bubble.dart';
import 'peta_belajar_painter.dart';

class PetaBelajar extends ConsumerWidget {
  final List<MapItem> items;
  final ScrollController scrollCtrl;
  final List<GlobalKey> itemKeys;
  final BloomTheme t;
  final String courseId;

  const PetaBelajar({
    super.key,
    required this.items,
    required this.scrollCtrl,
    required this.itemKeys,
    required this.t,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        final unitH = isLandscape ? 48.0 : 72.0;

        return LayoutBuilder(
          builder: (ctx, constraints) {
            final centerX = constraints.maxWidth / 2;
            final positions = <NodePos>[];
            double y = 0;

            for (int i = 0; i < items.length; i++) {
              final item = items[i];
              if (item.isLesson) {
                final h = isLandscape
                    ? 128.0
                    : (item.isFirstActive ? 192.0 : 152.0);
                final offsetX = item.lessonMapIndex.isEven
                    ? -S.scale(ctx, 70.0) * (S.isTablet(ctx) ? 1.5 : 1.0)
                    : S.scale(ctx, 70.0) * (S.isTablet(ctx) ? 1.5 : 1.0);
                positions.add(NodePos(x: centerX + offsetX, y: y + h / 2));
                y += h;
              } else {
                y += unitH;
              }
            }

            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.only(bottom: S.scale(context, 24)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (positions.length >= 2)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PetaBelajarPainter(positions: positions, t: t),
                      ),
                    ),
                  Column(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      if (!item.isLesson) {
                        return UnitHeader(
                          name: item.unitName ?? '',
                          t: t,
                          compact: isLandscape,
                        );
                      }
                      final bubble = Semantics(
                        button: true,
                        label: item.isLocked
                            ? '${item.lessonName} (terkunci)'
                            : 'Buka ${item.lessonName}',
                        child: Bounceable(
                          onTap: item.isLocked
                              ? null
                              : () {
                                  ref.read(soundProvider).playClick();
                                  context.push(
                                    '/lesson/${item.lessonId}?courseId=$courseId',
                                  );
                                },
                          child: Container(
                            key: itemKeys[i],
                            height: isLandscape
                                ? 128
                                : (item.isFirstActive ? 192 : 152),
                            alignment: Alignment.center,
                            child: LessonBubble(
                              name: item.lessonName ?? '',
                              isLocked: item.isLocked,
                              isCompleted: item.isCompleted,
                              isFirstActive: item.isFirstActive,
                              mapIndex: item.lessonMapIndex,
                              t: t,
                            ),
                          ),
                        ),
                      );
                      if (item.isFirstActive) {
                        return Padding(
                          padding: EdgeInsets.only(top: S.scale(context, 40)),
                          child: bubble,
                        );
                      }
                      return bubble;
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}