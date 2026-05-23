class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  const StreakInfo({required this.currentStreak, required this.longestStreak});
  factory StreakInfo.fromJson(Map<String, dynamic> j) => StreakInfo(
    currentStreak: (j['current_streak'] ?? j['currentStreak'] ?? 0) as int,
    longestStreak: (j['longest_streak'] ?? j['longestStreak'] ?? 0) as int,
  );
}

class LevelUpInfo {
  final bool leveledUp;
  final String? previousLevelName;
  final String? newLevelName;
  final int jewelsAwarded;
  const LevelUpInfo({
    required this.leveledUp,
    this.previousLevelName,
    this.newLevelName,
    this.jewelsAwarded = 0,
  });
  factory LevelUpInfo.fromJson(Map<String, dynamic> j) {
    final prev = j['previous_level'] as Map<String, dynamic>?;
    final next = j['new_level'] as Map<String, dynamic>?;
    return LevelUpInfo(
      leveledUp        : j['leveled_up'] ?? j['leveledUp'] ?? false,
      previousLevelName: prev?['name'] as String?,
      newLevelName     : next?['name'] as String?,
      jewelsAwarded    : (j['jewels_awarded'] ?? j['jewelsAwarded'] ?? 0) as int,
    );
  }
}

class BadgeInfo {
  final String id;
  final String name;
  final String? description;
  final int jewelsEarned;
  const BadgeInfo({
    required this.id,
    required this.name,
    this.description,
    this.jewelsEarned = 0,
  });
  factory BadgeInfo.fromJson(Map<String, dynamic> j) => BadgeInfo(
    id          : j['id']?.toString() ?? '',
    name        : j['name'] ?? '',
    description : j['description'] as String?,
    jewelsEarned: (j['jewels_earned'] ?? j['jewelsEarned'] ?? 0) as int,
  );
}
