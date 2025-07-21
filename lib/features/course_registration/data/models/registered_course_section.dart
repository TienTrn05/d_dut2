import 'course.dart';
import 'lecturer.dart';

class RegisteredCourseSection {
  final String id;
  final String courseName;
  final int capacity;
  final int registeredCount;
  final String lecturerId;
  final String scheduleGroup;
  final String schedule;
  final String studyWeeks;
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
    required this.courseName,
    required this.capacity,
    required this.registeredCount,
    required this.lecturerId,
    required this.scheduleGroup,
    required this.schedule,
    required this.studyWeeks,
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

  String get courseSectionIdSplited {
    return "${id.substring(0, 7)}.${id.substring(7, 11)}.${id.substring(11, 13)}.${id.substring(13, id.length)}";
  }

  factory RegisteredCourseSection.fromJson(Map<String, dynamic> json) {
    return RegisteredCourseSection(
      id: json['courseSection']['id'],
      courseName: json['courseSection']['courseName'],
      capacity: json['courseSection']['capacity'],
      registeredCount: json['courseSection']['registeredCount'],
      lecturerId: json['courseSection']['lecturerId'],
      scheduleGroup: json['courseSection']['scheduleGroup'],
      schedule: json['courseSection']['schedule'] ?? '',
      studyWeeks: json['courseSection']['studyWeeks'] ?? '',
      facultyId: json['courseSection']['facultyId'],
      courseSymbol: json['courseSection']['courseSymbol'],
      courseCodeExtracted: json['courseSection']['courseCodeExtracted'],
      academicYearCode: json['courseSection']['academicYearCode'],
      enrollmentYear: json['courseSection']['enrollmentYear'],
      sectionCode: json['courseSection']['sectionCode'],
      course: Course.fromJson(json['courseSection']['course'] as Map<String, dynamic>),
      lecturer: Lecturer.fromJson(json['courseSection']['lecturer'] as Map<String, dynamic>),
      isRegistering: json['isRegistering'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'lecturerId': lecturerId,
      'scheduleGroup': scheduleGroup,
      'schedule': schedule,
      'studyWeeks': studyWeeks,
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
