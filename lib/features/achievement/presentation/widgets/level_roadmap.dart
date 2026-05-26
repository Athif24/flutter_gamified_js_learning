import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/achievement_model.dart';

class LevelRoadmap extends ConsumerWidget {
  final List<LevelModel> levels;
  final int xpTotal;

  const LevelRoadmap({super.key, required this.levels, required this.xpTotal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    double rs(double px) => px * (w / 390).clamp(0.8, 1.3);
    final t = ref.watch(currentThemeProvider);
    final sorted = List<LevelModel>.from(levels)
      ..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));

    final currentLevelIdx = sorted.lastIndexWhere(
      (l) => l.requiredXp <= xpTotal,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(20)),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.textPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_rounded, color: t.primary, size: rs(20)),
              const SizedBox(width: 8),
              Text(
                'Peta Level',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: rs(16),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${currentLevelIdx + 1} / ${sorted.length} level',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: rs(14),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Positioned(
                left: 26,
                top: 16,
                bottom: 16,
                child: Container(width: 2, color: t.border.withAlpha(25)),
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
                      bottom: i < sorted.length - 1 ? 12 : 0,
                    ),
                    padding: EdgeInsets.all(rs(16)),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? t.primary.withAlpha(12)
                          : isPassed
                          ? t.success.withAlpha(12)
                          : t.bgSurface2.withAlpha(76),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent
                            ? t.primary
                            : isPassed
                            ? t.success.withAlpha(102)
                            : t.border.withAlpha(25),
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: t.primary.withAlpha(76),
                                offset: const Offset(3, 3),
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
                            width: rs(28),
                            child: Column(
                              children: [
                                const SizedBox(height: 2),
                                Container(
                                  width: rs(28),
                                  height: rs(28),
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
                                          : t.border.withAlpha(50),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: isPassed
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: t.primaryContent,
                                            size: rs(16),
                                          )
                                        : isCurrent
                                        ? Icon(
                                            Icons.star_rounded,
                                            color: t.primaryContent,
                                            size: rs(14),
                                          )
                                        : Icon(
                                            Icons.lock_rounded,
                                            color: t.mutedText.withAlpha(100),
                                            size: rs(14),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                                  : t.mutedText.withAlpha(127),
                                              fontWeight: FontWeight.w800,
                                              fontSize: rs(14),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrent) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: rs(8),
                                              vertical: rs(2),
                                            ),
                                            decoration: BoxDecoration(
                                              color: t.primary.withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: t.primary.withAlpha(100),
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'SEKARANG',
                                                style: GoogleFonts.nunito(
                                                  color: t.primary,
                                                  fontSize: rs(10),
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (isPassed) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: rs(8),
                                              vertical: rs(2),
                                            ),
                                            decoration: BoxDecoration(
                                              color: t.success.withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: t.success.withAlpha(100),
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'SELESAI',
                                                style: GoogleFonts.nunito(
                                                  color: t.success,
                                                  fontSize: rs(10),
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
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
                                        Icon(
                                          Icons.bolt_rounded,
                                          color: t.warning,
                                          size: rs(14),
                                        ),
                                        const SizedBox(width: 4),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${formatNumber(level.requiredXp)} XP',
                                            style: GoogleFonts.nunito(
                                              color: t.mutedText,
                                              fontSize: rs(11),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (level.rewardJewels > 0) ...[
                                          const SizedBox(width: 8),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '+${level.rewardJewels}',
                                            style: GoogleFonts.nunito(
                                              color: t.info,
                                              fontSize: rs(11),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.diamond_rounded,
                                          color: t.info,
                                          size: rs(14),
                                        ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                if (isCurrent && nextLevel != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: t.border.withAlpha(50),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        backgroundColor: t.bgSurface3,
                                        valueColor: AlwaysStoppedAnimation(
                                          t.primary,
                                        ),
                                        minHeight: rs(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${xpInLevel.clamp(0, 999999)} / $xpNeeded XP dalam level ini',
                                      style: GoogleFonts.nunito(
                                        color: t.mutedText,
                                        fontSize: rs(10),
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
        ],
      ),
    );
  }
}