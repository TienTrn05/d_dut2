import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommunityService {
  final String _url;
  final Dio _dio;

  CommunityService(@Named('communityAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<ActivityModel>> getActivities(
      String token, String keyword) async {
    try {
      final response = await _dio.get("$_url/api/activities",
          queryParameters: {"keyword": keyword},
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final activities = data.map((e) => ActivityModel.fromJson(e)).toList();
        return activities;
      } else {
        throw Exception(
            "Failed to load activities : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching all activities: $e");
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories(
      String token, String keyword) async {
    try {
      final response = await _dio.get("$_url/api/categories",
          queryParameters: {"keyword": keyword},
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final categories = data.map((e) => CategoryModel.fromJson(e)).toList();

        return categories;
      } else {
        throw Exception(
            "Failed to load categories : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching all categories: $e");
      rethrow;
    }
  }

  Future<UserInfoModel> getUserInfo(String token) async {
    try {
      final response = await _dio.get("$_url/api/users/me/info",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final dynamic data = responseData['data']['user'];

        final userInfo = UserInfoModel.fromJson(data);

        return userInfo;
      } else {
        throw Exception(
            "Failed to load user info : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching user info: $e");
      rethrow;
    }
  }

  Future<bool> registActivity(String token, String idActivity) async {
    try {
      final response =
          await _dio.post("$_url/api/activities/$idActivity/register",
              options: Options(headers: {
                "Authorization": "Bearer $token",
              }));

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      logger.e("Error regist activity: $e");
      rethrow;
    }
  }

  Future<List<UserActivityModel>> getUserActivities(
      String token, String keyword) async {
    try {
      final response = await _dio.get("$_url/api/my-activities",
          queryParameters: {"keyword": keyword},
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final userActivities =
            data.map((e) => UserActivityModel.fromJson(e)).toList();

        return userActivities;
      } else {
        throw Exception(
            "Failed to load my activities: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching my activities: $e");
      rethrow;
    }
  }

  Future<bool> cancelRegistration(String token, String idActivity) async {
    try {
      final response =
          await _dio.post("$_url/api/activities/$idActivity/cancel",
              options: Options(headers: {
                "Authorization": "Bearer $token",
              }));

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      logger.e("Error cancel registration: $e");
      rethrow;
    }
  }

  Future<bool> submitProof(
    String token,
    String idRegistration,
    File imageFile,
    String? description,
  ) async {
    try {
      final formData = FormData.fromMap({
        'name': 'Proof Image',
        'description': description ?? '',
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        )
      });
      final response =
          await _dio.post("$_url/api/proofs/$idRegistration/submit",
              data: formData,
              options: Options(headers: {
                "Authorization": "Bearer $token",
              }));
      return response.statusCode == 201 && response.data['success'] == true;
    } on DioException catch (e) {
      logger.e("Error submit proof: ${e.message}");
      rethrow;
    }
  }
}
