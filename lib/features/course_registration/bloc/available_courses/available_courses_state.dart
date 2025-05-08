part of 'available_courses_bloc.dart';

enum AvailableCoursesStatus { initial, loading, success, failure }

class AvailableCoursesState extends Equatable {
  final AvailableCoursesStatus status;
  final List<CourseSection> courses;
  final String errorMessage;

  const AvailableCoursesState({
    this.status = AvailableCoursesStatus.initial,
    this.courses = const <CourseSection>[],
    this.errorMessage = '',
  });

  AvailableCoursesState copyWith({
    AvailableCoursesStatus Function()? status,
    List<CourseSection> Function()? courses,
    String Function()? errorMessage,
  }) {
    return AvailableCoursesState(
      status: status != null ? status() : this.status,
      courses: courses != null ? courses() : this.courses,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    courses,
    errorMessage,
  ];
}
