import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/achievement_model.dart';
import '../utils/date_utils.dart';

class XpHistoryList extends ConsumerStatefulWidget {
  final List<XpHistoryEntry> entries;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const XpHistoryList({
    super.key,
    required this.entries,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  @override
  ConsumerState<XpHistoryList> createState() => _XpHistoryListState();
}

class _SourceConfig {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _SourceConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });
}

class _XpHistoryListState extends ConsumerState<XpHistoryList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore || widget.onLoadMore == null) {
      return;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      widget.onLoadMore!();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, _SourceConfig> _sourceConfig(BloomTheme t) => {
    'quiz': _SourceConfig(
      icon: Icons.code_rounded,
      label: 'Quiz',
      color: t.primary,
      bg: t.primary.withValues(alpha: 25/255),
    ),
    'lesson': _SourceConfig(
      icon: Icons.menu_book_rounded,
      label: 'Pelajaran',
      color: t.success,
      bg: t.success.withValues(alpha: 25/255),
    ),
    'bonus': _SourceConfig(
      icon: Icons.card_giftcard_rounded,
      label: 'Bonus',
      color: t.secondary,
      bg: t.secondary.withValues(alpha: 25/255),
    ),
    'unit': _SourceConfig(
      icon: Icons.folder_rounded,
      label: 'Unit',
      color: t.info,
      bg: t.info.withValues(alpha: 25/255),
    ),
    'course': _SourceConfig(
      icon: Icons.school_rounded,
      label: 'Kursus',
      color: t.warning,
      bg: t.warning.withValues(alpha: 25/255),
    ),
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

    return '${date.day} ${monthsId[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final sorted = List<XpHistoryEntry>.from(widget.entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<XpHistoryEntry>> groups = {};
    for (final entry in sorted) {
      final key = _formatDateGroup(entry.createdAt);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(entry);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(S.scale(context, 20)),
      decoration: BoxDecoration(
        color: t.bgSurface,
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
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.history_rounded,
                  color: t.mutedText,
                  size: S.scale(context, 20),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Riwayat XP',
                  style: GoogleFonts.nunito(
                    color: t.textPrimary,
                    fontSize: S.font(context, 16),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (sorted.isNotEmpty || widget.isLoading) const Spacer(),
              if (sorted.isNotEmpty && !widget.isLoading)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Total ${sorted.length} transaksi',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: S.font(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          if (widget.isLoading)
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
      children: List.generate(
        6,
        (i) => Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : S.scale(context, 8)),
          child:
              Container(
                    height: S.scale(context, 56),
                    decoration: BoxDecoration(
                      color: t.bgSurface2,
                      borderRadius: BorderRadius.circular(
                        S.scale(context, 12),
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: t.bgSurface3),
        ),
      ),
    );
  }

  Widget _buildList(BloomTheme t, Map<String, List<XpHistoryEntry>> groups) {
    final groupList = groups.entries.toList();

    final children = groupList.asMap().entries.expand((groupEntry) {
      final groupIdx = groupEntry.key;
      final dateLabel = groupEntry.value.key;
      final groupEntries = groupEntry.value.value;

      final items = <Widget>[];

      items.add(
        Padding(
          padding: EdgeInsets.only(top: groupIdx == 0 ? 0 : S.scale(context, 20)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Divider(
                        color: t.textPrimary.withValues(alpha: 25/255),
                        height: S.scale(context, 1),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: S.scale(context, 10),
                    ),
                    child: Text(
                      dateLabel,
                      style: GoogleFonts.nunito(
                        color: t.mutedText.withValues(alpha: 102/255),
                        fontSize: S.font(context, 11),
                        fontWeight: FontWeight.w800,
                        letterSpacing: S.scale(context, 1.1),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                        color: t.textPrimary.withValues(alpha: 25/255),
                        height: S.scale(context, 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: S.scale(context, 8)),
            ],
          ),
        ),
      );

      for (final entry in groupEntries.asMap().entries) {
        if (entry.key > 0) items.add(SizedBox(height: S.scale(context, 8)));
        items.add(_buildEntry(t, entry.value, groupIdx, entry.key));
      }

      return items;
    }).toList();

    if (widget.isLoadingMore) {
      children.add(
        Padding(
          padding: EdgeInsets.only(top: S.scale(context, 8)),
          child:
              Container(
                    height: S.scale(context, 56),
                    decoration: BoxDecoration(
                      color: t.bgSurface2,
                      borderRadius: BorderRadius.circular(
                        S.scale(context, 12),
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: t.bgSurface3),
              ),
            );
        }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: S.scale(context, 384)),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: children.length,
        itemBuilder: (_, i) => children[i],
      ),
    );
  }

  Widget _buildEntry(
    BloomTheme t,
    XpHistoryEntry e,
    int groupIdx,
    int entryIdx,
  ) {
    final totalIdx = groupIdx * 100 + entryIdx;
    final cfg =
        _sourceConfig(t)[e.sourceType] ??
        _SourceConfig(
          icon: Icons.star_rounded,
          label: e.sourceType,
          color: t.mutedText,
          bg: t.bgSurface2,
        );
    final icon = cfg.icon;
    final label = cfg.label;
    final iconColor = cfg.color;
    final bgColor = cfg.bg;
    final dateTime = DateTime.tryParse(e.createdAt);
    final time = dateTime != null
        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : null;

    return Container(
          padding: EdgeInsets.symmetric(
            horizontal: S.scale(context, 16),
            vertical: S.scale(context, 10),
          ),
          decoration: BoxDecoration(
            color: t.bgSurface2.withValues(alpha: 102/255),
            borderRadius: BorderRadius.circular(S.scale(context, 12)),
            border: Border.all(color: t.textPrimary.withAlpha(25)),
          ),
          child: Row(
            children: [
              Container(
                width: S.scale(context, 36),
                height: S.scale(context, 36),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(S.scale(context, 12)),
                  border: Border.all(color: iconColor.withValues(alpha: 76/255)),
                ),
                child: ExcludeSemantics(child: Icon(icon, color: iconColor, size: S.scale(context, 18))),
              ),
              SizedBox(width: S.scale(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 14),
                        ),
                      ),
                    ),
                    if (time != null)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          time,
                          style: GoogleFonts.nunito(
                            color: t.mutedText.withValues(alpha: 128/255),
                            fontSize: S.font(context, 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.scale(context, 10),
                  vertical: S.scale(context, 2),
                ),
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 25/255),
                  borderRadius: BorderRadius.circular(S.scale(context, 50)),
                  border: Border.all(
                    color: t.warning.withValues(alpha: 102/255),
                    width: S.scale(context, 2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.bolt_rounded,
                        color: t.warning,
                        size: S.scale(context, 14),
                      ),
                    ),
                    SizedBox(width: S.scale(context, 3)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '+${formatNumber(e.earnedXp)}',
                        style: GoogleFonts.nunito(
                          color: t.warning,
                          fontWeight: FontWeight.w800,
                          fontSize: S.font(context, 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: totalIdx * 30))
        .slideX(begin: 0.05);
  }

  Widget _emptyState(BloomTheme t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: S.scale(context, 32)),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.bolt_rounded,
              size: S.scale(context, 48),
              color: t.mutedText,
            ),
          ),
          SizedBox(height: S.scale(context, 12)),
          Text(
            'Belum ada XP yang dikumpulkan',
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: S.font(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: S.scale(context, 4)),
          Text(
            'Selesaikan quiz atau pelajaran untuk mendapat XP',
            style: GoogleFonts.nunito(
              color: t.mutedText,
              fontSize: S.font(context, 12),
            ),
          ),
        ],
      ),
    );
  }
}