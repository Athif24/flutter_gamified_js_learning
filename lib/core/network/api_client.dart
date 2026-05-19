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
    _dio.interceptors.add(_TimingInterceptor());
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

  Future<Response> delete(String path, {dynamic data}) =>
      _dio.delete(path, data: data);
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      o.headers['Authorization'] = 'Bearer $token';
    }
    h.next(o);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    final path = e.requestOptions.path;
    if (code == 401) {
      debugPrint('[API] 401 on $path — clearing token');
      SecureStorage.clearAll();
    } else if (code != null) {
      debugPrint('[API] $code on $path: ${data is Map ? data['message'] ?? data : data}');
    } else {
      debugPrint('[API] 💥 $path — ${e.message}');
    }
    h.next(e);
  }
}

class _TimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    o.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    final start = r.requestOptions.extra['startTime'] as int?;
    if (start != null) {
      final ms = DateTime.now().millisecondsSinceEpoch - start;
      final code = r.statusCode ?? 0;
      final emoji = code >= 200 && code < 300 ? '✅' : '⚠️';
      debugPrint('[API] $code ${r.requestOptions.path} (${ms}ms) $emoji');
    }
    h.next(r);
  }
}

final apiClientProvider = Provider<ApiClient>((_) => ApiClient());