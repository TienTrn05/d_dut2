part of 'available_courses_bloc.dart';

sealed class AvailableCoursesEvent extends Equatable {
  const AvailableCoursesEvent();

  @override
  List<Object> get props => [];
}

final class AvailableCoursesSubscriptionRequested extends AvailableCoursesEvent {
  final String studentCardNumber;
  final String academicYearCode;
  const AvailableCoursesSubscriptionRequested({
    required this.studentCardNumber,
    required this.academicYearCode,
  });
}