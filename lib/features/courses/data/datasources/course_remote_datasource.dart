import 'package:dio/dio.dart';
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

  Future<void> completeLesson(String id) async {
    try {
      await _api.post(Api.lessonComplete(id));
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
      return extractMap(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal memulai kuis');
    }
  }

  Future<QuizResultModel> submitQuiz(String id, Map<String, dynamic> answers) async {
    try {
      final res = await _api.post(Api.quizSubmit(id), data: {'answers': answers});
      return QuizResultModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Gagal submit kuis');
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