class LeaderboardEntry {
  final int rank;
  final int userId;
  final String name;
  final String? avatar;
  final int xpTotal;
  final String? levelName;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatar,
    required this.xpTotal,
    this.levelName,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
    rank     : (j['rank'] ?? 0) as int,
    userId   : (j['user_id'] ?? 0) as int,
    name     : j['name'] ?? '',
    avatar   : j['avatar']?.toString(),
    xpTotal  : (j['xp_total'] ?? 0) as int,
    levelName: j['level_name']?.toString(),
  );
}

class LeaderboardResponse {
  final List<LeaderboardEntry> leaderboard;
  final int? currentUserRank;
  final int? currentUserXp;

  const LeaderboardResponse({
    required this.leaderboard,
    this.currentUserRank,
    this.currentUserXp,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    final list = (d['leaderboard'] as List<dynamic>?)
        ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return LeaderboardResponse(
      leaderboard    : list,
      currentUserRank: d['current_user_rank'] as int?,
      currentUserXp  : d['current_user_xp'] as int?,
    );
  }
}
