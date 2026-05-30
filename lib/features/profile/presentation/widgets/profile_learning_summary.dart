import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/profile_model.dart';

class ProgressBlock extends StatelessWidget {
  final BloomTheme t;
  final String label, value, sub;
  final int pct;
  const ProgressBlock({
    super.key,
    required this.t,
    required this.label,
    required this.value,
    required this.pct,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(S.scale(context, 12)),
      decoration: BoxDecoration(
        color: t.bgSurface2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: S.scale(context, 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: t.textSecondary.withValues(alpha: 0.6),
                  fontSize: S.font(context, 12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: S.scale(context, 0.5),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 14),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 8)),
          Container(
            height: S.scale(context, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(S.scale(context, 4)),
              border: Border.all(color: t.textPrimary.withValues(alpha: 0.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(S.scale(context, 3)),
              child: LinearProgressIndicator(
                value: pct / 100.0,
                backgroundColor: t.bgSurface3,
                valueColor: AlwaysStoppedAnimation(t.primary),
                minHeight: S.scale(context, 6),
              ),
            ),
          ),
          SizedBox(height: S.scale(context, 4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              sub,
              style: GoogleFonts.nunito(
                color: t.textHint,
                fontSize: S.font(context, 11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  final BloomTheme t;
  final IconData icon;
  final Color iconColor;
  final Color bgColor, borderColor;
  final String label, value;
  const MiniStat({
    super.key,
    required this.t,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 10)),
      decoration: BoxDecoration(
        color: t.bgSurface2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(S.scale(context, 12)),
        border: Border.all(
          color: t.textPrimary.withValues(alpha: 0.15),
          width: S.scale(context, 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: S.scale(context, 32),
            height: S.scale(context, 32),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(S.scale(context, 8)),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: S.scale(context, 16)),
            ),
          ),
          SizedBox(width: S.scale(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: t.textSecondary.withValues(alpha: 0.55),
                      fontSize: S.font(context, 10),
                      fontWeight: FontWeight.w700,
                      letterSpacing: S.scale(context, 0.5),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 14),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLearningSummary extends StatelessWidget {
  final BloomTheme t;
  final ProfileModel profile;
  const ProfileLearningSummary({super.key, required this.t, required this.profile});

  @override
  Widget build(BuildContext context) {
    final courseRate = profile.coursesEnrolled > 0
        ? (profile.coursesCompleted / profile.coursesEnrolled * 100).round()
        : 0;
    final quizPassRate = profile.quizAttempts > 0
        ? (profile.quizPassed / profile.quizAttempts * 100).round()
        : 0;

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
              Icon(Icons.menu_book_rounded, color: t.primary, size: S.scale(context, 20)),
              SizedBox(width: S.scale(context, 8)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    'Ringkasan Belajar',
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 16),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 10),
                  vertical: S.scale(context, 4),
                ),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(S.scale(context, 50)),
                  border: Border.all(
                    color: t.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '${profile.lessonsCompleted} lesson selesai',
                  style: GoogleFonts.nunito(
                    color: t.primary,
                    fontSize: S.font(context, 11),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          ProgressBlock(
            t: t,
            label: 'Progres Course',
            value: '${profile.coursesCompleted}/${profile.coursesEnrolled}',
            pct: courseRate,
            sub: '$courseRate% course sudah dituntaskan',
          ),
          SizedBox(height: S.scale(context, 12)),
          ProgressBlock(
            t: t,
            label: 'Pass Rate Quiz',
            value: '${profile.quizPassed}/${profile.quizAttempts}',
            pct: quizPassRate,
            sub: '$quizPassRate% quiz berhasil dilalui',
          ),
          SizedBox(height: S.scale(context, 16)),
          LayoutBuilder(
            builder: (_, constraints) {
              final spacing = S.scale(context, 12);
              final childWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: childWidth,
                    child: MiniStat(
                      t: t,
                      icon: Icons.track_changes_rounded,
                      iconColor: t.success,
                      bgColor: t.success.withValues(alpha: 0.1),
                      borderColor: t.success.withValues(alpha: 0.3),
                      label: 'Skor Rata-rata',
                      value: '${profile.avgScore.round()}%',
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: MiniStat(
                      t: t,
                      icon: Icons.emoji_events_rounded,
                      iconColor: t.warning,
                      bgColor: t.warning.withValues(alpha: 0.1),
                      borderColor: t.warning.withValues(alpha: 0.3),
                      label: 'Skor Terbaik',
                      value: '${profile.bestScore.round()}%',
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: MiniStat(
                      t: t,
                      icon: Icons.check_circle_rounded,
                      iconColor: t.primary,
                      bgColor: t.primary.withValues(alpha: 0.1),
                      borderColor: t.primary.withValues(alpha: 0.3),
                      label: 'Quiz Attempt',
                      value: formatNumber(profile.quizAttempts),
                    ),
                  ),
                  SizedBox(
                    width: childWidth,
                    child: MiniStat(
                      t: t,
                      icon: Icons.menu_book_rounded,
                      iconColor: t.primary,
                      bgColor: t.primary.withValues(alpha: 0.1),
                      borderColor: t.textPrimary.withValues(alpha: 0.35),
                      label: 'Lesson Selesai',
                      value: formatNumber(profile.lessonsCompleted),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}
