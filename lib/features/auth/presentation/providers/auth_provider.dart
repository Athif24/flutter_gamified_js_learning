import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_model.dart';

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AuthUser? user, bool? isLoading, String? error,
    bool clearUser = false, bool clearError = false,
  }) => AuthState(
    user     : clearUser  ? null  : (user      ?? this.user),
    isLoading: isLoading  ?? this.isLoading,
    error    : clearError ? null  : (error     ?? this.error),
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource _ds;
  AuthNotifier(this._ds) : super(const AuthState()) { _restore(); }

  Future<void> _restore() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;
    try {
      final user = await _ds.getMe();
      state = state.copyWith(user: user);
    } catch (_) { await SecureStorage.clearAll(); }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _ds.login(email, password);
      state = state.copyWith(user: r.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _ds.register(name, email, password);
      state = state.copyWith(user: r.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _ds.logout();
    state = const AuthState();
  }
}

final _authDsProvider = Provider((ref) =>
    AuthRemoteDatasource(ref.read(apiClientProvider)));

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.read(_authDsProvider)));