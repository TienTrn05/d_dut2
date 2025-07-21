import 'dart:collection';

import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final ScheduleRepository _repository;

  final int _cacheLimit = 5;
  final LinkedHashMap<String, List<UosItemModel>> _uosCache = LinkedHashMap();

  int selectedIndex = 0;

  TimetableBloc(this._repository) : super(TimetableInitial()) {
    on<LoadListSemesters>(_onLoadListSemesters);
    on<LoadListUOSBySemester>(_onLoadListUOSBySemester);
  }
  Future<void> _onLoadListSemesters(
      LoadListSemesters event, Emitter<TimetableState> emit) async {
    emit(TimetableLoading());
    try {
      final semesters = await _repository.getListSemester();

      if (semesters.isEmpty) {
        emit(TimetableError("Không có học kỳ nào."));
        return;
      }

      final currentIdSemester =
          await _repository.getSemesterByDate(DateTime.now());
      final updatedSemesters = semesters.map((s) {
        return SemesterModel(
            idSemester: s.idSemester,
            noSemester: s.noSemester,
            startYear: s.startYear,
            endYear: s.endYear,
            isCurrentSemester: s.idSemester == currentIdSemester);
      }).toList();

      final selectedIndex =
          updatedSemesters.indexWhere((s) => s.isCurrentSemester) >= 0
              ? updatedSemesters.indexWhere((s) => s.isCurrentSemester)
              : 0;
      final selectedSemester = updatedSemesters[selectedIndex];
      final isTeacher = event.isTeacher;
      final listUOS = await _repository.getListUOSBySemester(
          selectedSemester.idSemester, isTeacher);

      emit(TimetableDataLoaded(semesters, listUOS, selectedIndex));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onLoadListUOSBySemester(
      LoadListUOSBySemester event, Emitter<TimetableState> emit) async {
    try {
      final currentState = state;

      if (currentState is TimetableDataLoaded) {
        final semesters = currentState.semesters;
        final index = event.selectedIndex;

        final idSemester = event.idSemester;
        final isTeacher = event.isTeacher;

        if (_uosCache.containsKey(idSemester)) {
          emit(TimetableDataLoaded(
            semesters,
            _uosCache[idSemester]!,
            index,
          ));
        } else {
          final listUOS =
              await _repository.getListUOSBySemester(idSemester, isTeacher);
          if (_uosCache.length >= _cacheLimit) {
            _uosCache.remove(_uosCache.keys.first);
          }

          _uosCache[idSemester] = listUOS;

          emit(TimetableDataLoaded(
            semesters,
            listUOS,
            index,
          ));
        }
      }
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }
}
