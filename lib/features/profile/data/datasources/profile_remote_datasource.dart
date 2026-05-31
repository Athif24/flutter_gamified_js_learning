import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../achievement/data/models/achievement_model.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _api;
  ProfileRemoteDatasource(this._api);

  Future<ProfileModel> getProfile() async {
    try {
      final res = await _api.get(Api.authProfile);
      return ProfileModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat profil');
    }
  }

  Future<LivesModel> getEffectiveLives() async {
    final res = await _api.get(Api.usersLives);
    return LivesModel.fromJson(res.data);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    debugPrint('[ACTION] Update profile: name=${data['name']} email=${data['email']}');
    try {
      final res = await _api.put(Api.authProfile, data: data);
      debugPrint('[ACTION] Update profile ✅');
      return ProfileModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal update profil';
      debugPrint('[ACTION] Update profile ❌ $msg');
      throw Exception(msg);
    }
  }
}