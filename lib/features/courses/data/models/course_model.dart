import 'dart:convert';

class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final int totalLessons;
  final int completedLessons;
  final bool isEnrolled;
  final bool isPublished;
  final double progress;
  final bool isCompleted;
  final String? lastAccessedLessonTitle;
  final String? lastAccessedUnitTitle;
  final List<UnitModel> units;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.totalLessons    = 0,
    this.completedLessons = 0,
    this.isEnrolled      = false,
    this.isPublished     = true,
    this.progress        = 0.0,
    this.isCompleted     = false,
    this.lastAccessedLessonTitle,
    this.lastAccessedUnitTitle,
    this.units           = const [],
  });

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    int? totalLessons,
    int? completedLessons,
    bool? isEnrolled,
    bool? isPublished,
    double? progress,
    bool? isCompleted,
    String? lastAccessedLessonTitle,
    String? lastAccessedUnitTitle,
    List<UnitModel>? units,
  }) => CourseModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    thumbnail: thumbnail ?? this.thumbnail,
    totalLessons: totalLessons ?? this.totalLessons,
    completedLessons: completedLessons ?? this.completedLessons,
    isEnrolled: isEnrolled ?? this.isEnrolled,
    isPublished: isPublished ?? this.isPublished,
    progress: progress ?? this.progress,
    isCompleted: isCompleted ?? this.isCompleted,
    lastAccessedLessonTitle: lastAccessedLessonTitle ?? this.lastAccessedLessonTitle,
    lastAccessedUnitTitle: lastAccessedUnitTitle ?? this.lastAccessedUnitTitle,
    units: units ?? this.units,
  );

  factory CourseModel.fromJson(Map<String, dynamic> j) {
    final rawUnits = (j['units'] as List? ?? []);
    int completedFromUnits = 0;
    int totalFromUnits = 0;
    for (final u in rawUnits) {
      final lessons = (u as Map)['lessons'] as List? ?? [];
      totalFromUnits += lessons.length;
      for (final l in lessons) {
        if ((l as Map)['is_completed'] == true || l['isCompleted'] == true) {
          completedFromUnits++;
        }
      }
    }

    return CourseModel(
      id               : j['id']?.toString() ?? '',
      title            : j['name'] ?? j['title'] ?? '',
      description      : j['description'],
      thumbnail        : j['thumbnail'] ?? j['imageUrl'],
      totalLessons     : (j['total_lessons'] ?? j['totalLessons'] ?? j['lessonsCount'] ?? totalFromUnits) as int,
      completedLessons : (j['completed_lessons'] ?? j['completedLessons'] ?? j['completedCount'] ?? completedFromUnits) as int,
      isEnrolled       : j['is_enrolled'] ?? j['isEnrolled'] ?? j['enrolled'] ?? false,
      isPublished      : j['is_published'] ?? j['isPublished'] ?? true,
      progress         : _parseDouble(j['progress']),
      isCompleted      : j['is_completed'] ?? j['isCompleted'] ?? false,
      lastAccessedLessonTitle: j['last_accessed_lesson_title'] ?? j['lastAccessedLessonTitle'],
      lastAccessedUnitTitle: j['last_accessed_unit_title'] ?? j['lastAccessedUnitTitle'],
      units            : rawUnits
          .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v > 1 ? v / 100.0 : v;
    if (v is int) return v > 1 ? v / 100.0 : v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
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

// ── Quiz Preview (GET /quizzes/:id) ───────────────────────────────────────────

class QuizPreviewModel {
  final String id;
  final String title;
  final String difficulty;
  final int totalQuestions;
  final int passingScore;
  final int xpReward;
  final int jewelReward;
  final int timeLimit;

  const QuizPreviewModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.totalQuestions,
    required this.passingScore,
    this.xpReward = 0,
    this.jewelReward = 0,
    this.timeLimit = 0,
  });

  factory QuizPreviewModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return QuizPreviewModel(
      id            : d['id']?.toString() ?? '',
      title         : d['title'] ?? d['name'] ?? 'Kuis',
      difficulty    : d['difficulty'] ?? 'medium',
      totalQuestions: (d['total_questions'] ?? d['totalQuestions'] ?? 0) as int,
      passingScore  : (d['passing_score'] ?? d['passingScore'] ?? 100) as int,
      xpReward      : (d['xp_reward'] ?? d['xpReward'] ?? 0) as int,
      jewelReward   : (d['jewel_reward'] ?? d['jewelReward'] ?? 0) as int,
      timeLimit     : (d['time_limit'] ?? d['timeLimit'] ?? 0) as int,
    );
  }
}

// ── My Quiz Result (GET /quizzes/:id/my-result) ───────────────────────────────

class MyQuizResultResponse {
  final bool attempted;
  final int percentageScore;
  final bool isPassed;

