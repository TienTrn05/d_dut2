import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../model/user_model.dart';

@injectable
class AuthService {
  final String _url;

  final Dio _dio;

  AuthService(@Named('apiUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        "$_url/api/login",
        data: {
          "username": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String accessToken = data["accessToken"];

        return {
          "accessToken": accessToken,
          "user": UserModel.fromJson(data["user"]),
        };
      } else {
        throw Exception("Failed to login: ${response.data["message"]}");
      }
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }

  Future<Map<String, dynamic>> getProfileWithMicrosoft(
      String accessToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/microsoft/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String accessToken = data["accessToken"];

        return {
          "accessToken": accessToken,
          "user": UserModel.fromJson(data["user"]),
        };
      } else {
        throw Exception("Failed to login: ${response.data["message"]}");
      }
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }
}
