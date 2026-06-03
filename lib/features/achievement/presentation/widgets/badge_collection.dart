import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/themes/theme_provider.dart';

import '../../data/models/achievement_model.dart';
import '../utils/date_utils.dart';
import 'achievement_skeletons.dart';
import 'section_header.dart';

class BadgeCollection extends ConsumerStatefulWidget {
  final BloomTheme t;
  final AsyncValue<List<BadgeModel>> badgesAsync;
  const BadgeCollection({
    super.key,
    required this.t,
    required this.badgesAsync,
  });

  @override
  ConsumerState<BadgeCollection> createState() => _BadgeCollectionState();
}

class _BadgeCollectionState extends ConsumerState<BadgeCollection> {
  String _activeTab = 'all';

  static const _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const _conditionIcons = {
    'streak': Icons.local_fire_department_rounded,
    'xp': Icons.bolt_rounded,
    'lesson_completion': Icons.menu_book_rounded,
    'event': Icons.event_rounded,
  };

  static const _conditionLabels = {
    'streak': 'Streak',
    'xp': 'XP',
    'lesson_completion': 'Pelajaran',
    'event': 'Event',
  };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    return '${d.day} ${monthsId[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return widget.badgesAsync.when(
      loading: () => BadgeGridSkeleton(t: t),
      error: (e, _) => const SizedBox.shrink(),
      data: (badges) {
        if (badges.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                t: t,
                title: 'Koleksi Badge',
                icon: Icons.workspace_premium_rounded,
              ),
              SizedBox(height: S.scale(context, 12)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(S.scale(context, 24)),
                decoration: BoxDecoration(
                  color: t.bgSurface2,
                  borderRadius: BorderRadius.circular(S.scale(context, 16)),
                  border: Border.all(
                    color: t.textPrimary,
                    width: S.scale(context, 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: t.textPrimary,
                      offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '🏅',
                          style: TextStyle(fontSize: S.font(context, 36)),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 8)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Belum ada badge',
                          style: GoogleFonts.nunito(
                            color: t.textSecondary,
                            fontSize: S.font(context, 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        final earnedCount = badges.where((b) => b.isEarned).length;
        final lockedCount = badges.length - earnedCount;

        final filtered = badges.where((b) {
          if (_activeTab == 'earned') return b.isEarned;
          if (_activeTab == 'locked') return !b.isEarned;
          return true;
        }).toList();

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
                offset: Offset(S.scale(context, 3), S.scale(context, 3)),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                t: t,
                title: 'Koleksi Badge',
                icon: Icons.workspace_premium_rounded,
                count: '$earnedCount/${badges.length}',
              ),
              SizedBox(height: S.scale(context, 12)),
              SizedBox(
                height: S.scale(context, 34),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterTab(
                      label: 'Semua',
                      count: badges.length,
                      isActive: _activeTab == 'all',
                      onTap: () {
                        setState(() => _activeTab = 'all');
                      },
                      t: t,
                    ),
                    SizedBox(width: S.scale(context, 8)),
                    FilterTab(
                      label: 'Diraih',
                      count: earnedCount,
                      isActive: _activeTab == 'earned',
                      onTap: () {
                        setState(() => _activeTab = 'earned');
                      },
                      t: t,
                    ),
                    SizedBox(width: S.scale(context, 8)),
                    FilterTab(
                      label: 'Terkunci',
                      count: lockedCount,
                      isActive: _activeTab == 'locked',
                      onTap: () {
                        setState(() => _activeTab = 'locked');
                      },
                      t: t,
                    ),
                  ],
                ),
              ),
              SizedBox(height: S.scale(context, 12)),
              Container(
                height: S.scale(context, 2),
                decoration: BoxDecoration(
                  color: t.textPrimary.withValues(alpha: 80 / 255),
                  boxShadow: [
                    BoxShadow(
                      color: t.textPrimary,
                      offset: Offset(S.scale(context, 0), S.scale(context, 1)),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: S.scale(context, 12)),
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: S.scale(context, 32)),
                  decoration: BoxDecoration(
                    color: t.bgSurface2,
                    borderRadius: BorderRadius.circular(S.scale(context, 16)),
                    border: Border.all(
                      color: t.border,
                      width: S.scale(context, 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ExcludeSemantics(
                          child: Icon(
                            Icons.emoji_events_outlined,
                            size: S.scale(context, 40),
                            color: t.textHint,
                          ),
                        ),
                      ),
                      SizedBox(height: S.scale(context, 8)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _activeTab == 'earned'
                              ? 'Belum ada badge yang diraih'
                              : 'Semua badge sudah diraih!',
                          style: GoogleFonts.nunito(
                            color: t.textSecondary,
                            fontSize: S.font(context, 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        final crossAxisCount = constraints.maxWidth > 800
                            ? 5
                            : constraints.maxWidth > 600
                            ? 4
                            : constraints.maxWidth > 400
                            ? 3
                            : 2;
                        final spacing = S.scale(context, 12);
                        final rowCount =
                            (filtered.length + crossAxisCount - 1) ~/
                            crossAxisCount;

                        return Column(
                          children: List.generate(rowCount, (rowIndex) {
                            final start = rowIndex * crossAxisCount;
                            final end = (start + crossAxisCount).clamp(
                              0,
                              filtered.length,
                            );
                            final rowItems = filtered.sublist(start, end);

                            final hasAnyDesc = rowItems.any(
                              (b) =>
                                  b.description != null &&
                                  b.description!.isNotEmpty,
                            );
                            final hasAnyCondition = rowItems.any(
                              (b) =>
                                  _conditionIcons[b.conditionType] != null &&
                                  b.conditionValue != null,
                            );
                            final hasAnyReward = rowItems.any(
                              (b) => b.rewardJewels > 0,
                            );
                            final hasAnyDate = rowItems.any(
                              (b) => b.isEarned && b.earnedAt != null,
                            );

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: rowIndex < rowCount - 1 ? spacing : 0,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (
                                      int i = 0;
                                      i < rowItems.length;
                                      i++
                                    ) ...[
                                      if (i > 0) SizedBox(width: spacing),
                                      Expanded(
                                        child: _buildBadgeCard(
                                          t,
                                          rowItems[i],
                                          hasAnyDesc: hasAnyDesc,
                                          hasAnyCondition: hasAnyCondition,
                                          hasAnyReward: hasAnyReward,
                                          hasAnyDate: hasAnyDate,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(
    BloomTheme t,
    BadgeModel b, {
    required bool hasAnyDesc,
    required bool hasAnyCondition,
    required bool hasAnyReward,
    required bool hasAnyDate,
  }) {
    final earned = b.isEarned;
    final condIcon = _conditionIcons[b.conditionType];
    final condLabel = _conditionLabels[b.conditionType];

    final cardBody = Container(
      padding: EdgeInsets.all(S.scale(context, 16)),
      decoration: BoxDecoration(
        color: earned ? t.bgSurface : t.bgSurface2.withValues(alpha: 180 / 255),
        borderRadius: BorderRadius.circular(S.scale(context, 16)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: S.scale(context, 4)),
          SizedBox(
            height: S.scale(context, 56),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: S.scale(context, 56),
                height: S.scale(context, 56),
                decoration: BoxDecoration(
                  color: earned
                      ? t.warning.withValues(alpha: 25 / 255)
                      : t.bgSurface3,
                  borderRadius: BorderRadius.circular(S.scale(context, 16)),
                  border: Border.all(
                    color: t.textPrimary,
                    width: S.scale(context, 2),
                  ),
                ),
                child: Semantics(
                  label:
                      '${b.name} - ${earned ? "Sudah didapat" : "Belum didapat"}',
                  child: Center(
                    child: b.icon.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: b.icon,
                            width: S.scale(context, 36),
                            height: S.scale(context, 36),
                            fit: BoxFit.contain,
                            placeholder: (_, __) => ExcludeSemantics(
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: S.scale(context, 24),
                                color: earned ? t.warning : t.textHint,
                              ),
                            ),
                            errorWidget: (_, __, ___) => ExcludeSemantics(
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: S.scale(context, 24),
                                color: earned ? t.warning : t.textHint,
                              ),
                            ),
                          )
                        : Text(
                            b.icon,
                            style: TextStyle(fontSize: S.font(context, 24)),
                          ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: S.scale(context, 10)),
          SizedBox(
            height: S.scale(context, 36),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                b.name,
                style: GoogleFonts.nunito(
                  fontSize: S.font(context, 14),
                  fontWeight: FontWeight.w800,
                  color: earned ? t.textPrimary : t.textHint,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (hasAnyDesc) ...[
            SizedBox(height: S.scale(context, 4)),
            SizedBox(
              height: S.scale(context, 26),
              child: Align(
                alignment: Alignment.topCenter,
                child: b.description != null && b.description!.isNotEmpty
                    ? Text(
                        b.description!,
                        style: GoogleFonts.nunito(
                          fontSize: S.font(context, 11),
                          color: t.textHint,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
              ),
            ),
          ],
          if (hasAnyCondition || hasAnyReward || hasAnyDate)
            SizedBox(height: S.scale(context, 10)),
          if (hasAnyCondition)
            SizedBox(
              height: S.scale(context, 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: condIcon != null && b.conditionValue != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: S.scale(context, 6),
                          vertical: S.scale(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: t.bgSurface2,
                          borderRadius: BorderRadius.circular(
                            S.scale(context, 50),
                          ),
                          border: Border.all(
                            color: t.border.withValues(alpha: 50 / 255),
                            width: S.scale(context, 1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                condIcon,
                                size: S.scale(context, 10),
                                color: t.textSecondary,
                              ),
                            ),
                            SizedBox(width: S.scale(context, 3)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$condLabel: ${b.conditionValue}',
                                style: GoogleFonts.nunito(
                                  fontSize: S.font(context, 10),
                                  color: t.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          if (hasAnyReward || hasAnyDate)
            SizedBox(height: S.scale(context, 10)),
          if (hasAnyReward)
            SizedBox(
              height: S.scale(context, 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: b.rewardJewels > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              Icons.diamond_rounded,
                              size: S.scale(context, 10),
                              color: t.info,
                            ),
                          ),
                          SizedBox(width: S.scale(context, 2)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '+${b.rewardJewels} jewels',
                              style: GoogleFonts.nunito(
                                fontSize: S.font(context, 11),
                                color: t.info,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          if (hasAnyDate) SizedBox(height: S.scale(context, 10)),
          if (hasAnyDate)
            SizedBox(
              height: S.scale(context, 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: earned && b.earnedAt != null
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Diraih ${_formatDate(b.earnedAt)}',
                          style: GoogleFonts.nunito(
                            fontSize: S.font(context, 10),
                            color: t.textHint,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          const Spacer(),
        ],
      ),
    );

    final statusIconWidget = Container(
      width: S.scale(context, 24),
      height: S.scale(context, 24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? t.success : t.bgSurface3,
        border: Border.all(color: t.border, width: S.scale(context, 2)),
        boxShadow: [
          BoxShadow(
            color: t.border,
            offset: Offset(S.scale(context, 1), S.scale(context, 1)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: earned
            ? ExcludeSemantics(
                child: Icon(
                  Icons.check_rounded,
                  color: t.accentText,
                  size: S.scale(context, 16),
                ),
              )
            : ExcludeSemantics(
                child: Icon(
                  Icons.lock_rounded,
                  color: t.textHint,
                  size: S.scale(context, 16),
                ),
              ),
      ),
    );

    final wrapped = Stack(
      clipBehavior: Clip.none,
      children: [
        cardBody,
        Positioned(
          top: -S.scale(context, 8),
          right: -S.scale(context, 8),
          child: statusIconWidget,
        ),
      ],
    );

    if (!earned) {
      return Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
          child: wrapped,
        ),
      );
    }
    return wrapped;
  }
}

class FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final BloomTheme t;

  const FilterTab({
    super.key,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Bounceable(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 14),
        vertical: S.scale(context, 6),
      ),
      decoration: BoxDecoration(
        color: isActive ? t.accent : t.bgSurface,
        borderRadius: BorderRadius.circular(S.scale(context, 50)),
        border: Border.all(color: t.textPrimary, width: S.scale(context, 2)),
        boxShadow: [
          BoxShadow(
            color: t.textPrimary,
            offset: Offset(S.scale(context, 3), S.scale(context, 3)),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                color: isActive ? t.accentText : t.textPrimary,
                fontSize: S.font(context, 13),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: S.scale(context, 6)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: S.scale(context, 6),
              vertical: S.scale(context, 1),
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? t.accentText.withValues(alpha: 30 / 255)
                  : t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 50)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: GoogleFonts.nunito(
                  color: isActive ? t.accentText : t.textSecondary,
                  fontSize: S.font(context, 10),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}