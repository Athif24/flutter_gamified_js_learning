import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../data/models/leaderboard_model.dart';
import 'leaderboard_helpers.dart';
import 'leaderboard_rank_badge.dart';
import 'leaderboard_separator.dart';

class LeaderboardTable extends StatelessWidget {
  final BloomTheme t;
  final List<LeaderboardEntry> entries;
  final bool isSearchActive;
  final int? currentUserRank;
  final int topXp;
  const LeaderboardTable({
    super.key,
    required this.t,
    required this.entries,
    this.isSearchActive = false,
    this.currentUserRank,
    required this.topXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(S.scale(context, 16)),
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
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: S.scale(context, 28), color: t.warning),
              SizedBox(width: S.scale(context, 8)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: S.font(context, 20),
                    ),
                  ),
                  Text(
                    'Ranking pemain berdasarkan total XP',
                    style: GoogleFonts.nunito(
                      color: t.mutedText,
                      fontSize: S.font(context, 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          if (entries.isEmpty && !isSearchActive)
            Padding(
              padding: EdgeInsets.symmetric(vertical: S.scale(context, 32)),
              child: Text(
                'Belum ada data',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.font(context, 15),
                ),
              ),
            )
          else if (entries.isEmpty && isSearchActive)
            Padding(
              padding: EdgeInsets.symmetric(vertical: S.scale(context, 32)),
              child: Text(
                'Tidak ada pemain dengan nama tersebut',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontSize: S.font(context, 15),
                ),
              ),
            )
          else
            Column(
              children: [
                ...entries.take(5).map((e) => Padding(
                  padding: EdgeInsets.only(bottom: S.scale(context, 8)),
                  child: LeaderboardRow(
                    entry: e,
                    isCurrentUser: e.rank == currentUserRank,
                    t: t,
                  ),
                )),
                if (!isSearchActive && currentUserRank != null) ...[
                  SizedBox(height: S.scale(context, 8)),
                  Separator(t: t),
                  if (currentUserRank! > 5) ...[
                    SizedBox(height: S.scale(context, 8)),
                    if (entries.where((e) => e.rank == currentUserRank).firstOrNull case final userEntry?)
                      LeaderboardRow(
                        entry: userEntry,
                        isCurrentUser: true,
                        t: t,
                      ),
                  ],
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final BloomTheme t;
  const LeaderboardRow({
    super.key,
    required this.entry,
    required this.isCurrentUser,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: S.scale(context, 12),
        vertical: S.scale(context, 8),
      ),
      decoration: BoxDecoration(
        color: isCurrentUser ? t.accent.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(S.scale(context, 10)),
      ),
      child: Row(
        children: [
          RankBadgeSmall(rank: entry.rank, t: t),
          SizedBox(width: S.scale(context, 12)),
          Container(
            width: S.scale(context, 36),
            height: S.scale(context, 36),
            decoration: BoxDecoration(
              color: t.bgSurface2,
              borderRadius: BorderRadius.circular(S.scale(context, 8)),
              border: Border.all(
                color: t.textPrimary,
                width: S.scale(context, 1.5),
              ),
            ),
            child: Center(
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(S.scale(context, 7)),
                      child: CachedNetworkImage(
                        imageUrl: entry.avatar!,
                        width: S.scale(context, 32),
                        height: S.scale(context, 32),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Text(
                          entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: S.font(context, 12),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Text(
                          entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                          style: GoogleFonts.nunito(
                            color: t.mutedText,
                            fontWeight: FontWeight.w800,
                            fontSize: S.font(context, 12),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: GoogleFonts.nunito(
                        color: t.mutedText,
                        fontWeight: FontWeight.w800,
                        fontSize: S.font(context, 12),
                      ),
                    ),
            ),
          ),
          SizedBox(width: S.scale(context, 8)),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser ? 'Anda' : entry.name,
                    style: GoogleFonts.nunito(
                      color: isCurrentUser ? t.primary : t.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: S.font(context, 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: S.scale(context, 8)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${fmtCompact(entry.xpTotal)} XP',
              style: GoogleFonts.nunito(
                color: t.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: S.font(context, 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
