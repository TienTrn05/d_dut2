import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/domain/repositories/course_section_repository.dart';
import '../../data/models/course_section.dart';

part 'available_courses_event.dart';
part 'available_courses_state.dart';

class AvailableCoursesBloc
    extends Bloc<AvailableCoursesEvent, AvailableCoursesState> {
  final CourseSectionRepository courseRepository;

  AvailableCoursesBloc({required this.courseRepository})
      : super(AvailableCoursesState()) {
    on<AvailableCoursesSubscriptionRequested>(_onFetchAvailableCourses);
  }

  Future<void> _onFetchAvailableCourses(
      AvailableCoursesSubscriptionRequested event,
      Emitter<AvailableCoursesState> emit) async {
    emit(AvailableCoursesState());
    try {
      emit(AvailableCoursesState(status: AvailableCoursesStatus.loading));
      final courses = await courseRepository.fetchAvailableCourses(
          event.studentCardNumber, event.academicYearCode
      );
      emit(AvailableCoursesState(
          status: AvailableCoursesStatus.success, courses: courses));
    } catch (e) {
      emit(AvailableCoursesState(
          status: AvailableCoursesStatus.failure, errorMessage: "Đã có lỗi xảy ra!"));
    }
  }
}
