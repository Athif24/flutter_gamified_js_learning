import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../shared/themes/theme_provider.dart';
import '../../data/models/leaderboard_model.dart';
import 'leaderboard_helpers.dart';

class Podium extends StatelessWidget {
  final BloomTheme t;
  final List<LeaderboardEntry> entries;
  const Podium({
    super.key,
    required this.t,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();
    return Semantics(
      label: 'Top 3 pemain terbaik',
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: S.scale(context, 22), color: t.warning),
              SizedBox(width: S.scale(context, 8)),
              Text(
                'Top 3 Pemain Terbaik',
                style: GoogleFonts.nunito(
                  color: t.textPrimary,
                  fontSize: S.font(context, 16),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PodiumUser(
                  entry: entries[1],
                  rank: 2,
                  t: t,
                  baseH: S.scale(context, 48),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              Expanded(
                child: PodiumUser(
                  entry: entries[0],
                  rank: 1,
                  t: t,
                  baseH: S.scale(context, 80),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              Expanded(
                child: PodiumUser(
                  entry: entries[2],
                  rank: 3,
                  t: t,
                  baseH: S.scale(context, 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PodiumUser extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final BloomTheme t;
  final double baseH;
  const PodiumUser({
    super.key,
    required this.entry,
    required this.rank,
    required this.t,
    required this.baseH,
  });

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8);
    return const Color(0xFFCD7F32);
  }

  String _initial() =>
      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Column(
    children: [
      if (rank == 1)
        Icon(Icons.emoji_events_rounded, size: S.scale(context, 28), color: t.warning),
      if (rank == 2)
        Icon(Icons.emoji_events_rounded, size: S.scale(context, 24), color: t.info),
      if (rank == 3)
        Icon(Icons.emoji_events_rounded, size: S.scale(context, 24), color: t.accent),
      SizedBox(height: S.scale(context, 8)),
      Container(
            width: rank == 1 ? S.scale(context, 56) : S.scale(context, 44),
            height: rank == 1 ? S.scale(context, 56) : S.scale(context, 44),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _color,
                width: S.scale(context, rank == 1 ? 3 : 2),
              ),
              color: _color.withValues(alpha: 0.2),
            ),
            child: Center(
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        S.scale(context, 50),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: entry.avatar!,
                        width: rank == 1 ? S.scale(context, 50) : S.scale(context, 38),
                        height: rank == 1 ? S.scale(context, 50) : S.scale(context, 38),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? S.font(context, 20) : S.font(context, 16),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Text(
                          _initial(),
                          style: GoogleFonts.nunito(
                            color: _color,
                            fontWeight: FontWeight.w900,
                            fontSize: rank == 1 ? S.font(context, 20) : S.font(context, 16),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _initial(),
                      style: GoogleFonts.nunito(
                        color: _color,
                        fontWeight: FontWeight.w900,
                        fontSize: rank == 1 ? S.font(context, 20) : S.font(context, 16),
                      ),
                    ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -4, duration: 1200.ms),
      SizedBox(height: S.scale(context, 8)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          entry.name,
          style: GoogleFonts.nunito(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: rank == 1 ? S.font(context, 12) : S.font(context, 11),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: S.scale(context, 2)),
      Text(
        '#${entry.rank}',
        style: GoogleFonts.nunito(
          color: _color,
          fontWeight: FontWeight.w800,
          fontSize: S.font(context, 11),
        ),
      ),
      SizedBox(height: S.scale(context, 4)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${fmtCompact(entry.xpTotal)} XP',
          style: GoogleFonts.nunito(
            color: t.mutedText,
            fontWeight: FontWeight.w700,
            fontSize: S.font(context, 10),
          ),
        ),
      ),
      if (entry.levelName != null)
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            entry.levelName!,
            style: GoogleFonts.nunito(
              color: t.mutedText.withValues(alpha: 0.7),
              fontSize: S.font(context, 9),
            ),
          ),
        ),
      SizedBox(height: S.scale(context, 4)),
      Container(
        height: baseH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color, _color.withValues(alpha: 0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(S.scale(context, 12)),
          ),
          border: Border.all(
            color: _color,
            width: S.scale(context, 3),
          ),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: GoogleFonts.nunito(
              color: rank == 1
                  ? const Color(0xFF78350F)
                  : rank == 2
                  ? const Color(0xFF475569)
                  : const Color(0xFF7C2D12),
              fontWeight: FontWeight.w900,
              fontSize: rank == 1 ? S.font(context, 28) : S.font(context, 22),
            ),
          ),
        ),
      ),
    ],
  );
  }
}
