import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/reward_pool_model.dart';

class RewardPoolRemoteDatasource {
  final ApiClient _api;
  RewardPoolRemoteDatasource(this._api);

  Future<List<RewardPool>> getPools([String? poolType]) async {
    try {
      final query = poolType != null ? {'pool_type': poolType} : null;
      final res = await _api.get(Api.rewardPools, query: query);
      final list = extractList(res.data);
      return list.map((e) => RewardPool.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat reward pools');
    }
  }

  Future<Map<String, dynamic>> buyPool(int poolId) async {
    debugPrint('[ACTION] Buy reward pool: id=$poolId');
    try {
      final res = await _api.post(Api.buyRewardPool(poolId));
      final data = res.data?['data'] ?? res.data;
      debugPrint('[ACTION] Buy reward pool ✅ id=$poolId');
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal membeli Mystery Box';
      debugPrint('[ACTION] Buy reward pool ❌ $msg');
      throw Exception(msg);
    }
  }

  Future<MysteryBoxResult> openPool(int poolId) async {
    debugPrint('[ACTION] Open reward pool: id=$poolId');
    try {
      final res = await _api.post(Api.openRewardPool(poolId));
      final data = res.data?['data'] ?? res.data;
      debugPrint('[ACTION] Open reward pool ✅ id=$poolId');
      return MysteryBoxResult.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal membuka Mystery Box';
      debugPrint('[ACTION] Open reward pool ❌ $msg');
      throw Exception(msg);
    }
  }
}
