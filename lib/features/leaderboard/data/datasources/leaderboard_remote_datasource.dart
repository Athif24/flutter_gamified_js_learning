import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRemoteDatasource {
  final ApiClient _api;
  LeaderboardRemoteDatasource(this._api);

  Future<LeaderboardResponse> getLeaderboard() async {
    try {
      final res = await _api.get(Api.leaderboard);
      return LeaderboardResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal memuat leaderboard',
      );
    }
  }
}
