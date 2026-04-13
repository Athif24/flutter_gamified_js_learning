class XpModel {
  final int totalXp;
  final int level;
  final String levelTitle;
  final int xpToNextLevel;

  const XpModel({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpToNextLevel,
  });

  double get progress => xpToNextLevel > 0
      ? (totalXp / xpToNextLevel).clamp(0.0, 1.0) : 1.0;

  factory XpModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return XpModel(
      totalXp      : (d['totalXp'] ?? d['xp'] ?? d['amount'] ?? 0) as int,
      level        : (d['level'] ?? 1) as int,
      levelTitle   : d['levelTitle'] ?? d['level_title'] ?? 'Pemula',
      xpToNextLevel: (d['xpToNextLevel'] ?? d['nextLevelXp'] ?? 500) as int,
    );
  }
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return StreakModel(
      currentStreak   : (d['currentStreak'] ?? d['streak'] ?? 0) as int,
      longestStreak   : (d['longestStreak'] ?? d['bestStreak'] ?? 0) as int,
      lastActivityDate: d['lastActivityDate']?.toString(),
    );
  }
}

class BadgeModel {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String rarity;
  final bool isEarned;
  final String? earnedAt;
  final int? requiredValue;

  const BadgeModel({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.rarity,
    required this.isEarned,
    this.earnedAt,
    this.requiredValue,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> j) {
    final badge = j['badge'] ?? j;
    return BadgeModel(
      id            : (badge['id'] ?? j['id'] ?? '').toString(),
      name          : badge['name'] ?? j['name'] ?? '',
      description   : badge['description'] ?? j['description'],
      icon          : badge['icon'] ?? badge['imageUrl'] ?? j['icon'] ?? '🏅',
      rarity        : (badge['rarity'] ?? j['rarity'] ?? 'bronze').toString().toLowerCase(),
      isEarned      : j['isEarned'] ?? j['earned'] ?? badge['isEarned'] ?? false,
      earnedAt      : j['earnedAt'] ?? j['createdAt'],
      requiredValue : badge['requiredValue'] as int?,
    );
  }
}

class LearningReportModel {
  final int quizAttempts;
  final int quizPassed;
  final double averageScore;
  final double bestScore;
  final int lessonsCompleted;
  final int coursesCompleted;

  const LearningReportModel({
    required this.quizAttempts,
    required this.quizPassed,
    required this.averageScore,
    required this.bestScore,
    required this.lessonsCompleted,
    required this.coursesCompleted,
  });

  double get accuracy =>
      quizAttempts > 0 ? (quizPassed / quizAttempts) * 100 : 0;

  factory LearningReportModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return LearningReportModel(
      quizAttempts    : (d['quizAttempts']    ?? d['totalQuizAttempts'] ?? 0) as int,
      quizPassed      : (d['quizPassed']      ?? d['totalQuizPassed']   ?? 0) as int,
      averageScore    : (d['averageScore']    ?? d['avgScore']          ?? 0).toDouble(),
      bestScore       : (d['bestScore']       ?? d['highestScore']      ?? 0).toDouble(),
      lessonsCompleted: (d['lessonsCompleted']?? d['totalLessons']      ?? 0) as int,
      coursesCompleted: (d['coursesCompleted']?? d['totalCourses']      ?? 0) as int,
    );
  }
}