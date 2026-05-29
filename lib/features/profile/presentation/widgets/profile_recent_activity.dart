import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/profile_model.dart';

class ProfileRecentActivity extends StatelessWidget {
  final BloomTheme t;
  final List<RecentXpEntry> entries;
  const ProfileRecentActivity({super.key, required this.t, required this.entries});

  static const _sourceConfig = {
    'quiz': {'icon': Icons.code_rounded, 'label': 'Quiz'},
    'lesson': {
      'icon': Icons.menu_book_rounded,
      'label': 'Lesson',
    },
    'bonus': {
      'icon': Icons.card_giftcard_rounded,
      'label': 'Bonus',
    },
  };

  String _dateLabel(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(d.year, d.month, d.day);
    if (dateDay == today) return 'Hari ini';
    if (dateDay == yesterday) return 'Kemarin';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _timeStr(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalXp = entries.fold<int>(0, (sum, e) => sum + e.xpEarned);

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
              Icon(Icons.timeline_rounded, color: t.warning, size: S.scale(context, 20)),
              SizedBox(width: S.scale(context, 8)),
              Text(
                'Aktivitas Terbaru',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 16),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 10),
                  vertical: S.scale(context, 4),
                ),
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(S.scale(context, 50)),
                  border: Border.all(
                    color: t.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: t.warning, size: S.scale(context, 14)),
                    SizedBox(width: S.scale(context, 3)),
                    Text(
                      '+${formatNumber(totalXp)} XP',
                      style: GoogleFonts.nunito(
                        color: t.warning,
                        fontSize: S.font(context, 11),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          if (entries.isEmpty)
            _emptyActivity(t, context)
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: S.scale(context, 320)),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, __) => SizedBox(height: S.scale(context, 8)),
                itemBuilder: (ctx, i) => _buildEntry(t, entries[i], context),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEntry(BloomTheme t, RecentXpEntry e, BuildContext context) {
    final cfg = _sourceConfig[e.sourceType] ?? _sourceConfig['lesson']!;
    final icon = cfg['icon'] as IconData;
    final label = cfg['label'] as String;

    Color iconColor;
    Color bgColor;
    switch (e.sourceType) {
      case 'quiz':
        iconColor = t.primary;
        bgColor = t.primary.withValues(alpha: 0.1);
        break;
      case 'bonus':
        iconColor = t.secondary;
        bgColor = t.secondary.withValues(alpha: 0.1);
        break;
      default:
        iconColor = t.success;
        bgColor = t.success.withValues(alpha: 0.1);
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: S.scale(context, 12), vertical: S.scale(context, 10)),
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
              width: S.scale(context, 36),
              height: S.scale(context, 36),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(S.scale(context, 12)),
                border: Border.all(
                  color: t.textPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(icon, color: iconColor, size: S.scale(context, 16)),
            ),
            SizedBox(width: S.scale(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontSize: S.font(context, 14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_dateLabel(e.createdAt)} • ${_timeStr(e.createdAt)}',
                    style: GoogleFonts.nunito(
                      color: t.textHint,
                      fontSize: S.font(context, 11),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: S.scale(context, 10), vertical: S.scale(context, 4)),
              decoration: BoxDecoration(
                color: t.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(S.scale(context, 50)),
                border: Border.all(
                  color: t.textPrimary.withValues(alpha: 0.35),
                  width: S.scale(context, 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: t.warning, size: S.scale(context, 14)),
                  SizedBox(width: S.scale(context, 3)),
                  Text(
                    '+${formatNumber(e.xpEarned)}',
                    style: GoogleFonts.nunito(
                      color: t.warning,
                      fontSize: S.font(context, 14),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _emptyActivity(BloomTheme t, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: S.scale(context, 40)),
      decoration: BoxDecoration(
        color: t.bgSurface2,
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
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
        children: [
          Icon(Icons.bolt_rounded, size: S.scale(context, 40), color: t.mutedText),
          SizedBox(height: S.scale(context, 8)),
          Text(
            'Belum ada aktivitas terbaru',
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: S.font(context, 13),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: S.scale(context, 4)),
          Text(
            'Selesaikan quiz atau lesson untuk mulai kumpulkan XP.',
            style: GoogleFonts.nunito(color: t.mutedText, fontSize: S.font(context, 11)),
          ),
        ],
      ),
    );
  }
}
