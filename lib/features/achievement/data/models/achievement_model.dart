class XpModel {
  final int totalXp;
  final int level;
  final String levelTitle;
  final int xpToNextLevel;
  final int jewels;
  final String? nextLevelTitle;
  final int currentLevelRequiredXp;

  const XpModel({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpToNextLevel,
    this.jewels = 0,
    this.nextLevelTitle,
    this.currentLevelRequiredXp = 0,
  });

  double get progress {
    final xpInThisLevel = totalXp - currentLevelRequiredXp;
    final xpNeededForLevel = xpToNextLevel + xpInThisLevel;
    return xpNeededForLevel > 0
        ? (xpInThisLevel / xpNeededForLevel).clamp(0.0, 1.0)
        : 1.0;
  }
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final bool freezeActive;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.freezeActive = false,
  });

  factory StreakModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return StreakModel(
      currentStreak:
          (d['current_streak'] ?? d['currentStreak'] ?? d['streak'] ?? 0)
              as int,
      longestStreak:
          (d['longest_streak'] ?? d['longestStreak'] ?? d['bestStreak'] ?? 0)
              as int,
      lastActivityDate:
          d['last_activity_date']?.toString() ??
          d['lastActivityDate']?.toString(),
      freezeActive: d['freeze_active'] ?? d['freezeActive'] ?? false,
    );
  }
}

class BadgeModel {
  final String id;
  final String? badgeId;
  final String name;
  final String? description;
  final String icon;
  final bool isEarned;
  final String? earnedAt;
  final int rewardJewels;
  final String? conditionType;
  final String? conditionValue;

  const BadgeModel({
    required this.id,
    this.badgeId,
    required this.name,
    this.description,
    required this.icon,
    required this.isEarned,
    this.earnedAt,
    this.rewardJewels = 0,
    this.conditionType,
    this.conditionValue,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> j) {
    final outer = j;
    final badge = j['badge'] ?? j;
    return BadgeModel(
      id: (badge['id'] ?? j['id'] ?? '').toString(),
      badgeId: j['badge_id']?.toString(),
      name: badge['name'] ?? j['name'] ?? '',
      description: _parseDesc(badge['description'] ?? j['description']),
      icon: badge['icon'] ?? badge['imageUrl'] ?? j['icon'] ?? '🏅',
      isEarned:
          outer['isEarned'] ??
          outer['earned'] ??
          outer['badge'] != null ??
          false,
      earnedAt: outer['earned_at']?.toString() ?? outer['earnedAt']?.toString(),
      rewardJewels: (badge['reward_jewels'] ?? 0) as int,
      conditionType: badge['condition_type']?.toString(),
      conditionValue: badge['condition_value']?.toString(),
    );
  }
}

class XpHistoryEntry {
  final String id;
  final int earnedXp;
  final String sourceType;
  final String? sourceId;
  final String createdAt;

  const XpHistoryEntry({
    required this.id,
    required this.earnedXp,
    required this.sourceType,
    this.sourceId,
    required this.createdAt,
  });

  factory XpHistoryEntry.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return XpHistoryEntry(
      id: d['id']?.toString() ?? '',
      earnedXp:
          (d['xp_earned'] ?? d['earned_xp'] ?? d['earnedXp'] ?? d['xp'] ?? 0)
              as int,
      sourceType: d['source_type'] ?? d['sourceType'] ?? 'lesson',
      sourceId: d['source_id']?.toString(),
      createdAt:
          d['created_at']?.toString() ?? d['createdAt']?.toString() ?? '',
    );
  }
}

class LevelModel {
  final String id;
  final String name;
  final int requiredXp;
  final int rewardJewels;
  final String? description;

  const LevelModel({
    required this.id,
    required this.name,
    required this.requiredXp,
    this.rewardJewels = 0,
    this.description,
  });

  factory LevelModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return LevelModel(
      id: d['id']?.toString() ?? '',
      name: d['name'] ?? '',
      requiredXp: (d['required_xp'] ?? d['requiredXp'] ?? 0) as int,
      rewardJewels: (d['reward_jewels'] ?? d['rewardJewels'] ?? 0) as int,
      description: d['description'] as String?,
    );
  }
}

class LivesModel {
  final int current;
  final int max;
  final DateTime? lastLifeUpdate;
  final int? minutesUntilNextLife;
  final bool isUnlimited;

  const LivesModel({
    required this.current,
    required this.max,
    this.lastLifeUpdate,
    this.minutesUntilNextLife,
    this.isUnlimited = false,
  });

  factory LivesModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return LivesModel(
      current: (d['current'] ?? d['currentLives'] ?? d['lives'] ?? 0) as int,
      max: (d['max'] ?? d['maxLives'] ?? 5) as int,
      lastLifeUpdate: d['lastLifeUpdate'] != null
          ? DateTime.tryParse(d['lastLifeUpdate'].toString())
          : null,
      minutesUntilNextLife: d['minutesUntilNextLife'] as int?,
      isUnlimited: (d['isUnlimited'] ?? false) as bool,
    );
  }
}

String? _parseDesc(dynamic d) {
  if (d == null) return null;
  if (d is String) return d;
  if (d is Map<String, dynamic>) return d['text']?.toString();
  return d.toString();
}