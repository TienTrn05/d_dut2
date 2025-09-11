import 'dart:io' show HttpHeaders;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/local/storage.dart';
import '/features/auth/presentation/auth_screen.dart';
import './navigation_service.dart';

const String _apiFromEnvironment = String.fromEnvironment(
  'API_BASE',
  defaultValue: '',
);

class ApiClient {
  final Dio _dio;
  final String baseUrl;

  final Future<String?> Function()? _tokenProvider;

  ApiClient(
    String baseUrl, {
    Dio? dio,
    Future<String?> Function()? tokenProvider,
  })  : baseUrl = (baseUrl.isNotEmpty ? baseUrl : _apiFromEnvironment).trim(),
        _dio = dio ?? Dio(),
        _tokenProvider = tokenProvider {
    if (this.baseUrl.isEmpty) {
      throw Exception('Missing API_BASE');
    }

    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.responseType = ResponseType.json;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers = <String, dynamic>{};
          options.headers
              .putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json');
          options.headers.putIfAbsent(HttpHeaders.contentTypeHeader,
              () => 'application/json; charset=utf-8');

          if (_tokenProvider != null) {
            try {
              final token = await _tokenProvider();
              if (token != null && token.isNotEmpty) {
                options.headers[HttpHeaders.authorizationHeader] =
                    'Bearer $token';
              }
            } catch (_) {}
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              await Storage.setAccessToken(null);
              await Storage.setUser(null);
            } catch (_) {}
            final context = navigatorKey.currentState?.context;
            if (context != null) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthScreen()),
                (Route<dynamic> route) => false,
              );
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  factory ApiClient.fromEnv({
    Dio? dio,
    Future<String?> Function()? tokenProvider,
  }) =>
      ApiClient(_apiFromEnvironment, dio: dio, tokenProvider: tokenProvider);

  Dio get dio => _dio;

  Map<String, dynamic> _mergedHeaders(Map<String, String>? headers) => {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        ...?headers,
      };

  // GET trả List
  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: _mergedHeaders(headers)),
    );
    final body = res.data;
    if (body is List) return body;
    if (body is Map) {
      final data = body['data'];
      if (data is List) return data;
      for (final entry in body.entries) {
        if (entry.value is List) return List<dynamic>.from(entry.value);
      }
    }
    return [body];
  }

  /// GET trả Map
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: _mergedHeaders(headers)),
    );
    final body = res.data;
    return body is Map<String, dynamic> ? body : {'data': body};
  }

  /// POST JSON trả Map
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final res = await _dio.post(
      path,
      queryParameters: query,
      data: body,
      options: Options(headers: _mergedHeaders(headers)),
    );
    final data = res.data;
    return data is Map<String, dynamic> ? data : {'data': data};
  }
}
