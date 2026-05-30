import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../../../../core/utils/responsive_utils.dart';
import 'start_here_label.dart';

class LessonBubble extends StatelessWidget {
  final String name;
  final bool isLocked;
  final bool isCompleted;
  final bool isFirstActive;
  final int mapIndex;
  final BloomTheme t;

  const LessonBubble({
    super.key,
    required this.name,
    required this.isLocked,
    required this.isCompleted,
    required this.isFirstActive,
    required this.mapIndex,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final offsetX = mapIndex.isEven
        ? -S.scale(context, 70.0)
        : S.scale(context, 70.0);

    final bubbleSize = S.scale(context, 64.0);
    Widget circle = Container(
      width: bubbleSize,
      height: bubbleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? t.bgSurface
            : isLocked
            ? t.bgSurface2
            : t.primary,
        border: Border.all(width: S.scale(context, 2), color: t.textPrimary),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            blurRadius: 0,
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isLocked)
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(bubbleSize * 0.09),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryContent.withValues(alpha: 0.15),
                ),
              ),
            ),
          Center(
            child: isCompleted
                ? Icon(Icons.check, size: bubbleSize * 0.375, color: t.success)
                : isLocked
                ? Icon(
                    Icons.lock_outline,
                    size: bubbleSize * 0.31,
                    color: t.mutedText.withValues(alpha: 0.5),
                  )
                : Icon(
                    Icons.menu_book_rounded,
                    size: bubbleSize * 0.34,
                    color: t.primaryContent,
                  ),
          ),
        ],
      ),
    );

    if (isFirstActive) {
      circle = circle
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(duration: 1200.ms, begin: 1.0, end: 1.06);
    }

    Widget bubble = Transform.translate(
      offset: Offset(offsetX, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              SizedBox(
                height: S.isTablet(context)
                    ? S.scale(context, 16)
                    : S.scale(context, 8),
              ),
              SizedBox(
                width: S.scale(context, 120.0).clamp(80.0, 180.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: isLocked
                        ? t.mutedText.withValues(alpha: 0.5)
                        : t.textPrimary.withValues(alpha: 0.8),
                    fontSize: S.font(context, 11),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (isFirstActive)
            Positioned(
              top: S.scale(context, -40),
              left: 0,
              right: 0,
              child: Center(child: StartHereLabel(t: t)),
            ),
        ],
      ),
    );

    return bubble;
  }
}