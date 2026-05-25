import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/error_helper.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_model.dart';
import '../../../../features/shared/presentation/widgets/post_register_tutorial.dart';

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final bool isCheckingAuth;
  final String? error;
  const AuthState({this.user, this.isLoading = false, this.isCheckingAuth = true, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AuthUser? user, bool? isLoading, bool? isCheckingAuth, String? error,
    bool clearUser = false, bool clearError = false,
  }) => AuthState(
    user          : clearUser  ? null  : (user      ?? this.user),
    isLoading     : isLoading  ?? this.isLoading,
    isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
    error         : clearError ? null  : (error     ?? this.error),
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource _ds;
  final ApiClient _api;
  AuthNotifier(this._ds, this._api) : super(const AuthState()) { _restore(); }

  static const _onboardingSPKey = 'onboarding_completed';

  Future<void> _restore() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      state = state.copyWith(isCheckingAuth: false, clearError: true);
      return;
    }
    try {
      var user = await _ds.getMe();
      final prefs = await SharedPreferences.getInstance();
      final localCompleted = prefs.getBool(_onboardingSPKey) ?? false;
      if (localCompleted && !user.onboardingCompleted) {
        user = user.copyWith(onboardingCompleted: true);
      }
      state = state.copyWith(user: user, isCheckingAuth: false, clearError: true);
    } catch (_) {
      await SecureStorage.clearAll();
      state = state.copyWith(isCheckingAuth: false, clearUser: true, clearError: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _ds.login(email, password);
      // Cache token in memory immediately to avoid race condition
      // where SecureStorage hasn't flushed to disk yet.
      _api.cacheToken(r.token);
      state = state.copyWith(user: r.user, isLoading: false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingSPKey, r.user.onboardingCompleted);
      await PostRegisterTutorial.reset();
      _maybeRegisterToken();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: sanitizeErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _ds.register(name, email, password);
      AuthUser user;
      if (r.token.isEmpty) {
        final loginR = await _ds.login(email, password);
        _api.cacheToken(loginR.token);
        user = loginR.user;
      } else {
        _api.cacheToken(r.token);
        user = r.user;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingSPKey, user.onboardingCompleted);
      state = state.copyWith(user: user, isLoading: false);
      await PostRegisterTutorial.reset();
      _maybeRegisterToken();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: sanitizeErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> _maybeRegisterToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      if (enabled) {
        unawaited(FcmService.registerToken(_api));
      }
    } catch (_) {}
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      await _ds.changePassword(oldPassword, newPassword);
      return null;
    } catch (e) {
      return sanitizeErrorMessage(e);
    }
  }

  Future<void> refreshMe() async {
    try {
      final user = await _ds.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> updateProfile({String? avatar}) async {
    await _ds.updateProfile(avatar: avatar);
  }

  Future<void> completeOnboarding() async {
    await _ds.completeOnboarding();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSPKey, true);
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(onboardingCompleted: true));
    }
  }

  Future<void> logout() async {
    await FcmService.unregisterToken(_api);
    await _ds.logout();
    _api.clearCachedToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingSPKey);
    state = const AuthState(isCheckingAuth: false);
  }
}

final _authDsProvider = Provider((ref) =>
    AuthRemoteDatasource(ref.read(apiClientProvider)));

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.read(_authDsProvider), ref.read(apiClientProvider)));