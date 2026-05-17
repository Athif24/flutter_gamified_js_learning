import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../data/models/achievement_model.dart';

class XpHistoryList extends ConsumerWidget {
  final List<XpHistoryEntry> entries;
  final bool isLoading;

  const XpHistoryList({super.key, required this.entries, this.isLoading = false});

  Map<String, Map<String, dynamic>> _sourceConfig(BloomTheme t) => {
    'quiz':   {'icon': Icons.code_rounded,          'label': 'Quiz',      'color': t.accent,  'bg': t.accent.withAlpha(25)},
    'lesson': {'icon': Icons.menu_book_rounded,      'label': 'Pelajaran', 'color': t.success, 'bg': t.success.withAlpha(25)},
    'bonus':  {'icon': Icons.card_giftcard_rounded,   'label': 'Bonus',    'color': Colors.purple, 'bg': Colors.purple.withAlpha(25)},
  };

  String _formatDateGroup(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return 'Hari Ini';
    if (dateDay == yesterday) return 'Kemarin';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(currentThemeProvider);
    final sorted = List<XpHistoryEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<XpHistoryEntry>> groups = {};
    for (final entry in sorted) {
      final key = _formatDateGroup(entry.createdAt);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(entry);
    }

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
            Icon(Icons.history_rounded, color: t.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text('Riwayat XP', style: GoogleFonts.nunito(
                color: t.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w800)),
            if (sorted.isNotEmpty || isLoading) const Spacer(),
            if (sorted.isNotEmpty && !isLoading)
              Text('Total ${sorted.length} transaksi',
                  style: GoogleFonts.nunito(
                      color: t.textSecondary, fontSize: 14,
                      fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          if (isLoading)
            _loadingSkeleton(t)
          else if (sorted.isEmpty)
            _emptyState(t)
          else
            _buildList(t, groups),
        ],
      ),
    );
  }

  Widget _loadingSkeleton(BloomTheme t) {
    return Column(
      children: List.generate(6, (i) => Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(12),
          ),
        ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: t.bgSurface3),
      )),
    );
  }

  Widget _buildList(BloomTheme t, Map<String, List<XpHistoryEntry>> groups) {
    final groupList = groups.entries.toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 384),
      child: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        children: groupList.asMap().entries.expand((groupEntry) {
          final groupIdx = groupEntry.key;
          final dateLabel = groupEntry.value.key;
          final groupEntries = groupEntry.value.value;

          final items = <Widget>[];

          items.add(
            Padding(
              padding: EdgeInsets.only(top: groupIdx == 0 ? 0 : 20),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: Divider(color: t.textPrimary.withAlpha(25), height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(dateLabel,
                          style: GoogleFonts.nunito(
                              color: t.textSecondary.withAlpha(102),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1)),
                    ),
                    Expanded(child: Divider(color: t.textPrimary.withAlpha(25), height: 1)),
                  ]),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );

          for (final entry in groupEntries.asMap().entries) {
            if (entry.key > 0) items.add(const SizedBox(height: 8));
            items.add(_buildEntry(t, entry.value, groupIdx, entry.key));
          }

          return items;
        }).toList(),
      ),
    );
  }

  Widget _buildEntry(BloomTheme t, XpHistoryEntry e, int groupIdx, int entryIdx) {
    final totalIdx = groupIdx * 100 + entryIdx;
    final cfg = _sourceConfig(t)[e.sourceType] ??
        {'icon': Icons.star_rounded, 'label': e.sourceType, 'color': t.textSecondary, 'bg': t.bgSurface2};
    final icon = cfg['icon'] as IconData;
    final label = cfg['label'] as String;
    final iconColor = cfg['color'] as Color;
    final bgColor = cfg['bg'] as Color;
    final dateTime = DateTime.tryParse(e.createdAt);
    final time = dateTime != null
        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.bgSurface2.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.textPrimary.withAlpha(25)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withAlpha(76)),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
              if (time != null)
                Text(time,
                    style: GoogleFonts.nunito(
                        color: t.textSecondary.withAlpha(128),
                        fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: t.warning.withAlpha(25),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: t.warning.withAlpha(102), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: t.warning, size: 14),
              const SizedBox(width: 3),
              Text('+${_formatNumber(e.earnedXp)}',
                  style: GoogleFonts.nunito(
                      color: t.warning,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
        ),
      ]),
    ).animate().fadeIn(
      delay: Duration(milliseconds: totalIdx * 30),
    ).slideX(begin: 0.05);
  }

  Widget _emptyState(BloomTheme t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(children: [
        Icon(Icons.bolt_rounded, size: 48, color: t.textHint),
        const SizedBox(height: 12),
        Text('Belum ada XP yang dikumpulkan',
            style: GoogleFonts.nunito(
                color: t.textSecondary, fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Selesaikan quiz atau pelajaran untuk mendapat XP',
            style: GoogleFonts.nunito(
                color: t.textHint, fontSize: 12)),
      ]),
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
