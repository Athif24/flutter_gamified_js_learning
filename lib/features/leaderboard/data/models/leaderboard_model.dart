class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String? avatar;
  final int xp;
  final String levelTitle;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatar,
    required this.xp,
    required this.levelTitle,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j, {int fallbackRank = 0}) {
    final user = j['user'] ?? j;
    return LeaderboardEntry(
      rank         : (j['rank'] ?? j['position'] ?? fallbackRank) as int,
      userId       : (user['id'] ?? j['userId'] ?? '').toString(),
      name         : user['name'] ?? user['username'] ?? j['name'] ?? 'User',
      avatar       : user['avatar'] ?? user['profilePicture'],
      xp           : (j['totalXp'] ?? j['xp'] ?? user['xp'] ?? 0) as int,
      levelTitle   : j['levelTitle'] ?? user['levelTitle'] ?? 'Pemula',
      isCurrentUser: j['isCurrentUser'] ?? j['isMe'] ?? false,
    );
  }
}