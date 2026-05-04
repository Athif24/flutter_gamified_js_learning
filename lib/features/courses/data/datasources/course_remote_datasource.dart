import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseRemoteDatasource {
  final ApiClient _api;
  CourseRemoteDatasource(this._api);

  Future<List<CourseModel>> getCourses() async {
    try {
      final res  = await _api.get(Api.courses);
      final list = extractList(res.data);
      return list.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      debugPrint('[Courses] Error ${e.response?.statusCode} on ${e.requestOptions.path}: ${e.response?.data}');
      if (e.response?.statusCode == 403) {
        throw Exception('Akses ditolak: Anda tidak memiliki izin untuk melihat daftar kursus. Silakan hubungi administrator.');
      }
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat kursus');
    }
  }

  Future<CourseModel> getCourseById(String id) async {
    try {
      final res       = await _api.get(Api.courseById(id));
      final courseMap = Map<String, dynamic>.from(extractMap(res.data));
      final rawUnits  = courseMap['units'] as List? ?? [];

      final unitsWithData = await Future.wait(
        rawUnits.map((unit) async {
          final unitMap = Map<String, dynamic>.from(unit as Map<String, dynamic>);
          final unitId  = unitMap['id']?.toString() ?? '';

          // Fetch lessons
          try {
            final res = await _api.get(Api.lessonsByUnit(unitId)); 
            final outer = res.data?['data'];
            unitMap['lessons'] = (outer is Map ? outer['data'] : null) as List? ?? [];
          } catch (_) {
            unitMap['lessons'] = <dynamic>[];
          }

          // Fetch quizzes for this unit
          try {
            final res = await _api.get(Api.quizzes, query: {'unit_id': unitId});
            final outer = res.data?['data'];
            unitMap['quizzes'] = (outer is Map ? outer['data'] : null) as List? ?? [];
          } catch (_) {
            unitMap['quizzes'] = <dynamic>[];
          }

          return unitMap;
        }),
      );

      courseMap['units'] = unitsWithData;

      // Fetch progress to get is_enrolled, progress %, and last accessed info
      try {
        final progressRes = await _api.get(Api.courseProgress(id));
        final progressData = extractMap(progressRes.data);
        final pd = progressData['data'] ?? progressData;
        // progress endpoint returns: { course, progress, is_completed, units: [...] }
        if (pd != null) {
          courseMap['is_enrolled'] = true;
          courseMap['progress'] = pd['progress'] ?? 0;
          courseMap['is_completed'] = pd['is_completed'] ?? false;

          // Find last accessed lesson/unit from units
          for (final u in (pd['units'] as List? ?? [])) {
            for (final l in (u as Map)['lessons'] as List? ?? []) {
              if ((l as Map)['is_completed'] == true) {
                courseMap['last_accessed_lesson_title'] = l['name'];
                courseMap['last_accessed_unit_title'] = u['name'];
              }
            }
          }
        }
      } catch (_) {
        // Not enrolled or error — is_enrolled stays false
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
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal enroll kursus');
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

  Future<LessonCompleteResponse> completeLesson(String id) async {
    try {
      final res = await _api.post(Api.lessonComplete(id));
      return LessonCompleteResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal menyelesaikan materi');
    }
  }

  Future<QuizDetailModel> getQuizById(String id) async {
    try {
      final res = await _api.get(Api.quizById(id));
      return QuizDetailModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat kuis');
    }
  }

  Future<Map<String, dynamic>> startQuiz(String id) async {
    try {
      final res = await _api.post(Api.quizStart(id));
      debugPrint('[startQuiz] Raw response: ${res.data}');
      final extracted = extractMap(res.data);
      debugPrint('[startQuiz] Extracted map: $extracted');
      // Log questions if available
      if (extracted['data'] != null && extracted['data'] is Map) {
        final data = extracted['data'] as Map;
        if (data['questions'] != null && data['questions'] is List) {
          final questions = data['questions'] as List;
          debugPrint('[startQuiz] Questions count: ${questions.length}');
          if (questions.isNotEmpty) {
            debugPrint('[startQuiz] First question: ${questions[0]}');
          }
        }
      }
      return extracted;
    } on DioException catch (e) {
      debugPrint('[startQuiz] Error: ${e.response?.data}');
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memulai kuis');
    }
  }

  Future<QuizResultModel> submitQuiz(String id) async {
    try {
      final res = await _api.post(Api.quizSubmit(id));
      return QuizResultModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal submit kuis');
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
        'question_id': int.parse(questionId),
        if (submittedAnswer != null) 'submitted_answer': submittedAnswer,
        if (submittedCode != null) 'submitted_code': submittedCode,
      };
      final res = await _api.post(Api.submitAnswer, data: data);
      return SubmitAnswerResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint('[submitAnswer] Error: ${e.response?.data}');
      throw Exception(e.response?.data?['error'] ?? 'Gagal submit jawaban');
    }
  }

  Future<QuizResultModel> getMyQuizResult(String id) async {
    try {
      final res = await _api.get(Api.quizMyResult(id));
      return QuizResultModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memuat hasil kuis');
    }
  }
}