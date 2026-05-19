import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AuthRemoteDatasource {
  final ApiClient _api;
  AuthRemoteDatasource(this._api);

  Future<LoginResponse> login(String email, String password) async {
    debugPrint('[ACTION] Login: email=$email');
    try {
      final res = await _api.post(Api.login, data: {'email': email, 'password': password});
      final response = LoginResponse.fromJson(res.data);
      await SecureStorage.saveToken(response.token);
      await SecureStorage.saveUid(response.user.id);
      debugPrint('[ACTION] Login ✅ user=${response.user.id}');
      return response;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login gagal';
      debugPrint('[ACTION] Login ❌ $msg');
      throw Exception(msg);
    }
  }

  Future<LoginResponse> register(String name, String email, String password) async {
    debugPrint('[ACTION] Register: name=$name email=$email');
    try {
      final res = await _api.post(Api.register, data: {
        'name': name, 'email': email, 'password': password,
      });
      final response = LoginResponse.fromJson(res.data);
      await SecureStorage.saveToken(response.token);
      await SecureStorage.saveUid(response.user.id);
      debugPrint('[ACTION] Register ✅ user=${response.user.id}');
      return response;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registrasi gagal';
      debugPrint('[ACTION] Register ❌ $msg');
      throw Exception(msg);
    }
  }

  Future<void> logout() async {
    debugPrint('[ACTION] Logout');
    await SecureStorage.clearAll();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    debugPrint('[ACTION] Change password');
    try {
      await _api.put(Api.authChangePassword, data: {
        'current_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': newPassword,
      });
      debugPrint('[ACTION] Change password ✅');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal mengubah password';
      debugPrint('[ACTION] Change password ❌ $msg');
      throw Exception(msg);
    }
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