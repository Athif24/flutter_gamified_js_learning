import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseRemoteDatasource {
  final ApiClient _api;
  final String deviceType;

  CourseRemoteDatasource(this._api, {this.deviceType = 'mobile'});

  /// Normalizes progress from 0–100 (API) to 0.0–1.0 (internal scale).
  static double _normalizeProgress(dynamic v) {
    if (v is num) return v > 1 ? v / 100.0 : v.toDouble();
    return 0.0;
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      final res = await _api.get(Api.courses);
      final list = extractList(res.data);
      return list.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat kursus');
    }
  }

  Future<Map<String, dynamic>> getMyEnrollments() async {
    try {
      // user-courses returns 403; use auth/profile instead which has courses.details
      final res = await _api.get(Api.authProfile);
      final data = extractMap(res.data);
      final coursesData = data['courses'] as Map? ?? {};
      final details = coursesData['details'] as List? ?? [];
      final enrollmentMap = <String, dynamic>{};
      for (final item in details) {
        final m = item as Map;
        final courseId = m['id']?.toString() ?? '';
        if (courseId.isEmpty) {
          continue;
        }
        final rawProgress = m['progress'] ?? 0;
        final progress = rawProgress is num
            ? (rawProgress > 1 ? rawProgress / 100.0 : rawProgress.toDouble())
            : 0.0;
        enrollmentMap[courseId] = <String, dynamic>{
          'progress': progress,
          'is_completed': m['is_completed'] ?? m['isCompleted'] ?? false,
          'name': m['name'] ?? '',
        };
      }
      return enrollmentMap;
    } on DioException {
      return <String, dynamic>{};
    }
  }

  Future<CourseModel> getCourseById(String id) async {
    try {
      // Primary: call progress endpoint — returns course + units + lessons + status
      final progressRes = await _api.get(Api.courseProgress(id));
      final progressData = extractMap(progressRes.data);
      final pd = progressData['data'] ?? progressData;

      if (pd == null) throw Exception('Data tidak ditemukan');

      final courseInfo = pd['course'] as Map? ?? {};
      final unitsRaw = pd['units'] as List? ?? [];

      // Build course map from progress response
      final courseMap = <String, dynamic>{
        'id': courseInfo['id']?.toString() ?? id,
        'name': courseInfo['name'] ?? '',
        'description': courseInfo['description'],
        'thumbnail': courseInfo['thumbnail'],
        'total_lessons': courseInfo['total_lessons'] ?? 0,
        'is_published': courseInfo['is_published'] ?? true,
        'progress': _normalizeProgress(pd['progress']),
        'is_completed': pd['is_completed'] ?? false,
        'is_enrolled': true,
        'units': unitsRaw.map((u) {
          final uMap = u as Map;
          final isUnlocked = uMap['is_unlocked'] ?? true;
          return <String, dynamic>{
            'id': uMap['id']?.toString() ?? '',
            'name': uMap['name'] ?? '',
            'sequence': uMap['sequence'] ?? 0,
            'order': uMap['sequence'] ?? 0,
            'progress': uMap['progress'] ?? 0,
            'is_completed': uMap['is_completed'] ?? false,
            'is_unlocked': isUnlocked,
            'lessons': (uMap['lessons'] as List? ?? []).map((l) {
              final lMap = l as Map;
              return <String, dynamic>{
                'id': lMap['id']?.toString() ?? '',
                'name': lMap['name'] ?? '',
                'sequence': lMap['sequence'] ?? 0,
                'order': lMap['sequence'] ?? 0,
                'is_completed': lMap['is_completed'] ?? false,
                'is_locked': !isUnlocked,
              };
            }).toList(),
            'quizzes': <dynamic>[],
          };
        }).toList(),
      };

      // Find last accessed from completed lessons
      for (final u in unitsRaw) {
        for (final l in (u as Map)['lessons'] as List? ?? []) {
          if ((l as Map)['is_completed'] == true) {
            courseMap['last_accessed_lesson_title'] = l['name'];
            courseMap['last_accessed_unit_title'] = u['name'];
          }
        }
      }

      return CourseModel.fromJson(courseMap);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat detail kursus');
    }
  }

  Future<Map<String, dynamic>> getCourseProgress(String id) async {
    try {
      final res = await _api.get(Api.courseProgress(id));
      return extractMap(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat progress');
    }
  }

  Future<void> enrollCourse(String id) async {
    try {
      await _api.post(Api.courseEnroll(id));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? '';
      if (msg.toLowerCase().contains('udah enroll') || msg.toLowerCase().contains('already')) {
        return;
      }
      throw Exception(msg);
    }
  }

  Future<LessonModel> getLessonById(String id) async {
    try {
      final res = await _api.get(Api.lessonById(id));
      return LessonModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat materi');
    }
  }

  Future<QuizRefModel?> getQuizByLessonId(String lessonId) async {
    try {
      final res = await _api.get(Api.quizzes, query: {
        'lesson_id': lessonId,
        'device': deviceType,
      });
      final list = extractList(res.data);
      if (list.isEmpty) return null;
      return QuizRefModel.fromJson(list[0] as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<LessonCompleteResponse> completeLesson(String id) async {
    try {
      final res = await _api.post(Api.lessonComplete(id));
      final resp = LessonCompleteResponse.fromJson(res.data);
      return resp;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal menyelesaikan materi';
      throw Exception(msg);
    }
  }

  Future<QuizPreviewModel> getQuizById(String id) async {
    try {
      final res = await _api.get(Api.quizById(id));
      return QuizPreviewModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat kuis');
    }
  }

  Future<Map<String, dynamic>> startQuiz(String id, {bool force = false}) async {
    try {
      final uri = '${Api.quizStart(id)}${force ? '?force=true' : ''}';
      final res = await _api.post(uri);
      final extracted = extractMap(res.data);
      return extracted;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memulai kuis';
      throw Exception(msg);
    }
  }

  Future<QuizAttemptModel> getQuizAttempt(String id) async {
    try {
      final res = await _api.get(Api.quizAttempt(id));
      return QuizAttemptModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat status kuis');
    }
  }

  Future<QuizResultModel> submitQuiz(String id) async {
    try {
      final res = await _api.post(Api.quizSubmit(id), data: {});
      final result = QuizResultModel.fromJson(res.data);
      return result;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal submit kuis';
      throw Exception(msg);
    }
  }

  Future<SubmitAnswerResponse> submitAnswer({
    required int userQuizId,
    required String questionId,
    dynamic submittedAnswer,
    dynamic submittedCode,
  }) async {
    try {
      final data = {
        'user_quiz_id': userQuizId,
        'question_id': int.tryParse(questionId) ?? questionId,
        if (submittedAnswer != null) 'submitted_answer': submittedAnswer,
        if (submittedCode != null) 'submitted_code': submittedCode,
      };
      final res = await _api.post(Api.submitAnswer, data: data);
      final result = SubmitAnswerResponse.fromJson(res.data);
      return result;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Gagal submit jawaban';
      throw Exception(msg);
    }
  }

  Future<MyQuizResultResponse> getMyQuizResult(String id) async {
    try {
      final res = await _api.get(Api.quizMyResult(id));
      return MyQuizResultResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat hasil kuis');
    }
  }
}