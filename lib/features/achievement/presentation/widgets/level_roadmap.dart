import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../data/models/achievement_model.dart';

class LevelRoadmap extends ConsumerWidget {
  final List<LevelModel> levels;
  final int xpTotal;

  const LevelRoadmap({
    super.key,
    required this.levels,
    required this.xpTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final sorted = List<LevelModel>.from(levels)
      ..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));

    final currentLevelIdx = sorted.lastIndexWhere((l) => l.requiredXp <= xpTotal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border, width: 2),
        boxShadow: [BoxShadow(color: t.border, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.map_rounded, color: t.accent, size: 20),
            const SizedBox(width: 8),
            Text('Peta Level', style: GoogleFonts.nunito(
                color: t.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('${currentLevelIdx + 1} / ${sorted.length} level',
                style: GoogleFonts.nunito(
                    color: t.textSecondary, fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
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
                  final nextLevel = i + 1 < sorted.length ? sorted[i + 1] : null;
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
                        bottom: i < sorted.length - 1 ? 12 : 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? t.accent.withAlpha(12)
                          : isPassed
                              ? t.success.withAlpha(12)
                              : t.bgSurface2.withAlpha(76),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent
                            ? t.accent
                            : isPassed
                                ? t.success.withAlpha(102)
                                : t.border.withAlpha(25),
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [BoxShadow(
                              color: t.accent.withAlpha(76),
                              offset: const Offset(3, 3),
                              blurRadius: 0)]
                          : null,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Column(children: [
                              const SizedBox(height: 2),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPassed
                                      ? t.success
                                      : isCurrent
                                          ? t.accent
                                          : t.bgSurface2,
                                  border: Border.all(
                                    color: isPassed
                                        ? t.success
                                        : isCurrent
                                            ? t.accent
                                            : t.border.withAlpha(50),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                    child: isPassed
                                        ? Icon(Icons.check_rounded,
                                            color: t.accentText, size: 16)
                                        : isCurrent
                                            ? Icon(Icons.star_rounded,
                                                color: t.accentText, size: 14)
                                            : Icon(Icons.lock_rounded,
                                                color: t.textHint.withAlpha(100), size: 14),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8, runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 140),
                                        child: Text(level.name,
                                            style: GoogleFonts.nunito(
                                                color: isCurrent
                                                    ? t.accent
                                                    : isPassed
                                                        ? t.success
                                                        : t.textSecondary.withAlpha(127),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: t.accent.withAlpha(25),
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(
                                                color: t.accent.withAlpha(100)),
                                          ),
                                          child: Text('SEKARANG',
                                              style: GoogleFonts.nunito(
                                                  color: t.accent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5)),
                                        ),
                                      ],
                                      if (isPassed) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: t.success.withAlpha(25),
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(
                                                color: t.success.withAlpha(100)),
                                          ),
                                          child: Text('SELESAI',
                                              style: GoogleFonts.nunito(
                                                  color: t.success,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5)),
                                        ),
                                      ],
                                    ]),
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.bolt_rounded,
                                          color: t.warning, size: 14),
                                      const SizedBox(width: 4),
                                      Text('${_formatNumber(level.requiredXp)} XP',
                                          style: GoogleFonts.nunito(
                                              color: t.textSecondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                      if (level.rewardJewels > 0) ...[
                                        const SizedBox(width: 8),
                                        Text('+${level.rewardJewels}',
                                            style: GoogleFonts.nunito(
                                                color: t.info,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 2),
                                        Icon(Icons.diamond_rounded,
                                            color: t.info, size: 14),
                                      ],
                                    ]),
                                  ],
                                ),
                                if (isCurrent && nextLevel != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: t.border.withAlpha(50)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        backgroundColor: t.bgSurface3,
                                        valueColor:
                                            AlwaysStoppedAnimation(t.accent),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${xpInLevel.clamp(0, 999999)} / $xpNeeded XP dalam level ini',
                                    style: GoogleFonts.nunito(
                                        color: t.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 60 * i));

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

String _formatNumber(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final parts = <String>[];
  for (int i = s.length; i > 0; i -= 3) {
    parts.insert(0, s.substring(i > 3 ? i - 3 : 0, i));
  }
  return parts.join('.');
}
