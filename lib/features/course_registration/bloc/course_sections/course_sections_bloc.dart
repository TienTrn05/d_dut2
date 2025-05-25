import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/course_section.dart';
import '../../data/models/registered_course_section.dart';
import '../../domain/repositories/course_section_repository.dart';

part 'course_sections_event.dart';
part 'course_sections_state.dart';

class CourseSectionsBloc
    extends Bloc<CourseSectionsEvent, CourseSectionsState> {
  final CourseSectionRepository courseRepository;

  CourseSectionsBloc({required this.courseRepository})
      : super(const CourseSectionsState()) {
    on<AvailableCourseSectionsSubscriptionRequested>(_onFetchAvailableCourses);
    on<RegisteredCourseSectionSubscriptionRequested>(_onFetchRegisteredCourses);
    on<RegisterCourseRequested>(_onRegisterCourse);
    on<UnregisterCourseRequested>(_onUnregisterCourse);
  }

  Future<void> _onFetchAvailableCourses(
      AvailableCourseSectionsSubscriptionRequested event,
      Emitter<CourseSectionsState> emit) async {
    try {
      emit(state.copyWith(status: () => AvailableCoursesStatus.loading));
      final courses = await courseRepository.fetchAvailableCourses(event.token);
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.success,
          courses: () => courses,),
          );
    } catch (e) {
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.failure,
          errorCourseSectionMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onFetchRegisteredCourses(
      RegisteredCourseSectionSubscriptionRequested event,
      Emitter<CourseSectionsState> emit) async {
    try {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.loading));
      final courses = await courseRepository.fetchMyCourses(event.token);
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.success,
          registeredCourses: () => courses));
    } catch (e) {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.failure,
          errorRegisteredCoursesMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onRegisterCourse(
      RegisterCourseRequested event, Emitter<CourseSectionsState> emit) async {
    try {
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.loading));
      await courseRepository.registerCourse(
          event.token, event.courseSectionId);
      final courses = await courseRepository.fetchAvailableCourses(event.token);
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.success,
          courses: () => courses));
    } catch (e) {
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.failure,
          errorCourseSectionMessage: () => "Đã có lỗi xảy ra!"));
    }

    // Refresh registered courses after registration
    try {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.loading));
      final registeredCourses =
          await courseRepository.fetchMyCourses(event.token);
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.success,
          registeredCourses: () => registeredCourses));
    } catch (e) {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.failure,
          errorRegisteredCoursesMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onUnregisterCourse(
      UnregisterCourseRequested event, Emitter<CourseSectionsState> emit) async {
    try {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.loading));
      await courseRepository.unregisterCourse(
          event.token, event.courseSectionId);
      final courses = await courseRepository.fetchMyCourses(event.token);
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.success,
          registeredCourses: () => courses));
    } catch (e) {
      emit(state.copyWith(
          registeredCoursesStatus: () => RegisteredCoursesStatus.failure,
          errorRegisteredCoursesMessage: () => "Đã có lỗi xảy ra!"));
    }

    // Refresh available courses after unregistration
    try {
      emit(state.copyWith(status: () => AvailableCoursesStatus.loading));
      final courses = await courseRepository.fetchAvailableCourses(event.token);
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.success,
          courses: () => courses));
    } catch (e) {
      emit(state.copyWith(
          status: () => AvailableCoursesStatus.failure,
          errorCourseSectionMessage: () => "Đã có lỗi xảy ra!"));
    }
  }
}
