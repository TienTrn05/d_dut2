part of 'course_sections_bloc.dart';

enum AvailableCoursesStatus { initial, loading, success, failure }
enum RegisteredCoursesStatus { initial, loading, success, failure }

class CourseSectionsState extends Equatable {
  final AvailableCoursesStatus availableCoursesStatus;
  final List<CourseSection> courses;
  final String errorCourseSectionMessage;

  final RegisteredCoursesStatus registeredCoursesStatus;
  final List<RegisteredCourseSection> registeredCourses;
  final String errorRegisteredCoursesMessage;

  final RegistrationPhase registrationPhase;

  const CourseSectionsState({
    this.availableCoursesStatus = AvailableCoursesStatus.initial,
    this.registeredCoursesStatus = RegisteredCoursesStatus.initial,
    this.courses = const <CourseSection>[],
    this.registeredCourses = const <RegisteredCourseSection>[],
    this.errorCourseSectionMessage = '',
    this.errorRegisteredCoursesMessage = '',
    this.registrationPhase = RegistrationPhase.group,
  });

  CourseSectionsState copyWith({
    AvailableCoursesStatus Function()? availableCoursesStatus,
    RegisteredCoursesStatus Function()? registeredCoursesStatus,
    List<CourseSection> Function()? courses,
    List<RegisteredCourseSection> Function()? registeredCourses,
    String Function()? errorCourseSectionMessage,
    String Function()? errorRegisteredCoursesMessage,
    RegistrationPhase Function()? registrationPhase,
  }) {
    return CourseSectionsState(
      availableCoursesStatus: availableCoursesStatus != null ? availableCoursesStatus() : this.availableCoursesStatus,
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
      registrationPhase: registrationPhase != null
          ? registrationPhase()
          : this.registrationPhase,
    );
  }

  @override
  List<Object?> get props => [
    availableCoursesStatus,
    registeredCoursesStatus,
    courses,
    registeredCourses,
    errorCourseSectionMessage,
    errorRegisteredCoursesMessage,
    registrationPhase,
  ];
}
