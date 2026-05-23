class RecentXpEntry {
  final String id;
  final int xpEarned;
  final String sourceType;
  final String createdAt;

  const RecentXpEntry({
    required this.id,
    required this.xpEarned,
    required this.sourceType,
    required this.createdAt,
  });

  factory RecentXpEntry.fromJson(Map<String, dynamic> j) {
    return RecentXpEntry(
      id: (j['id'] ?? '').toString(),
      xpEarned: (j['xp_earned'] ?? 0) as int,
      sourceType: j['source_type']?.toString() ?? 'lesson',
      createdAt: j['created_at']?.toString() ?? '',
    );
  }
}

class CourseDetail {
  final int id;
  final String name;
  final double progress;
  final bool isCompleted;

  const CourseDetail({
    required this.id,
    required this.name,
    required this.progress,
    required this.isCompleted,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> j) {
    return CourseDetail(
      id: (j['id'] ?? 0) as int,
      name: j['name']?.toString() ?? '',
      progress: (j['progress'] ?? 0).toDouble(),
      isCompleted: j['is_completed'] == true,
    );
  }
}

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? role;
  final String? joinedAt;
  final int daysSinceJoined;

  final int lifes;
  final int maxLives;
  final int quizAttempts;
  final int quizPassed;
  final double avgScore;
  final double bestScore;
  final int lessonsCompleted;

  final int xpTotal;
  final int jewels;
  final int maxJewels;
  final int level;
  final String levelTitle;

  final int coursesEnrolled;
  final int coursesCompleted;
  final List<CourseDetail> courseDetails;

  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;

  final List<RecentXpEntry> recentXp;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role,
    this.joinedAt,
    this.daysSinceJoined = 0,
    this.lifes = 5,
    this.maxLives = 5,
    this.quizAttempts = 0,
    this.quizPassed = 0,
    this.avgScore = 0,
    this.bestScore = 0,
    this.lessonsCompleted = 0,
    this.xpTotal = 0,
    this.jewels = 0,
    this.maxJewels = 0,
    this.level = 1,
    this.levelTitle = 'Pemula',
    this.coursesEnrolled = 0,
    this.coursesCompleted = 0,
    this.courseDetails = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.recentXp = const [],
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    final u = d['user'] ?? d;
    final s = d['stats'] as Map<String, dynamic>?;
    final q = d['quiz_stats'] as Map<String, dynamic>?;
    final lvl = s?['level'] as Map<String, dynamic>?;
    final st = d['streak'] as Map<String, dynamic>?;
    final c = d['courses'] as Map<String, dynamic>?;
    final rx = d['recent_xp'] as List<dynamic>?;

    final joinedAtRaw =
        u['created_at']?.toString() ??
        u['createdAt']?.toString() ??
        u['joinedAt']?.toString();
    int daysSinceJoined = 0;
    if (joinedAtRaw != null) {
      final joined = DateTime.tryParse(joinedAtRaw);
      if (joined != null) {
        daysSinceJoined = DateTime.now().difference(joined).inDays;
      }
    }

    return ProfileModel(
      id: (u['id'] ?? '').toString(),
      name: u['name'] ?? u['username'] ?? '',
      email: u['email'] ?? '',
      avatar: u['avatar'] ?? u['profilePicture'],
      role: u['role']?.toString(),
      joinedAt: joinedAtRaw,
      daysSinceJoined: daysSinceJoined,
      lifes: (s?['lifes'] ?? 5) as int,
      maxLives: (s?['max_lives'] ?? 5) as int,
      quizAttempts: (q?['total_attempted'] ?? 0) as int,
      quizPassed: (q?['total_passed'] ?? 0) as int,
      avgScore: (q?['avg_score'] ?? 0).toDouble(),
      bestScore: (q?['best_score'] ?? 0).toDouble(),
      lessonsCompleted: (d['lessons_completed'] ?? 0) as int,
      xpTotal: (s?['xp_total'] ?? 0) as int,
      jewels: (s?['jewels'] ?? 0) as int,
      maxJewels: (s?['max_jewels'] ?? 0) as int,
      level: (lvl?['id'] ?? 1) as int,
      levelTitle: lvl?['name']?.toString() ?? 'Pemula',
      coursesEnrolled: (c?['enrolled'] ?? 0) as int,
      coursesCompleted: (c?['completed'] ?? 0) as int,
      courseDetails:
          (c?['details'] as List<dynamic>?)
              ?.map((e) => CourseDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentStreak: (st?['current_streak'] ?? 0) as int,
      longestStreak: (st?['longest_streak'] ?? 0) as int,
      lastActivityDate: st?['last_activity_date']?.toString(),
      recentXp: rx != null
          ? rx
                .map((e) => RecentXpEntry.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
    );
  }
}
