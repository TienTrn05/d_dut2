part of 'course_sections_bloc.dart';

sealed class CourseSectionsEvent extends Equatable {
  const CourseSectionsEvent();

  @override
  List<Object> get props => [];
}

class AvailableCourseSectionsSubscriptionRequested extends CourseSectionsEvent {
  final String token;

  const AvailableCourseSectionsSubscriptionRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}

class RegisteredCourseSectionSubscriptionRequested
    extends CourseSectionsEvent {
  final String token;

  const RegisteredCourseSectionSubscriptionRequested({
    required this.token,
  });

  @override
  List<Object> get props => [token];
}

class RegisterCourseRequested extends CourseSectionsEvent {
  final String token;
  final String courseSectionId;

  const RegisterCourseRequested({
    required this.token,
    required this.courseSectionId,
  });

  @override
  List<Object> get props => [token, courseSectionId];
}

class UnregisterCourseRequested extends CourseSectionsEvent {
  final String token;
  final String courseSectionId;

  const UnregisterCourseRequested({
    required this.token,
    required this.courseSectionId,
  });

  @override
  List<Object> get props => [token, courseSectionId];
}