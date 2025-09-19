import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/profile_repository.dart';
import '../../data/model/student_profile_model.dart';

part 'student_profile_event.dart';
part 'student_profile_state.dart';

class StudentProfileBloc
    extends Bloc<StudentProfileEvent, StudentProfileState> {
  final ProfileRepository repository;

  StudentProfileBloc({required this.repository})
      : super(StudentProfileState()) {
    on<LoadStudentProfile>(_onLoadStudentProfile);
  }

  Future<void> _onLoadStudentProfile(
      LoadStudentProfile event, Emitter<StudentProfileState> emit) async {
    emit(state.copyWith(
        studentProfileStatus: () => StudentProfileStatus.loading));

    try {
      final profile = await repository.getStudentProfile(event.token);
      emit(state.copyWith(
        studentProfileStatus: () => StudentProfileStatus.success,
        profile: () => profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        studentProfileStatus: () => StudentProfileStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }
}
