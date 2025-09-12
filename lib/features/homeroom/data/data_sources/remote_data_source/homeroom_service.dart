import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/core/services/api_client.dart';
import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeroomService {
  HomeroomService(@Named('homeroomAPIUrl') String url)
      : _url = url,
        _apiClient = ApiClient(url);

  final String _url;
  final ApiClient _apiClient;

  Future<List<StudentModel>> getStudents(String token, String classId) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/students",
          queryParameters: {"classId": classId},
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['isSuccess'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final students = data.map((e) => StudentModel.fromJson(e)).toList();

        return students;
      } else {
        throw Exception(
            "Failed to load students of homeroom: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching students of homeroom: $e");
      rethrow;
    }
  }

  Future<List<HomeroomModel>> getHomerooms(String token) async {
    try {
      final response = await _apiClient.dio.get("$_url/api/classActivities",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 && response.data['isSuccess'] == true) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final homerooms = data.map((e) => HomeroomModel(
            id: e['id'] ?? 'Unknown',
            name: e['name'] ?? 'Unknown',
            numStudent: e['numOfStudents'] ?? 0
        )).toList();

        return homerooms;
      } else {
        throw Exception(
            "Failed to load homerooms: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching homerooms: $e");
      rethrow;
    }
  }
}
