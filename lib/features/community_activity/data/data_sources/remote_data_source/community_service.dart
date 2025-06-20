import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/data/model/category_model.dart';
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
}
