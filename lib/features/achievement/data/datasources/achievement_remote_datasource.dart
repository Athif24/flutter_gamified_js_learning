import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/achievement_model.dart';

// TODO: add per-call timeout via Dio options to prevent hanging requests
class AchievementRemoteDatasource {
  final ApiClient _api;
  AchievementRemoteDatasource(this._api);

  Future<List<LevelModel>> getLevels() async {
    try {
      final res = await _api.get(Api.levels);
      final list = extractList(res.data);
      return list
          .map((e) => LevelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // TODO: preserve original exception type instead of wrapping in Exception
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat level');
    }
  }

  Future<({List<XpHistoryEntry> data, String? cursor, bool hasMore})>
  getXpHistory({String? cursor}) async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final query = <String, dynamic>{
        'user_id': uid,
        'page_size': 50,
        'sort': 'desc',
      };
      if (cursor != null) query['cursor'] = cursor;
      final res = await _api.get(Api.xps, query: query);
      final body = res.data;
      final list = extractList(body);
      final entries = list
          .map((e) => XpHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      String? nextCursor;
      bool hasMore = false;
      if (body is Map<String, dynamic>) {
        final inner = body['data'];
        if (inner is Map) {
          final meta = inner['meta'];
          if (meta is Map) {
            nextCursor = meta['cursor']?.toString();
            hasMore = meta['has_more'] == true;
          }
        }
      }
      return (data: entries, cursor: nextCursor, hasMore: hasMore);
    } on DioException catch (e) {
      // TODO: preserve original exception type instead of wrapping in Exception
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal memuat riwayat XP',
      );
    }
  }

  Future<StreakModel> getStreak() async {
    try {
      final uid = await SecureStorage.getUid();
      if (uid == null) throw Exception('User tidak ditemukan');
      final res = await _api.get(
        Api.userStreaks,
        query: {'user_id': uid, 'page_size': 1},
      );
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
      final res = await _api.get(Api.userBadgesByUser(uid));
      final list = extractList(res.data);
      return list
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // TODO: preserve original exception type instead of wrapping in Exception
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat badge');
    }
  }

  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final res = await _api.get(Api.badges);
      final list = extractList(res.data);
      return list
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // TODO: preserve original exception type instead of wrapping in Exception
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat badge');
    }
  }
}