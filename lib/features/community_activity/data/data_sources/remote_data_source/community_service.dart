import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/community_activity/constant/page_limit.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/proofs_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/paged/user_activities_paged_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:injectable/injectable.dart';

import '/core/services/api_client.dart';

@injectable
class CommunityService {
  CommunityService(@Named('communityAPIUrl') String url)
      : _url = url,
        _apiClient = ApiClient(url);

  final String _url;
  final ApiClient _apiClient;

  Future<ActivitiesPagedModel> getActivities(
    String token,
    String keyword,
    int pageNumber,
    String? status,
    String? categoryIds,
    DateTime? startDate,
    DateTime? endDate,
    int minScrore,
    int maxScore,
  ) async {
    try {
      final Map<String, dynamic> queryParams = {
        "keyword": keyword,
        "page": pageNumber,
        "limit": PageLimit.activitiesLimit,
      };

      if (status != null) queryParams["status"] = status;
      if (categoryIds != null) queryParams["categoryIds"] = categoryIds;
      if (startDate != null) {
        queryParams["startDate"] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams["endDate"] = endDate.toIso8601String();
      queryParams["minScore"] = minScrore;
      queryParams["maxScore"] = maxScore;

      final response = await _apiClient.dio.get(
        "$_url/api/activities",
        queryParameters: queryParams,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final pagedActivities = ActivitiesPagedModel.fromJson(data);
        return pagedActivities;
      } else {
        throw Exception(
            "Failed to load activities: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching all activities: $e");
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories(
      String token, String keyword) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/categories",
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

  Future<List<AcademicYearModel>> getAcademicYears(String token) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/academic-year-activities",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final academicYears =
            data.map((e) => AcademicYearModel.fromJson(e)).toList();

        return academicYears;
      } else {
        throw Exception(
            "Failed to load academic year activities : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching all academic year activities: $e");
      rethrow;
    }
  }

  Future<UserInfoModel> getUserInfo(String token) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/users/me/info",
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
          await _apiClient.dio.post("$_url/api/activities/$idActivity/register",
              options: Options(headers: {
                "Authorization": "Bearer $token",
              }));

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      logger.e("Error regist activity: $e");
      rethrow;
    }
  }

  Future<UserActivitiesPagedModel> getUserActivities(
    String token,
    String keyword,
    String academicYearId,
    String? status,
    int pageNumber,
  ) async {
    try {
      final Map<String, dynamic> queryParams = {
        "keyword": keyword,
        "page": pageNumber,
        "academicYearId": academicYearId,
        "limit": PageLimit.activitiesLimit
      };
      if (status != null) queryParams["status"] = status;
      final response = await _apiClient.dio.get("$_url/api/my-activities",
          queryParameters: queryParams,
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;

        final data = responseData['data'];

        final userActivities = UserActivitiesPagedModel.fromJson(data);

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
          await _apiClient.dio.post("$_url/api/activities/$idActivity/cancel",
              options: Options(headers: {
                "Authorization": "Bearer $token",
                "Content-Type": "application/json",
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
          await _apiClient.dio.post("$_url/api/proofs/$idRegistration/submit",
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

  Future<ProofsPagedModel> getUserProofs(String token, String keyword,
      int pageNumber, String academicYearId, String? status) async {
    try {
      final Map<String, dynamic> queryParams = {
        "keyword": keyword,
        "page": pageNumber,
        "academicYearId": academicYearId,
        "limit": PageLimit.activitiesLimit
      };
      if (status != null) queryParams["status"] = status;
      final response = await _apiClient.dio.get("$_url/api/proofs/me",
          queryParameters: queryParams,
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;
        final data = responseData['data'];

        final pagedProofs = ProofsPagedModel.fromJson(data);

        return pagedProofs;
      } else {
        throw Exception(
            "Failed to load my proofs: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching my proofs: $e");
      rethrow;
    }
  }

  Future<List<UserProofModel>> getUserScores(
      String token, String keyword, String academicYearId) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/proofs/me",
          queryParameters: {
            "keyword": keyword,
            "academicYearId": academicYearId,
          },
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data']['scores'];

        final userProofs = data.map((e) => UserProofModel.fromJson(e)).toList();

        return userProofs;
      } else {
        throw Exception(
            "Failed to load my scores: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching my scores: $e");
      rethrow;
    }
  }
}
