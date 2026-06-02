import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/achievement_model.dart';

class LevelRoadmap extends ConsumerWidget {
  final List<LevelModel> levels;
  final int xpTotal;

  const LevelRoadmap({super.key, required this.levels, required this.xpTotal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final sorted = List<LevelModel>.from(levels)
      ..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));

    final currentLevelIdx = sorted.lastIndexWhere(
      (l) => l.requiredXp <= xpTotal,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(S.scale(context, 20)),
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
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.map_rounded,
                  color: t.primary,
                  size: S.scale(context, 20),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Peta Level',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: S.font(context, 16),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${currentLevelIdx + 1} / ${sorted.length} level',
                  style: GoogleFonts.nunito(
                    color: t.mutedText,
                    fontSize: S.font(context, 14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 20)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Positioned(
                    left: S.scale(context, 26),
                    top: S.scale(context, 16),
                    bottom: S.scale(context, 16),
                    child: Container(
                      width: S.scale(context, 2),
                      color: t.border.withValues(alpha: 25 / 255),
                    ),
                  ),
                  Column(
                    children: sorted.asMap().entries.map((entry) {
                      final i = entry.key;
                      final level = entry.value;
                      final nextLevel = i + 1 < sorted.length
                          ? sorted[i + 1]
                          : null;
                      final isPassed = i < currentLevelIdx;
                      final isCurrent = i == currentLevelIdx;
                      final isLocked = i > currentLevelIdx;

                      final xpInLevel = xpTotal - level.requiredXp;
                      final xpNeeded = nextLevel != null
                          ? nextLevel.requiredXp - level.requiredXp
                          : 0;
                      final pct = isCurrent && nextLevel != null
                          ? (xpInLevel / xpNeeded).clamp(0.0, 1.0)
                          : 0.0;

                      final outerCard = Container(
                        margin: EdgeInsets.only(
                          bottom: i < sorted.length - 1
                              ? S.scale(context, 12)
                              : 0,
                        ),
                        padding: EdgeInsets.all(S.scale(context, 16)),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? t.primary.withValues(alpha: 12 / 255)
                              : isPassed
                              ? t.success.withValues(alpha: 12 / 255)
                              : t.bgSurface2.withValues(alpha: 76 / 255),
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 16),
                          ),
                          border: Border.all(
                            color: isCurrent
                                ? t.primary
                                : isPassed
                                ? t.success.withValues(alpha: 102 / 255)
                                : t.border.withValues(alpha: 25 / 255),
                            width: S.scale(context, 2),
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: t.primary.withValues(
                                      alpha: 76 / 255,
                                    ),
                                    offset: Offset(
                                      S.scale(context, 3),
                                      S.scale(context, 3),
                                    ),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: S.scale(context, 28),
                                child: Column(
                                  children: [
                                    SizedBox(height: S.scale(context, 2)),
                                    Container(
                                      width: S.scale(context, 28),
                                      height: S.scale(context, 28),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isPassed
                                            ? t.success
                                            : isCurrent
                                            ? t.primary
                                            : t.bgSurface2,
                                        border: Border.all(
                                          color: isPassed
                                              ? t.success
                                              : isCurrent
                                              ? t.primary
                                              : t.border.withValues(
                                                  alpha: 50 / 255,
                                                ),
                                          width: S.scale(context, 2),
                                        ),
                                      ),
                                      child: Center(
                                        child: isPassed
                                            ? ExcludeSemantics(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  color: t.primaryContent,
                                                  size: S.scale(context, 16),
                                                ),
                                              )
                                            : isCurrent
                                            ? ExcludeSemantics(
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  color: t.primaryContent,
                                                  size: S.scale(context, 14),
                                                ),
                                              )
                                            : ExcludeSemantics(
                                                child: Icon(
                                                  Icons.lock_rounded,
                                                  color: t.mutedText.withValues(
                                                    alpha: 100 / 255,
                                                  ),
                                                  size: S.scale(context, 14),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: S.scale(context, 16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: S.scale(context, 8),
                                      runSpacing: S.scale(context, 4),
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                level.name,
                                                style: GoogleFonts.nunito(
                                                  color: isCurrent
                                                      ? t.primary
                                                      : isPassed
                                                      ? t.success
                                                      : t.mutedText.withValues(
                                                          alpha: 127 / 255,
                                                        ),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: S.font(context, 14),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isCurrent) ...[
                                              SizedBox(
                                                width: S.scale(context, 8),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: S.scale(
                                                    context,
                                                    8,
                                                  ),
                                                  vertical: S.scale(context, 2),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: t.primary.withValues(
                                                    alpha: 25 / 255,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        S.scale(context, 50),
                                                      ),
                                                  border: Border.all(
                                                    color: t.primary.withValues(
                                                      alpha: 100 / 255,
                                                    ),
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'SEKARANG',
                                                    style: GoogleFonts.nunito(
                                                      color: t.primary,
                                                      fontSize: S.font(
                                                        context,
                                                        10,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: S.scale(
                                                        context,
                                                        0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (isPassed) ...[
                                              SizedBox(
                                                width: S.scale(context, 8),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: S.scale(
                                                    context,
                                                    8,
                                                  ),
                                                  vertical: S.scale(context, 2),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: t.success.withValues(
                                                    alpha: 25 / 255,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        S.scale(context, 50),
                                                      ),
                                                  border: Border.all(
                                                    color: t.success.withValues(
                                                      alpha: 100 / 255,
                                                    ),
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'SELESAI',
                                                    style: GoogleFonts.nunito(
                                                      color: t.success,
                                                      fontSize: S.font(
                                                        context,
                                                        10,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: S.scale(
                                                        context,
                                                        0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ExcludeSemantics(
                                              child: Icon(
                                                Icons.bolt_rounded,
                                                color: t.warning,
                                                size: S.scale(context, 14),
                                              ),
                                            ),
                                            SizedBox(
                                              width: S.scale(context, 4),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '${formatNumber(level.requiredXp)} XP',
                                                style: GoogleFonts.nunito(
                                                  color: t.mutedText,
                                                  fontSize: S.font(context, 11),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (level.rewardJewels > 0) ...[
                                              SizedBox(
                                                width: S.scale(context, 8),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '+${level.rewardJewels}',
                                                  style: GoogleFonts.nunito(
                                                    color: t.info,
                                                    fontSize: S.font(
                                                      context,
                                                      11,
                                                    ),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: S.scale(context, 2),
                                              ),
                                              ExcludeSemantics(
                                                child: Icon(
                                                  Icons.diamond_rounded,
                                                  color: t.info,
                                                  size: S.scale(context, 14),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (isCurrent && nextLevel != null) ...[
                                      SizedBox(height: S.scale(context, 8)),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: t.border.withValues(
                                              alpha: 50 / 255,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 4),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            S.scale(context, 3),
                                          ),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: t.bgSurface3,
                                            valueColor: AlwaysStoppedAnimation(
                                              t.primary,
                                            ),
                                            minHeight: S.scale(context, 8),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: S.scale(context, 4)),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${xpInLevel.clamp(0, 999999)} / $xpNeeded XP dalam level ini',
                                          style: GoogleFonts.nunito(
                                            color: t.mutedText,
                                            fontSize: S.font(context, 10),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 60 * i));

                      if (isLocked) return Opacity(opacity: 0.6, child: outerCard);
                      return outerCard;
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}