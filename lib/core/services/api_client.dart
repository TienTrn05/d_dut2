import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../common/utils/getit_utils.dart';
import '../../features/app/app_router.dart';
import '../data/local/storage.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await Storage.setAccessToken(null);
            await Storage.setUser(null);

            getIt<AppRouter>().replaceAll([const AuthRoute()]);
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
