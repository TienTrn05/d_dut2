import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/utils/logger.dart';
import '../../data/models/course_section.dart';
import '../../data/models/course_section_response.dart';
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
    emit(state.copyWith(registrationStatus: () => RegistrationStatus.initial));
    try {
      emit(state.copyWith(
          availableCoursesStatus: () => AvailableCoursesStatus.loading));
      final res = await courseRepository.fetchAvailableCourses(event.token);
      emit(
        state.copyWith(
          availableCoursesStatus: () => AvailableCoursesStatus.success,
          courses: () => res.courseSections,
          registrationPhase: () => res.registrationPhase,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
          availableCoursesStatus: () => AvailableCoursesStatus.failure,
          errorCourseSectionMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onFetchRegisteredCourses(
      RegisteredCourseSectionSubscriptionRequested event,
      Emitter<CourseSectionsState> emit) async {
    emit(state.copyWith(registrationStatus: () => RegistrationStatus.initial));
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
    emit(state.copyWith(registrationStatus: () => RegistrationStatus.loading));

    try {
      await courseRepository.registerCourse(event.token, event.courseSectionId);

      final results = await Future.wait([
        courseRepository.fetchAvailableCourses(event.token),
        courseRepository.fetchMyCourses(event.token),
      ]);

      final availableCoursesResponse = results[0]
          as CourseSectionResponse;
      final registeredCourses = results[1] as List<
          RegisteredCourseSection>;

      emit(state.copyWith(
        registrationStatus: () => RegistrationStatus.success,
        registrationMessage: () => "Yêu cầu đăng ký khóa học thành công!",

        availableCoursesStatus: () => AvailableCoursesStatus.success,
        courses: () => availableCoursesResponse.courseSections,
        registrationPhase: () => availableCoursesResponse.registrationPhase,

        registeredCoursesStatus: () => RegisteredCoursesStatus.success,
        registeredCourses: () => registeredCourses,
      ));
    } catch (e) {
      logger.e("Error in register course flow: $e");

      emit(state.copyWith(
        registrationStatus: () => RegistrationStatus.failure,
        errorCourseSectionMessage: () =>
            "Đăng ký khóa học hoặc làm mới dữ liệu thất bại. Vui lòng thử lại!",
      ));
    }
  }

  Future<void> _onUnregisterCourse(
  UnregisterCourseRequested event, Emitter<CourseSectionsState> emit) async {

  emit(state.copyWith(registrationStatus: () => RegistrationStatus.loading));

  try {
    await courseRepository.unregisterCourse(event.token, event.courseSectionId);

    final results = await Future.wait([
      courseRepository.fetchMyCourses(event.token),
      courseRepository.fetchAvailableCourses(event.token),
    ]);

    // Trích xuất kết quả từ Future.wait
    final registeredCourses = results[0] as List<RegisteredCourseSection>;
    final availableCoursesResponse = results[1] as CourseSectionResponse;

    emit(state.copyWith(
      registrationStatus: () => RegistrationStatus.success,
      registrationMessage: () => "Yêu cầu hủy đăng ký khóa học thành công!",
      
      registeredCoursesStatus: () => RegisteredCoursesStatus.success,
      registeredCourses: () => registeredCourses,

      availableCoursesStatus: () => AvailableCoursesStatus.success,
      courses: () => availableCoursesResponse.courseSections,
      registrationPhase: () => availableCoursesResponse.registrationPhase,
    ));

  } catch (e) {
    logger.e("Error in unregister course flow: $e");
    
    emit(state.copyWith(
      registrationStatus: () => RegistrationStatus.failure,
      registrationMessage: () => "Hủy đăng ký khóa học hoặc làm mới dữ liệu thất bại!",
    ));
  }
}
}
