import 'package:dio/dio.dart';
import 'package:e_dut/features/course_registration/data/models/course_section.dart';
import 'package:injectable/injectable.dart';

import '../../../../../common/utils/logger.dart';

@injectable
class CourseSectionService {
  final String _url;
  final Dio _dio;

  CourseSectionService(@Named('courseRegistrationAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<CourseSection>> getAvailableCourses(
    String studentCardNumber,
    String academicYearCode,
  ) async {
    try {
      final response = await _dio.get("$_url/api/CourseSections/student?studentCardNumber=$studentCardNumber&academicYearCode=$academicYearCode");
      if (response.statusCode == 200) {
        final data = response.data;

        final List<CourseSection> courses = (data as List)
            .map((course) => CourseSection.fromJson(course))
            .toList();
        return courses;
      } else {
        throw Exception("Failed to load courses: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching available courses: $e");
      rethrow;
    }
  }
}