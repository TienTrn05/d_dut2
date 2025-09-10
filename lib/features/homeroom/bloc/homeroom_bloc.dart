import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/domain/repository/homeroom_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'homeroom_event.dart';
part 'homeroom_state.dart';

class HomeroomBloc extends Bloc<HomeroomEvent, HomeroomState> {
  final HomeroomRepository _repository;

  HomeroomBloc(this._repository) : super(HomeroomInitial()) {
    on<LoadStudentsOfHomeroom>(_onLoadStudentsOfHomeroom);
  }

  Future<void> _onLoadStudentsOfHomeroom(
      LoadStudentsOfHomeroom event, Emitter<HomeroomState> emit) async {
    emit(HomeroomLoading());

    try {
      final token = event.token;
      final classId = event.classId;

      final students = await _repository.getStudents(token, classId);

      emit(HomeroomLoaded(students: students));
    } catch (e) {
      emit(HomeroomError(e.toString()));
    }
  }
}
