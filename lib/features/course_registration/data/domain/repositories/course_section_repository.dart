import 'package:injectable/injectable.dart';

import '../../data_sourses/remote_data_sourse/course_section_service.dart';
import '../../models/course_section.dart';

@injectable
class CourseSectionRepository {
  final CourseSectionService _courseService;

  CourseSectionRepository(this._courseService);

  Future<List<CourseSection>> fetchAvailableCourses(
    String studentCardNumber,
    String academicYearCode,
  ) async {
    try {
      final courses = await _courseService.getAvailableCourses(
        studentCardNumber,
        academicYearCode,
      );
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }
}