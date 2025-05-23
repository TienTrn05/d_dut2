part of 'course_sections_bloc.dart';

enum AvailableCoursesStatus { initial, loading, success, failure }
enum RegisteredCoursesStatus { initial, loading, success, failure }

class CourseSectionsState extends Equatable {
  final AvailableCoursesStatus status;
  final List<CourseSection> courses;
  final String errorCourseSectionMessage;

  final RegisteredCoursesStatus registeredCoursesStatus;
  final List<RegisteredCourseSection> registeredCourses;
  final String errorRegisteredCoursesMessage;

  const CourseSectionsState({
    this.status = AvailableCoursesStatus.initial,
    this.registeredCoursesStatus = RegisteredCoursesStatus.initial,
    this.courses = const <CourseSection>[],
    this.registeredCourses = const <RegisteredCourseSection>[],
    this.errorCourseSectionMessage = '',
    this.errorRegisteredCoursesMessage = '',
  });

  CourseSectionsState copyWith({
    AvailableCoursesStatus Function()? status,
    RegisteredCoursesStatus Function()? registeredCoursesStatus,
    List<CourseSection> Function()? courses,
    List<RegisteredCourseSection> Function()? registeredCourses,
    String Function()? errorCourseSectionMessage,
    String Function()? errorRegisteredCoursesMessage,
  }) {
    return CourseSectionsState(
      status: status != null ? status() : this.status,
      registeredCoursesStatus: registeredCoursesStatus != null
          ? registeredCoursesStatus()
          : this.registeredCoursesStatus,
      courses: courses != null ? courses() : this.courses,
      registeredCourses: registeredCourses != null
          ? registeredCourses()
          : this.registeredCourses,
      errorCourseSectionMessage: errorCourseSectionMessage != null
          ? errorCourseSectionMessage()
          : this.errorCourseSectionMessage,
      errorRegisteredCoursesMessage: errorRegisteredCoursesMessage != null
          ? errorRegisteredCoursesMessage()
          : this.errorRegisteredCoursesMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    registeredCoursesStatus,
    courses,
    registeredCourses,
    errorCourseSectionMessage,
    errorRegisteredCoursesMessage,
  ];
}
