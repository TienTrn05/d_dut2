import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/profile_repository.dart';
import '../../data/model/teacher_profile_model.dart';

part 'teacher_profile_event.dart';
part 'teacher_profile_state.dart';

class TeacherProfileBloc
    extends Bloc<TeacherProfileEvent, TeacherProfileState> {
  final ProfileRepository repository;

  TeacherProfileBloc({required this.repository})
      : super(TeacherProfileState()) {
    on<LoadTeacherProfile>(_onLoadTeacherProfile);
  }

  Future<void> _onLoadTeacherProfile(
      LoadTeacherProfile event, Emitter<TeacherProfileState> emit) async {
    emit(state.copyWith(
        teacherProfileStatus: () => TeacherProfileStatus.loading));

    try {
      final profile = await repository.getTeacherProfile(event.token);
      emit(state.copyWith(
        teacherProfileStatus: () => TeacherProfileStatus.success,
        profile: () => profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        teacherProfileStatus: () => TeacherProfileStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }
}
