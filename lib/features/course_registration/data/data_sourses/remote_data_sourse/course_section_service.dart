import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/common/utils/logger.dart';

import '../../models/course_section.dart';
import '../../models/registered_course_section.dart';

@injectable
class CourseSectionService {
  final String _url;
  final Dio _dio;

  CourseSectionService(@Named('courseRegistrationAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<CourseSection>> getAvailableCourses(
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
        final data = response.data['data'];

        final List<RegisteredCourseSection> courses = (data as List)
            .map((course) => RegisteredCourseSection.fromJson(course))
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
      if (response.statusCode == 200) {
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
      if (response.statusCode == 200) {
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
