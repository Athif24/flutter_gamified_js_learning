import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

// ── Response helpers ──────────────────────────────────────────────────────────

List<dynamic> extractList(dynamic body) {
  if (body is List) return body;
  if (body is Map<String, dynamic>) {
    final d = body['data'];
    if (d is List) return d;
    if (d is Map) {
      // for (final v in (d as Map).values) { if (v is List) return v; }
      for (final v in (d as Map<String, dynamic>).values) { if (v is List) return v; }
    }
    for (final v in body.values) { if (v is List) return v; }
  }
  return [];
}

Map<String, dynamic> extractMap(dynamic body) {
  if (body is Map<String, dynamic>) {
    final d = body['data'];
    if (d is Map<String, dynamic>) return d;
    return body;
  }
  return {};
}

// ── Dio client ────────────────────────────────────────────────────────────────

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl        : Api.base,
      connectTimeout : const Duration(seconds: 15),
      receiveTimeout : const Duration(seconds: 20),
      headers        : {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, responseBody: true,
      logPrint: (o) => debugPrint('[API] $o'),
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) =>
      _dio.get(path, queryParameters: query);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final token = await SecureStorage.getToken();
    if (token != null) o.headers['Authorization'] = 'Bearer $token';
    h.next(o);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (e.response?.statusCode == 401) SecureStorage.clearAll();
    h.next(e);
  }
}

final apiClientProvider = Provider<ApiClient>((_) => ApiClient());