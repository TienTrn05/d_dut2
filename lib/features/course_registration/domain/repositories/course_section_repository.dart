import 'package:injectable/injectable.dart';

import '../../data/data_sourses/remote_data_sourse/course_section_service.dart';
import '../../data/models/course_section.dart';
import '../../data/models/registered_course_section.dart';

@injectable
class CourseSectionRepository {
  final CourseSectionService _courseService;

  CourseSectionRepository(this._courseService);

  Future<List<CourseSection>> fetchAvailableCourses(
    String token,
  ) async {
    try {
      final courses = await _courseService.getAvailableCourses(
        token
      );
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  Future<List<RegisteredCourseSection>> fetchMyCourses(
    String token,
  ) async {
    try {
      final courses = await _courseService.getMyCourses(
        token
      );
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  Future<void> registerCourse(
    String token,
    String courseSectionId,
  ) async {
    try {
      await _courseService.registerCourse(
        token,
        courseSectionId,
      );
    } catch (e) {
      throw Exception('Failed to register course: $e');
    }
  }

  Future<void> unregisterCourse(
    String token,
    String courseSectionId,
  ) async {
    try {
      await _courseService.unregisterCourse(
        token,
        courseSectionId,
      );
    } catch (e) {
      throw Exception('Failed to unregister course: $e');
    }
  }
}