  const MyQuizResultResponse({
    required this.attempted,
    this.percentageScore = 0,
    this.isPassed = false,
  });

  factory MyQuizResultResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return MyQuizResultResponse(
      attempted      : d['attempted'] ?? false,
      percentageScore: (d['percentage_score'] ?? 0) as int,
      isPassed       : d['is_passed'] ?? d['isPassed'] ?? false,
    );
  }
}

// ── Quiz Detail (dari POST /quizzes/:id/start) ────────────────────────────────

class QuizDetailModel {
  final String id;
  final String title;
  final int timeLimit;
  final int passingScore;
  final List<QuestionModel> questions;
  final int userQuizId;

  const QuizDetailModel({
    required this.id,
    required this.title,
    required this.timeLimit,
    this.passingScore = 100,
    required this.questions,
    this.userQuizId = 0,
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
    final userQuiz = data['userQuiz'] ?? data['user_quiz'] ?? {};
    final userQuizId = int.tryParse(
      (userQuiz is Map ? userQuiz['id'] : null)?.toString() ?? '0'
    ) ?? 0;

    return QuizDetailModel(
      id           : quizInfo['id']?.toString() ?? '',
      title        : quizInfo['title'] ?? quizInfo['name'] ?? 'Kuis',
      timeLimit    : (quizInfo['time_limit'] ?? quizInfo['timeLimit'] ?? 0) as int,
      passingScore : (quizInfo['passing_score'] ?? quizInfo['passingScore'] ?? 100) as int,
      questions    : questions
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userQuizId   : userQuizId,
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
  final String? arrangeVariant;
  /// Options sebagai objek {id, text} — dipakai untuk submit jawaban dengan option id
  final List<QuizOption> optionObjects;
  final List<String> blocks;
  final int points;
  /// Test cases untuk coding questions
  final List<TestCaseModel> testCases;
  /// Kunci jawaban (format bergantung tipe soal)
  final dynamic answerKey;
  /// Code snippet untuk coding questions (konteks soal)
  final String? codeSnippet;
  /// Code template / kerangka kode untuk coding questions
  final String? codeTemplate;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.arrangeVariant,
    this.optionObjects = const [],
    this.blocks        = const [],
    this.points        = 10,
    this.testCases     = const [],
    this.answerKey,
    this.codeSnippet,
    this.codeTemplate,
  });

  /// Untuk kompatibilitas dengan UI yang butuh `List<String>`
  List<String> get options => optionObjects.map((o) => o.text).toList();

  factory QuestionModel.fromJson(Map<String, dynamic> j) {
    // question bisa berupa nested object {text, image, codeSnippet, codeTemplate, blocks} atau string langsung
    final questionField = j['question'];
    final String questionText;
    List<String> extractedBlocks = [];
    
    if (questionField is Map) {
      questionText = questionField['text'] as String? ?? '';
      
      // Extract blocks from question object (for complete_word, arrange, etc.)
      if (questionField['blocks'] != null) {
        extractedBlocks = List<String>.from(questionField['blocks']);
      } else {
        // Fallback: Generate blocks from codeTemplate or text with {{N}} placeholders
        final codeTemplate = questionField['codeTemplate'] as String?;
        final text = questionField['text'] as String? ?? '';
        final sourceText = codeTemplate ?? text;
        
        if (sourceText.contains('{{')) {
          final regex = RegExp(r'\{\{(\d+)\}\}');
          
          // parts will be: ["function ", "{{0}}", "( ", "{{1}}", " ) { ..."]
          // We need to convert to blocks: ["function ", "___", "( ", "___", " ) { ..."]
          extractedBlocks = [];
          int lastEnd =0;
          for (final match in regex.allMatches(sourceText)) {
            // Add text before match as block
            if (match.start > lastEnd) {
              extractedBlocks.add(sourceText.substring(lastEnd, match.start));
            }
            // Add blank placeholder
            extractedBlocks.add('___');
            lastEnd = match.end;
          }
          // Add remaining text
          if (lastEnd < sourceText.length) {
            extractedBlocks.add(sourceText.substring(lastEnd));
          }
        }
      }
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

    // Parse test cases untuk coding questions
    final rawTestCases = j['test_case'] as List? ?? [];
    final testCases = rawTestCases.map((tc) {
      if (tc is Map<String, dynamic>) {
        return TestCaseModel.fromJson(tc);
      }
      return const TestCaseModel(input: '', expectedOutput: '', isHidden: false);
    }).toList();

    // Use blocks from question object, fallback to root level
    final blocks = extractedBlocks.isNotEmpty 
        ? extractedBlocks 
        : List<String>.from(j['blocks'] ?? []);

    final codeSnippet = questionField is Map
        ? questionField['codeSnippet'] as String?
        : null;
    final codeTemplate = questionField is Map
        ? questionField['codeTemplate'] as String?
        : null;

    return QuestionModel(
      id           : j['id']?.toString() ?? '',
      text         : questionText,
      type         : j['type'] ?? 'choice',
      arrangeVariant: j['arrange_variant'] as String?,
      optionObjects: parsedOptions,
      blocks       : blocks,
      points       : (j['score_weight'] ?? j['points'] ?? 10) as int,
      testCases    : testCases,
      answerKey    : j['answer_key'],
      codeSnippet  : codeSnippet,
      codeTemplate : codeTemplate,
    );
  }
}

class TestCaseModel {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  const TestCaseModel({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  factory TestCaseModel.fromJson(Map<String, dynamic> j) => TestCaseModel(
    input          : j['input'] ?? '',
    expectedOutput : j['expectedOutput'] ?? j['expected_output'] ?? '',
    isHidden       : j['isHidden'] ?? j['is_hidden'] ?? false,
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

// ── Quiz Result ───────────────────────────────────────────────────────────────

class QuizResultModel {
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int xpEarned;
  final int jewelsEarned;
  final bool alreadyClaimed;
  final StreakInfo? streak;
  final LevelUpInfo? levelUp;
  final List<BadgeInfo> badgesAwarded;
  final List<QuestionResultModel> questionResults;

  const QuizResultModel({
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passed,
    required this.xpEarned,
    this.jewelsEarned = 0,
    this.alreadyClaimed = false,
    this.streak,
    this.levelUp,
    this.badgesAwarded = const [],
    this.questionResults = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return QuizResultModel(
      score          : (d['score'] ?? d['total_score'] ?? 0) as int,
      totalPoints    : (d['total_points'] ?? d['totalPoints'] ?? 100) as int,
      percentage     : (d['percentage'] ?? d['percentage_score'] ?? d['score'] ?? 0).toDouble(),
      passed         : d['passed'] ?? d['is_passed'] ?? d['isPassed'] ?? false,
      xpEarned       : (d['xp_earned'] ?? d['xpEarned'] ?? d['xp'] ?? d['earned_xp'] ?? 0) as int,
      jewelsEarned   : (d['jewels_earned'] ?? d['jewelsEarned'] ?? d['earned_jewels'] ?? 0) as int,
      alreadyClaimed : d['already_claimed'] ?? d['alreadyClaimed'] ?? false,
      streak         : d['streak'] != null ? StreakInfo.fromJson(d['streak']) : null,
      levelUp        : d['level_up'] != null ? LevelUpInfo.fromJson(d['level_up']) : null,
      badgesAwarded  : (d['badges_awarded'] as List? ?? [])
          .map((b) => BadgeInfo.fromJson(b as Map<String, dynamic>))
          .toList(),
      questionResults: (d['question_results'] as List? ?? [])
          .map((q) => QuestionResultModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionResultModel {
  final String questionId;
  final int score;
  final int maxScore;
  final bool isCorrect;
  final dynamic userAnswer;
  final dynamic correctAnswer;

  const QuestionResultModel({
    required this.questionId,
    required this.score,
    required this.maxScore,
    required this.isCorrect,
    this.userAnswer,
    this.correctAnswer,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> j) => QuestionResultModel(
    questionId  : j['question_id']?.toString() ?? '',
    score       : (j['score'] ?? 0) as int,
    maxScore    : (j['max_score'] ?? 0) as int,
    isCorrect   : j['is_correct'] ?? j['isCorrect'] ?? false,
    userAnswer  : j['user_answer'],
    correctAnswer: j['correct_answer'],
  );
}

// ── Submit Answer Response ───────────────────────────────────────────────

class SubmitAnswerResponse {
  final String userQuestionId;
  final int score;
  final int maxScore;
  final bool isCorrect;
  final String? feedback;
  final int? livesRemaining;
  final dynamic correctAnswer;

  const SubmitAnswerResponse({
    required this.userQuestionId,
    required this.score,
    required this.maxScore,
    required this.isCorrect,
    this.feedback,
    this.livesRemaining,
    this.correctAnswer,
  });

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    final userQuestion = d['user_question'] ?? {};
    return SubmitAnswerResponse(
      userQuestionId: (userQuestion['id'] ?? '').toString(),
      score: (d['score'] ?? 0) as int,
      maxScore: (d['max_score'] ?? d['maxScore'] ?? 0) as int,
      isCorrect: d['is_correct'] ?? d['isCorrect'] ?? false,
      feedback: d['feedback'] as String?,
      livesRemaining: d['lives_remaining'] ?? d['livesRemaining'],
      correctAnswer: d['correct_answer'] ?? d['correctAnswer'],
    );
  }
}