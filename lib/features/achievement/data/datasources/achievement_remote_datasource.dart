import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/achievement_model.dart';

class AchievementRemoteDatasource {
  final ApiClient _api;
  AchievementRemoteDatasource(this._api);

  Future<List<LevelModel>> getLevels() async {
    try {
      final res = await _api.get(Api.levels);
      final list = extractList(res.data);
      return list.map((e) => LevelModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat level');
    }
  }

  Future<List<dynamic>>? _xpPending;
  Future<List<dynamic>> fetchXpRaw() {
    if (_xpPending != null) return _xpPending!;
    _xpPending = _doFetchXpRaw();
    _xpPending?.then((_) => _xpPending = null, onError: (_) => _xpPending = null);
    return _xpPending!;
  }

  Future<List<dynamic>> _doFetchXpRaw() async {
    final res = await _api.get(Api.xps);
    return extractList(res.data);
  }

  Future<List<XpHistoryEntry>> getXpHistory() async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final res = await _api.get(Api.xps, query: {
        'user_id': uid,
        'page_size': 50,
        'sort': 'desc',
      });
      final list = extractList(res.data);
      return list.map((e) => XpHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat riwayat XP');
    }
  }

  Future<LivesModel> getLives() async {
    try {
      final res = await _api.get(Api.usersLives);
      return LivesModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat lives');
    }
  }

  Future<XpModel> getXp() async {
    try {
      final list = await fetchXpRaw();
      if (list.isNotEmpty) {
        return XpModel.fromJson(list.first as Map<String, dynamic>);
      }
      return const XpModel(totalXp: 0, level: 1, levelTitle: 'Pemula', xpToNextLevel: 500);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat XP');
    }
  }

  Future<StreakModel> getStreak() async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final res = await _api.get(Api.userStreaks, query: {
        'user_id': uid,
        'page_size': 1,
      });
      final list = extractList(res.data);
      if (list.isNotEmpty) {
        return StreakModel.fromJson(list.first as Map<String, dynamic>);
      }
      return const StreakModel(currentStreak: 0, longestStreak: 0);
    } on DioException catch (_) {
      return const StreakModel(currentStreak: 0, longestStreak: 0);
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