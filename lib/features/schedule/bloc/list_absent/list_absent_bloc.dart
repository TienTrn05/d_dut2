import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_state.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListAbsentBloc extends Bloc<ListAbsentEvent, ListAbsentState> {
  final ScheduleRepository _repository;
  ListAbsentBloc(this._repository) : super(ListAbsentInitial()) {
    on<LoadListAbsent>(_onLoadListAbsent);
  }

  Future<void> _onLoadListAbsent(
      LoadListAbsent event, Emitter<ListAbsentState> emit) async {
    emit(ListAbsentLoading());
    try {
      final idUos = event.idUos;
      final idStudent = event.idStudent;
      final authToken = event.authToken;
      final listAbsentDate =
          await _repository.getListAbsentDate(idUos, idStudent, authToken);

      emit(ListAbsentLoaded(listAbsentDate: listAbsentDate));
    } catch (e) {
      emit(ListAbsentError(message: e.toString()));
    }
  }
}
