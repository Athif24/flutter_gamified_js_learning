import 'question_model.dart';
import 'gamification_models.dart';

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

class QuizAttemptModel {
  final bool inProgress;
  final List<int> answeredQuestionIds;

  const QuizAttemptModel({required this.inProgress, this.answeredQuestionIds = const []});

  factory QuizAttemptModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? j;
    return QuizAttemptModel(
      inProgress: d['in_progress'] ?? false,
      answeredQuestionIds: (d['answered_question_ids'] as List<dynamic>?)
          ?.map((e) => e as int).toList() ?? [],
    );
  }
}

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

class QuizDetailModel {
  final String id;
  final String title;
  final int timeLimit;
  final int passingScore;
  final List<QuestionModel> questions;
  final int userQuizId;
  final List<int> answeredQuestionIds;

  const QuizDetailModel({
    required this.id,
    required this.title,
    required this.timeLimit,
    this.passingScore = 100,
    required this.questions,
    this.userQuizId = 0,
    this.answeredQuestionIds = const [],
  });

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

  factory QuizDetailModel.fromStartResponse(Map<String, dynamic> data) {
    final quizInfo  = data['quiz']  as Map<String, dynamic>? ?? {};
    final questions = data['questions'] as List? ?? [];
    final userQuiz = data['userQuiz'] ?? data['user_quiz'] ?? {};
    final userQuizId = int.tryParse(
      (userQuiz is Map ? userQuiz['id'] : null)?.toString() ?? '0'
    ) ?? 0;
    final answeredIds = (data['answered_question_ids'] as List?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .where((id) => id > 0)
            .toList() ??
        [];

    return QuizDetailModel(
      id           : quizInfo['id']?.toString() ?? '',
      title        : quizInfo['title'] ?? quizInfo['name'] ?? 'Kuis',
      timeLimit    : (quizInfo['time_limit'] ?? quizInfo['timeLimit'] ?? 0) as int,
      passingScore : (quizInfo['passing_score'] ?? quizInfo['passingScore'] ?? 100) as int,
      questions    : questions
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userQuizId   : userQuizId,
      answeredQuestionIds: answeredIds,
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

class QuizResultModel {
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int xpEarned;
  final int jewelsEarned;
  final int passingScore;
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
    this.passingScore = 100,
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
      passingScore   : (d['passing_score'] ?? d['passingScore'] ?? 100) as int,
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
