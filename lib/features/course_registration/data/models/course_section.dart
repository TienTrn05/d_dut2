import 'course.dart';
import 'lecturer.dart';

class CourseSection {
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
  final bool canRegister;
  final Course course;
  final Lecturer lecturer;

  CourseSection({
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
    required this.canRegister,
    required this.course,
    required this.lecturer,
  });

  String get courseSectionIdSplited {
    return "${id.substring(0, 7)}.${id.substring(7, 11)}.${id.substring(11, 13)}.${id.substring(13, id.length)}";
  }

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'],
      courseName: json['courseName'],
      capacity: json['capacity'],
      registeredCount: json['registeredCount'],
      lecturerId: json['lecturerId'],
      scheduleGroup: json['scheduleGroup'],
      schedule: json['schedule'] ?? '',
      studyWeeks: json['studyWeeks'] ?? '',
      facultyId: json['facultyId'],
      courseSymbol: json['courseSymbol'],
      courseCodeExtracted: json['courseCodeExtracted'],
      academicYearCode: json['academicYearCode'],
      enrollmentYear: json['enrollmentYear'],
      sectionCode: json['sectionCode'],
      canRegister: json['canRegister'] ?? false,
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      lecturer: Lecturer.fromJson(json['lecturer'] as Map<String, dynamic>),
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
      'canRegister': canRegister,
    };
  }

  static Map<Course, List<CourseSection>> groupByCourse(
      List<CourseSection> sections) {
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

  static Map<String, List<CourseSection>> groupByScheduleGroup(
      List<CourseSection> sections) {
    final Map<String, List<CourseSection>> grouped = {};

    for (final section in sections) {
      final group = section.scheduleGroup;
      if (grouped.containsKey(group)) {
        grouped[group]!.add(section);
      } else {
        grouped[group] = [section];
      }
    }

    return grouped;
  }
}
