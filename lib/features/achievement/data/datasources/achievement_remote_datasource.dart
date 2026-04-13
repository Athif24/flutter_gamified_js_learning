import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/achievement_model.dart';

class AchievementRemoteDatasource {
  final ApiClient _api;
  AchievementRemoteDatasource(this._api);

  Future<XpModel> getXp() async {
    try {
      final res = await _api.get(Api.xps);
      final list = extractList(res.data);
      if (list.isNotEmpty) {
        return XpModel.fromJson(list.first as Map<String, dynamic>);
      }
      return XpModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat XP');
    }
  }

  Future<StreakModel> getStreak() async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final res = await _api.get(Api.userStreakByUser(uid));
      return StreakModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat streak');
    }
  }

  Future<List<BadgeModel>> getUserBadges() async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final res  = await _api.get(Api.userBadgesByUser(uid));
      final list = extractList(res.data);
      return list.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat badge');
    }
  }

  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final res  = await _api.get(Api.badges);
      final list = extractList(res.data);
      return list.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat badge');
    }
  }

  Future<LearningReportModel> getLearningReport() async {
    try {
      final res = await _api.get(Api.reportsLearning);
      return LearningReportModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat laporan');
    }
  }
}