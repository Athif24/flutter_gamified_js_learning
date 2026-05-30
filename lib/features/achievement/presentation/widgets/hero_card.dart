import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/achievement_model.dart';

class HeroCard extends StatelessWidget {
  final BloomTheme t;
  final XpModel xp;
  final StreakModel? streak;
  final LivesModel? lives;
  final String name;
  const HeroCard({
    super.key,
    required this.t,
    required this.xp,
    this.streak,
    this.lives,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(S.scale(context, 24)),
          decoration: BoxDecoration(
            color: t.primary,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Progress Kamu',
                      style: GoogleFonts.nunito(
                        color: t.primaryContent.withValues(alpha: 0.8),
                        fontSize: S.font(context, 14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 8),
                      vertical: S.scale(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: t.primaryContent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(S.scale(context, 50)),
                      border: Border.all(
                        color: t.textPrimary,
                        width: S.scale(context, 1.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.military_tech_rounded,
                          color: t.primaryContent,
                          size: S.scale(context, 12),
                        ),
                        const SizedBox(width: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            xp.levelTitle,
                            style: GoogleFonts.nunito(
                              color: t.primaryContent,
                              fontWeight: FontWeight.w800,
                              fontSize: S.font(context, 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: GoogleFonts.nunito(
                    color: t.primaryContent,
                    fontSize: S.font(context, 24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: t.primaryContent.withValues(alpha: 0.8),
                        size: S.scale(context, 16),
                      ),
                      const SizedBox(width: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${formatNumber(xp.totalXp)} XP',
                          style: GoogleFonts.nunito(
                            color: t.primaryContent.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w800,
                            fontSize: S.font(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            xp.nextLevelTitle != null
                                ? '${formatNumber(xp.xpToNextLevel)} XP lagi menuju ${xp.nextLevelTitle}'
                                : 'Max level!',
                            style: GoogleFonts.nunito(
                              color: t.primaryContent.withValues(alpha: 0.8),
                              fontSize: S.font(context, 12),
                            ),
                          ),
                        ),
                      ),
                      if (xp.nextLevelTitle != null)
                        Padding(
                          padding: EdgeInsets.only(left: S.scale(context, 4)),
                          child: Icon(
                            Icons.chevron_right,
                            color: t.primaryContent.withValues(alpha: 0.8),
                            size: S.scale(context, 14),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: S.scale(context, 24),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(S.scale(context, 12)),
                border: Border.all(
                  color: t.border.withAlpha(120),
                  width: S.scale(context, 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: t.border.withAlpha(75),
                    offset: Offset(
                      S.scale(context, 1),
                      S.scale(context, 1),
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(S.scale(context, 10)),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: xp.progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: t.bgSurface3,
                    valueColor: AlwaysStoppedAnimation(t.primary),
                    minHeight: S.scale(context, 20),
                  ),
                ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      xp.levelTitle,
                      style: GoogleFonts.nunito(
                        color: t.primaryContent.withValues(alpha: 0.8),
                        fontSize: S.font(context, 12),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (xp.nextLevelTitle != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        xp.nextLevelTitle!,
                        style: GoogleFonts.nunito(
                          color: t.primaryContent.withValues(alpha: 0.8),
                          fontSize: S.font(context, 12),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: S.scale(context, 12),
                  horizontal: S.scale(context, 16),
                ),
                decoration: BoxDecoration(
                  color: t.bgSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(S.scale(context, 16)),
                  border: Border.all(
                    color: t.textPrimary.withValues(alpha: 0.5),
                    width: S.scale(context, 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: S.scale(context, 32),
                            height: S.scale(context, 32),
                            decoration: BoxDecoration(
                              color: t.warning.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.warning.withValues(alpha: 0.3),
                                width: S.scale(context, 1.5),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                color: t.warning,
                                size: S.scale(context, 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${streak?.currentStreak ?? 0}',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent,
                                fontSize: S.font(context, 18),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'HARI STREAK',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent.withValues(alpha: 0.8),
                                fontSize: S.font(context, 10),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: S.scale(context, 1),
                      height: S.scale(context, 40),
                      color: t.textPrimary.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: S.scale(context, 32),
                            height: S.scale(context, 32),
                            decoration: BoxDecoration(
                              color: t.info.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.info.withValues(alpha: 0.3),
                                width: S.scale(context, 1.5),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.diamond_rounded,
                                color: t.info,
                                size: S.scale(context, 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatNumber(xp.jewels),
                              style: GoogleFonts.nunito(
                                color: t.primaryContent,
                                fontSize: S.font(context, 18),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'JEWELS',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent.withValues(alpha: 0.8),
                                fontSize: S.font(context, 10),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: S.scale(context, 1),
                      height: S.scale(context, 40),
                      color: t.textPrimary.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: S.scale(context, 32),
                            height: S.scale(context, 32),
                            decoration: BoxDecoration(
                              color: t.error.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.error.withValues(alpha: 0.3),
                                width: S.scale(context, 1.5),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: t.error,
                                size: S.scale(context, 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${lives?.current ?? 0}',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent,
                                fontSize: S.font(context, 18),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'LIVES',
                              style: GoogleFonts.nunito(
                                color: t.primaryContent.withValues(alpha: 0.8),
                                fontSize: S.font(context, 10),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
