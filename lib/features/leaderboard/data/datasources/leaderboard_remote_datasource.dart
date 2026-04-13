import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRemoteDatasource {
  final ApiClient _api;
  LeaderboardRemoteDatasource(this._api);

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final res  = await _api.get(Api.leaderboard);
      final list = extractList(res.data);
      return list.asMap().entries.map((e) =>
          LeaderboardEntry.fromJson(
              e.value as Map<String, dynamic>,
              fallbackRank: e.key + 1)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat leaderboard');
    }
  }
}