import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/models/course_model.dart';

// ── Datasource provider ───────────────────────────────────────────────────────
final courseDsProvider = Provider((ref) =>
    CourseRemoteDatasource(ref.read(apiClientProvider)));

// ── Course list ───────────────────────────────────────────────────────────────
final coursesProvider = FutureProvider<List<CourseModel>>(
    (ref) => ref.read(courseDsProvider).getCourses());

// ── Course detail ─────────────────────────────────────────────────────────────
final courseDetailProvider =
    FutureProvider.family<CourseModel, String>(
        (ref, id) => ref.read(courseDsProvider).getCourseById(id));

// ── Lesson detail ─────────────────────────────────────────────────────────────
final lessonDetailProvider =
    FutureProvider.family<LessonModel, String>(
        (ref, id) => ref.read(courseDsProvider).getLessonById(id));

// ── Quiz detail ───────────────────────────────────────────────────────────────
final quizDetailProvider =
    FutureProvider.family<QuizDetailModel, String>(
        (ref, id) => ref.read(courseDsProvider).getQuizById(id));

// ── Quiz state ────────────────────────────────────────────────────────────────

class QuizState {
  final QuizDetailModel? quiz;
  final int currentIndex;
  /// answers: { questionId: optionId }
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final bool isFinished;
  final QuizResultModel? result;
  final String? error;
  final int? userQuizId;
  final Map<String, SubmitAnswerResponse> answerResults;
  final SubmitAnswerResponse? lastAnswerResult;
  final bool isSubmittingAnswer;

  const QuizState({
    this.quiz,
    this.currentIndex = 0,
    this.answers      = const {},
    this.isSubmitting = false,
    this.isFinished   = false,
    this.result,
    this.error,
    this.userQuizId,
    this.answerResults = const {},
    this.lastAnswerResult,
    this.isSubmittingAnswer = false,
  });

  QuestionModel? get current =>
      quiz != null && currentIndex < quiz!.questions.length
          ? quiz!.questions[currentIndex]
          : null;

  bool get isLast =>
      quiz != null && currentIndex >= quiz!.questions.length - 1;

  QuizState copyWith({
    QuizDetailModel? quiz,
    int? currentIndex,
    Map<String, dynamic>? answers,
    bool? isSubmitting,
    bool? isFinished,
    QuizResultModel? result,
    String? error,
    int? userQuizId,
    Map<String, SubmitAnswerResponse>? answerResults,
    SubmitAnswerResponse? lastAnswerResult,
    bool? isSubmittingAnswer,
    bool clearError = false,
    bool clearLastAnswer = false,
  }) => QuizState(
    quiz              : quiz               ?? this.quiz,
    currentIndex      : currentIndex       ?? this.currentIndex,
    answers           : answers            ?? this.answers,
    isSubmitting      : isSubmitting       ?? this.isSubmitting,
    isFinished        : isFinished         ?? this.isFinished,
    result            : result             ?? this.result,
    error             : clearError ? null : (error ?? this.error),
    userQuizId        : userQuizId         ?? this.userQuizId,
    answerResults     : answerResults      ?? this.answerResults,
    lastAnswerResult  : clearLastAnswer ? null : (lastAnswerResult ?? this.lastAnswerResult),
    isSubmittingAnswer: isSubmittingAnswer ?? this.isSubmittingAnswer,
  );
}

class QuizNotifier extends StateNotifier<QuizState> {
  final CourseRemoteDatasource _ds;
  QuizNotifier(this._ds) : super(const QuizState());

  Future<void> load(String quizId) async {
    state = const QuizState();
    try {
      // Start quiz → response berisi questions di data.questions
      final startData = await _ds.startQuiz(quizId);

      // Parse QuizDetailModel dari response /start (termasuk questions)
      final quiz = QuizDetailModel.fromStartResponse(startData);

      if (quiz.questions.isEmpty) {
        // Quiz belum punya soal — tampilkan pesan
        state = state.copyWith(
          error: 'Quiz ini belum memiliki soal. Silakan coba lagi nanti.',
        );
        return;
      }

      state = state.copyWith(
        quiz: quiz,
        userQuizId: quiz.userQuizId,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
          error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Simpan jawaban dengan option ID (bukan teks)
  void answer(String questionId, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[questionId] = value;
    state = state.copyWith(answers: updated);
  }

  void next() {
    if (!state.isLast) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prev() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<void> submit(String quizId) async {
    if (state.quiz == null) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _ds.submitQuiz(quizId);
      state = state.copyWith(
          isSubmitting: false, isFinished: true, result: result);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<SubmitAnswerResponse?> submitCurrentAnswer() async {
    if (state.current == null || state.userQuizId == null) return null;

    final questionId = state.current!.id;
    final answer = state.answers[questionId];
    if (answer == null) return null;

    state = state.copyWith(isSubmittingAnswer: true);
    try {
      final result = await _ds.submitAnswer(
        userQuizId: state.userQuizId!,
        questionId: questionId,
        submittedAnswer: answer,
      );

      // Simpan hasil
      final updated = Map<String, SubmitAnswerResponse>.from(state.answerResults);
      updated[questionId] = result;

      state = state.copyWith(
        answerResults: updated,
        lastAnswerResult: result,
        isSubmittingAnswer: false,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmittingAnswer: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  void clearLastAnswerResult() {
    state = state.copyWith(clearLastAnswer: true);
  }

  void reset() => state = const QuizState();
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
    (ref) => QuizNotifier(ref.read(courseDsProvider)));