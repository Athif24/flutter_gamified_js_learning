import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AuthRemoteDatasource {
  final ApiClient _api;
  AuthRemoteDatasource(this._api);

  Future<LoginResponse> login(String email, String password) async {
    try {
      final res = await _api.post(Api.login, data: {'email': email, 'password': password});
      final response = LoginResponse.fromJson(res.data);
      await SecureStorage.saveToken(response.token);
      await SecureStorage.saveUid(response.user.id);
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login gagal');
    }
  }

  Future<LoginResponse> register(String name, String email, String password) async {
    try {
      final res = await _api.post(Api.register, data: {
        'name': name, 'email': email, 'password': password,
      });
      final response = LoginResponse.fromJson(res.data);
      await SecureStorage.saveToken(response.token);
      await SecureStorage.saveUid(response.user.id);
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> logout() async {
    try { await _api.post(Api.logout); } catch (_) {}
    await SecureStorage.clearAll();
  }

  Future<AuthUser> getMe() async {
    try {
      final res = await _api.get(Api.authMe);
      return AuthUser.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat profil');
    }
  }
}