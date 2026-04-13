import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _api;
  ProfileRemoteDatasource(this._api);

  Future<ProfileModel> getProfile() async {
    try {
      final res = await _api.get(Api.authMe);
      return ProfileModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat profil');
    }
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.put(Api.authProfile, data: data);
      return ProfileModel.fromJson(extractMap(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal update profil');
    }
  }
}