import 'dart:convert';

class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final int level;
  final int totalLessons;
  final int completedLessons;
  final bool isEnrolled;
  final List<UnitModel> units;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.level,
    this.totalLessons    = 0,
    this.completedLessons = 0,
    this.isEnrolled      = false,
    this.units           = const [],
  });

  double get progress =>
      totalLessons > 0 ? completedLessons / totalLessons : 0;

  factory CourseModel.fromJson(Map<String, dynamic> j) => CourseModel(
    id               : j['id']?.toString() ?? '',
    title            : j['name'] ?? j['title'] ?? '',
    description      : j['description'],
    thumbnail        : j['thumbnail'] ?? j['imageUrl'],
    level            : (j['level'] ?? j['difficulty'] ?? 1) as int,
    totalLessons     : (j['total_lessons'] ?? j['totalLessons'] ?? j['lessonsCount'] ?? 0) as int,
    completedLessons : (j['completed_lessons'] ?? j['completedLessons'] ?? j['completedCount'] ?? 0) as int,
    isEnrolled       : j['is_enrolled'] ?? j['isEnrolled'] ?? j['enrolled'] ?? false,
    units            : (j['units'] as List? ?? [])
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList(),
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
    // content bisa berupa Map (ProseMirror JSON) atau String
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

// ── Quiz Detail ───────────────────────────────────────────────────────────────

class QuizDetailModel {
  final String id;
  final String title;
  final int timeLimit;
  final int passingScore;
  final List<QuestionModel> questions;

  const QuizDetailModel({
    required this.id,
    required this.title,
    required this.timeLimit,
    this.passingScore = 100,
    required this.questions,
  });

  /// Parse dari response GET /quizzes/:id (tanpa questions)
  factory QuizDetailModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return QuizDetailModel(
      id           : d['id']?.toString() ?? '',
      title        : d['title'] ?? d['name'] ?? 'Kuis',
      timeLimit    : (d['time_limit'] ?? d['timeLimit'] ?? d['timeLimitMinutes'] ?? 0) as int,
      passingScore : (d['passing_score'] ?? d['passingScore'] ?? 100) as int,
      questions    : (d['questions'] as List? ?? [])
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parse dari response POST /quizzes/:id/start
  /// Questions ada di data.questions, quiz info ada di data.quiz
  factory QuizDetailModel.fromStartResponse(Map<String, dynamic> data) {
    final quizInfo  = data['quiz']  as Map<String, dynamic>? ?? {};
    final questions = data['questions'] as List? ?? [];

    return QuizDetailModel(
      id           : quizInfo['id']?.toString() ?? '',
      title        : quizInfo['title'] ?? quizInfo['name'] ?? 'Kuis',
      timeLimit    : (quizInfo['time_limit'] ?? quizInfo['timeLimit'] ?? 0) as int,
      passingScore : (quizInfo['passing_score'] ?? quizInfo['passingScore'] ?? 100) as int,
      questions    : questions
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Question Model ────────────────────────────────────────────────────────────

class QuizOption {
  final String id;
  final String text;

  const QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> j) => QuizOption(
    id  : j['id']?.toString() ?? '',
    text: j['text'] ?? '',
  );
}

class QuestionModel {
  final String id;
  final String text;
  final String type;
  /// Options sebagai objek {id, text} — dipakai untuk submit jawaban dengan option id
  final List<QuizOption> optionObjects;
  final List<String> blocks;
  final int points;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.optionObjects = const [],
    this.blocks        = const [],
    this.points        = 10,
  });

  /// Untuk kompatibilitas dengan UI yang butuh List<String>
  List<String> get options => optionObjects.map((o) => o.text).toList();

  factory QuestionModel.fromJson(Map<String, dynamic> j) {
    // question bisa berupa nested object {text, image, codeSnippet} atau string langsung
    final questionField = j['question'];
    final String questionText;
    if (questionField is Map) {
      questionText = questionField['text'] as String? ?? '';
    } else {
      questionText = questionField as String? ?? j['text'] as String? ?? '';
    }

    // options bisa berupa List<{id,text}> atau List<String>
    final rawOptions = j['options'] as List? ?? [];
    final List<QuizOption> parsedOptions = rawOptions.map((o) {
      if (o is Map<String, dynamic>) {
        return QuizOption.fromJson(o);
      } else {
        // Fallback jika options berupa string langsung
        return QuizOption(id: o.toString(), text: o.toString());
      }
    }).toList();

    return QuestionModel(
      id           : j['id']?.toString() ?? '',
      text         : questionText,
      type         : j['type'] ?? 'choice',
      optionObjects: parsedOptions,
      blocks       : List<String>.from(j['blocks'] ?? []),
      points       : (j['score_weight'] ?? j['points'] ?? 10) as int,
    );
  }
}

// ── Quiz Result ───────────────────────────────────────────────────────────────

class QuizResultModel {
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int xpEarned;

  const QuizResultModel({
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passed,
    required this.xpEarned,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return QuizResultModel(
      score      : (d['score'] ?? d['total_score'] ?? 0) as int,
      totalPoints: (d['total_points'] ?? d['totalPoints'] ?? 100) as int,
      percentage : (d['percentage'] ?? d['score'] ?? 0).toDouble(),
      passed     : d['passed'] ?? d['is_passed'] ?? d['isPassed'] ?? false,
      xpEarned   : (d['xp_earned'] ?? d['xpEarned'] ?? d['xp'] ?? 0) as int,
    );
  }
}