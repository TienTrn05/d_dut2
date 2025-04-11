import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/uos_item_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final ScheduleRepository _repository;

  final Map<String, List<UosItemModel>> _uosCache = {};
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

      // Mặc định chọn học kỳ đầu tiên
      final selectedIndex = 0;
      final selectedSemester = semesters[selectedIndex];

      final listUOS =
          await _repository.getListUOSBySemester(selectedSemester.idSemester);

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

        // Nếu đã có cache, dùng lại
        if (_uosCache.containsKey(idSemester)) {
          emit(TimetableDataLoaded(
            semesters,
            _uosCache[idSemester]!,
            index,
          ));
        } else {
          // Gọi API lấy mới
          final listUOS = await _repository.getListUOSBySemester(idSemester);
          _uosCache[idSemester] = listUOS; // Lưu cache

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
