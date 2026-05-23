import 'dart:convert';
import 'gamification_models.dart';

class QuizRefModel {
  final String id;
  final String title;
  final String? lessonId;
  final bool isPassed;
  final bool isLocked;

  const QuizRefModel({
    required this.id,
    required this.title,
    this.lessonId,
    this.isPassed = false,
    this.isLocked = true,
  });

  factory QuizRefModel.fromJson(Map<String, dynamic> j) => QuizRefModel(
    id       : j['id']?.toString() ?? '',
    title    : j['title'] ?? j['name'] ?? 'Kuis',
    lessonId : (j['lesson_id'] ?? j['lessonId'])?.toString(),
    isPassed : j['is_passed'] ?? j['isPassed'] ?? j['passed'] ?? false,
    isLocked : j['is_locked'] ?? j['isLocked'] ?? j['locked'] ?? true,
  );
}

class UnitModel {
  final String id;
  final String title;
  final int order;
  final List<LessonModel> lessons;
  final List<QuizRefModel> quizzes;

  const UnitModel({
    required this.id,
    required this.title,
    required this.order,
    this.lessons = const [],
    this.quizzes = const [],
  });

  factory UnitModel.fromJson(Map<String, dynamic> j) => UnitModel(
    id      : j['id']?.toString() ?? '',
    title   : j['name'] ?? j['title'] ?? '',
    order   : (j['sequence'] ?? j['order'] ?? j['position'] ?? 0) as int,
    lessons : (j['lessons'] as List? ?? [])
        .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    quizzes : (j['quizzes'] as List? ?? [])
        .map((e) => QuizRefModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class LessonModel {
  final String id;
  final String title;
  final String type;
  final String? content;
  final int order;
  final bool isCompleted;
  final bool isLocked;

  const LessonModel({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    required this.order,
    this.isCompleted = false,
    this.isLocked    = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> j) => LessonModel(
    id         : j['id']?.toString() ?? '',
    title      : j['title'] ?? j['name'] ?? '',
    type       : j['type'] ?? 'text',
    content    : j['content'] == null
                   ? null
                   : j['content'] is String
                       ? j['content'] as String
                       : jsonEncode(j['content']),
    order      : (j['sequence'] ?? j['order'] ?? j['position'] ?? 0) as int,
    isCompleted: j['is_completed'] ?? j['isCompleted'] ?? j['completed'] ?? false,
    isLocked   : j['is_locked'] ?? j['isLocked'] ?? j['locked'] ?? false,
  );
}

class LessonCompleteResponse {
  final int xpEarned;
  final int jewelsEarned;
  final bool alreadyCompleted;
  final StreakInfo? streak;
  final LevelUpInfo? levelUp;
  final List<BadgeInfo> badgesAwarded;

  const LessonCompleteResponse({
    required this.xpEarned,
    required this.jewelsEarned,
    required this.alreadyCompleted,
    this.streak,
    this.levelUp,
    this.badgesAwarded = const [],
  });

  factory LessonCompleteResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return LessonCompleteResponse(
      xpEarned         : (d['xp_earned'] ?? d['xpEarned'] ?? 0) as int,
      jewelsEarned     : (d['jewels_earned'] ?? d['jewelsEarned'] ?? 0) as int,
      alreadyCompleted : d['already_completed'] ?? d['alreadyCompleted'] ?? false,
      streak           : d['streak'] != null ? StreakInfo.fromJson(d['streak']) : null,
      levelUp          : d['level_up'] != null ? LevelUpInfo.fromJson(d['level_up']) : null,
      badgesAwarded    : (d['badges_awarded'] as List? ?? [])
          .map((b) => BadgeInfo.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}


