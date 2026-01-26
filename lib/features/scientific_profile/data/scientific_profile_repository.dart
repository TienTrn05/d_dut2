import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import '../models/scientific_profile_model.dart';

@lazySingleton
class ScientificProfileRepository {
  final Dio _dio = Dio();

  Future<ScientificProfileModel> getProfile(String microsoftEmail) async {
    try {
      final String baseUrl = dotenv.env['SCIENTIFIC_PROFILE_API_BASE'] ?? '';

      final response = await _dio.get(
        baseUrl,
        queryParameters: {'microsoftEmail': microsoftEmail},
      );

      if (response.data['state'] == true) {
        return ScientificProfileModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi từ máy chủ');
      }
    } catch (e) {
      throw Exception('Không thể tải lý lịch khoa học: $e');
    }
  }
}
