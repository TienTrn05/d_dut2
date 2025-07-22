import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/common/utils/logger.dart';

import '../../models/registered_course_section.dart';
import '../../models/course_section_response.dart';

@injectable
class CourseSectionService {
  final String _url;
  final Dio _dio;

  CourseSectionService(@Named('courseRegistrationAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<CourseSectionResponse> getAvailableCourses(
    String token,
  ) async {
    try {
      final response = await _dio.get(
          "$_url/api/CourseSections/available",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200) {
        final data = response.data['data'];

        final CourseSectionResponse courseSectionResponse =
            CourseSectionResponse.fromJson(data);

        return courseSectionResponse;
      } else {
        throw Exception("Failed to load courses: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching available courses: $e");
      rethrow;
    }
  }

  Future<List<RegisteredCourseSection>> getMyCourses(
    String token,
  ) async {
    try {
      final response = await _dio.get(
          "$_url/api/CourseSections/me",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200) {
        final data = response.data['data']['courseSections'];

        final List<RegisteredCourseSection> courses = (data as List)
            .map((course) => RegisteredCourseSection.fromJson(course))
            .toList();
        return courses;
      } else {
        throw Exception("Failed to load courses: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching my courses: $e");
      rethrow;
    }
  }

  Future<bool> registerCourse(
    String token,
    String courseSectionId,
  ) async {
    try {
      final response = await _dio.post(
          "$_url/api/CourseSections/register",
          data: {
            "courseSectionId": courseSectionId,
          },
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      } else {
        throw Exception("Failed to register course: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error registering course: $e");
      rethrow;
    }
  }

  Future<bool> unregisterCourse(
    String token,
    String courseSectionId,
  ) async {
    try {
      final response = await _dio.post(
          "$_url/api/CourseSections/unregister",
          data: {
            "courseSectionId": courseSectionId,
          },
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      } else {
        throw Exception("Failed to unregister course: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error unregistering course: $e");
      rethrow;
    }
  }
}
