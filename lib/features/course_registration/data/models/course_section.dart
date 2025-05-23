import 'course.dart';
import 'lecturer.dart';

class CourseSection {
  final String id;
  final String courseSectionCode;
  final String courseName;
  final int capacity;
  final int registeredCount;
  final String lecturerId;
  final String scheduleGroup;
  final String schedule;
  final String facultyId;
  final String courseSymbol;
  final String courseCodeExtracted;
  final String academicYearCode;
  final String enrollmentYear;
  final String sectionCode;
  final Course course;
  final Lecturer lecturer;

  CourseSection({
    required this.id,
    required this.courseSectionCode,
    required this.courseName,
    required this.capacity,
    required this.registeredCount,
    required this.lecturerId,
    required this.scheduleGroup,
    required this.schedule,
    required this.facultyId,
    required this.courseSymbol,
    required this.courseCodeExtracted,
    required this.academicYearCode,
    required this.enrollmentYear,
    required this.sectionCode,
    required this.course,
    required this.lecturer,
  });

  String get courseSectionCodeSplited {
    return "${courseSectionCode.substring(0, 7)}.${courseSectionCode.substring(7, 11)}.${courseSectionCode.substring(11, 13)}.${courseSectionCode.substring(13, courseSectionCode.length)}";
  }

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'],
      courseSectionCode: json['courseSectionCode'],
      courseName: json['courseName'],
      capacity: json['capacity'],
      registeredCount: json['registeredCount'],
      lecturerId: json['lecturerId'],
      scheduleGroup: json['scheduleGroup'],
      schedule: json['schedule'] ?? '',
      facultyId: json['facultyId'],
      courseSymbol: json['courseSymbol'],
      courseCodeExtracted: json['courseCodeExtracted'],
      academicYearCode: json['academicYearCode'],
      enrollmentYear: json['enrollmentYear'],
      sectionCode: json['sectionCode'],
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      lecturer: Lecturer.fromJson(json['lecturer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseSectionCode': courseSectionCode,
      'courseName': courseName,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'lecturerId': lecturerId,
      'scheduleGroup': scheduleGroup,
      'schedule': schedule,
      'facultyId': facultyId,
      'courseSymbol': courseSymbol,
      'courseCodeExtracted': courseCodeExtracted,
      'academicYearCode': academicYearCode,
      'enrollmentYear': enrollmentYear,
      'sectionCode': sectionCode,
    };
  }

  static Map<Course, List<CourseSection>> groupByCourse(List<CourseSection> sections) {
    final Map<Course, List<CourseSection>> grouped = {};

    for (final section in sections) {
      final course = section.course;
      if (grouped.containsKey(course)) {
        grouped[course]!.add(section);
      } else {
        grouped[course] = [section];
      }
    }

    return grouped;
  }
}
