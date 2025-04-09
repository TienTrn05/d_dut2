import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final ScheduleRepository _repository;

  TimetableBloc(this._repository) : super(TimetableInitial()) {
    on<LoadListSemesters>(_onLoadListSemesters);
  }
  Future<void> _onLoadListSemesters(
      LoadListSemesters event, Emitter<TimetableState> emit) async {
    emit(TimetableLoading());
    try {
      final semesters = await _repository.getListSemester();
      debugPrint('[TimetableBloc] Loaded ${semesters.length} semesters');
      emit(SemesterListLoaded(semesters));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }
}
