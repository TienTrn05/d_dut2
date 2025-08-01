import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/common/utils/logger.dart';
import '../../models/grade.dart';

@injectable
class GradeService {
  final String _url;
  final Dio _dio;

  GradeService(@Named('courseRegistrationGradeAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<Grade>> getMyGrades(
    String token,
  ) async {
    try {
      final response = await _dio.get("$_url/api/StudentGrades/me",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<Grade> grades =
            (data as List).map((grade) => Grade.fromJson(grade)).toList();

        return grades;
      } else {
        throw Exception("Failed to load courses: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching grades: $e");
      rethrow;
    }
  }
}
