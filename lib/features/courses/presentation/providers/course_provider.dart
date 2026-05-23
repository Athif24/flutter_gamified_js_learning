import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/device_utils.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/models/course_model.dart';

// ── Datasource provider ───────────────────────────────────────────────
final courseDsProvider = Provider((ref) =>
    CourseRemoteDatasource(ref.read(apiClientProvider), deviceType: detectDeviceType()));

// ── Course list (guarded: only fetches when auth is ready) ───────────
final coursesProvider = FutureProvider<List<CourseModel>>(
    (ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isLoggedIn) return <CourseModel>[];
  return ref.read(courseDsProvider).getCourses();
});

// ── Enriched courses: merge enrollment data into course list ───────────
List<CourseModel> getEnrichedCourses(
  List<CourseModel> courses,
  Map<String, dynamic>? enrolled,
) {
  if (enrolled == null || enrolled.isEmpty) {
    return courses;
  }

  final enriched = courses.map((course) {
    final data = enrolled[course.id];
    if (data != null) {
      return course.copyWith(
        isEnrolled: true,
        progress: (data['progress'] ?? 0).toDouble(),
        isCompleted: data['is_completed'] ?? false,
      );
    }
    return course;
  }).toList();

  return enriched;
}

// ── User's enrollment data (courseId -> {progress, isCompleted}) ─────
final enrolledCoursesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isLoggedIn) return <String, dynamic>{};
  final ds = ref.read(courseDsProvider);
  return ds.getMyEnrollments();
});

// ── Course detail ─────────────────────────────────────────────────────────────
final courseDetailProvider =
    FutureProvider.family<CourseModel, String>(
        (ref, id) => ref.read(courseDsProvider).getCourseById(id));

// ── Lesson detail ─────────────────────────────────────────────────────────────
final lessonDetailProvider =
    FutureProvider.family<LessonModel, String>(
        (ref, id) => ref.read(courseDsProvider).getLessonById(id));

// ── Quiz per lesson (filtered by device=mobile) ───────────────────────────────
final lessonQuizProvider =
    FutureProvider.family<QuizRefModel?, String>(
        (ref, lessonId) => ref.read(courseDsProvider).getQuizByLessonId(lessonId));

// ── Quiz preview (GET /quizzes/:id) ───────────────────────────────────────────
final quizPreviewProvider =
    FutureProvider.family<QuizPreviewModel, String>(
        (ref, id) => ref.read(courseDsProvider).getQuizById(id));

// ── My quiz result (GET /quizzes/:id/my-result) ──────────────────────────────
final myQuizResultProvider =
    FutureProvider.family<MyQuizResultResponse, String>(
        (ref, id) => ref.read(courseDsProvider).getMyQuizResult(id));

// ── Quiz attempt check (GET /quizzes/:id/attempt) ────────────────────────────
final quizAttemptProvider =
    FutureProvider.family<QuizAttemptModel, String>(
        (ref, id) => ref.read(courseDsProvider).getQuizAttempt(id));

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
  final int currentStreak;

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
    this.currentStreak = 0,
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
    int? currentStreak,
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
    currentStreak     : currentStreak      ?? this.currentStreak,
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
          error: sanitizeErrorMessage(e));
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
    if (state.quiz == null || state.isSubmitting || state.isSubmittingAnswer) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _ds.submitQuiz(quizId);
      state = state.copyWith(
          isSubmitting: false, isFinished: true, result: result);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: sanitizeErrorMessage(e),
      );
    }
  }

  Future<SubmitAnswerResponse?> submitCurrentAnswer() async {
    if (state.current == null || state.userQuizId == null || state.isSubmitting || state.isSubmittingAnswer) return null;

    final questionId = state.current!.id;
    final isCoding = state.current!.type == 'coding';
    final answer = state.answers[questionId];
    if (answer == null) return null;

    state = state.copyWith(isSubmittingAnswer: true);
    try {
      final result = isCoding
          ? await _ds.submitAnswer(
              userQuizId: state.userQuizId!,
              questionId: questionId,
              submittedCode: answer,
            )
          : await _ds.submitAnswer(
              userQuizId: state.userQuizId!,
              questionId: questionId,
              submittedAnswer: answer,
            );

      // Simpan hasil
      final updated = Map<String, SubmitAnswerResponse>.from(state.answerResults);
      updated[questionId] = result;

      // Update streak
      final newStreak = result.isCorrect ? state.currentStreak + 1 : 0;

      state = state.copyWith(
        answerResults: updated,
        lastAnswerResult: result,
        isSubmittingAnswer: false,
        currentStreak: newStreak,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmittingAnswer: false,
        error: sanitizeErrorMessage(e),
      );
      return null;
    }
  }

  void clearLastAnswerResult() {
    state = state.copyWith(clearLastAnswer: true);
  }

  /// Load quiz data directly from a started response (used by IntroScreen)
  void loadFromData(QuizDetailModel quizData) {
    final startIndex = quizData.answeredQuestionIds.isNotEmpty
        ? quizData.answeredQuestionIds.length
        : 0;
    state = const QuizState().copyWith(
      quiz: quizData,
      userQuizId: quizData.userQuizId,
      currentIndex: startIndex,
    );
  }

  void reset() => state = const QuizState();
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
    (ref) => QuizNotifier(ref.read(courseDsProvider)));