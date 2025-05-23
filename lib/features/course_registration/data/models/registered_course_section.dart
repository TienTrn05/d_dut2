import 'course.dart';
import 'lecturer.dart';

class RegisteredCourseSection {
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
  final bool isRegistering;

  RegisteredCourseSection({
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
    required this.isRegistering,
  });

  String get courseSectionCodeSplited {
    return "${courseSectionCode.substring(0, 7)}.${courseSectionCode.substring(7, 11)}.${courseSectionCode.substring(11, 13)}.${courseSectionCode.substring(13, courseSectionCode.length)}";
  }

  factory RegisteredCourseSection.fromJson(Map<String, dynamic> json) {
    return RegisteredCourseSection(
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
      isRegistering: json['isRegistering'] ?? false,
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
      'course': course.toJson(),
      'lecturer': lecturer.toJson(),
      'isRegistering': isRegistering,
    };
  }

  static Map<Course, List<RegisteredCourseSection>> groupByCourse(List<RegisteredCourseSection> sections) {
    final Map<Course, List<RegisteredCourseSection>> grouped = {};

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
