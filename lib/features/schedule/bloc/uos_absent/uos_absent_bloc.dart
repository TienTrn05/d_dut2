import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_state.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UosAbsentBloc extends Bloc<UosAbsentEvent, UosAbsentState> {
  final ScheduleRepository _repository;
  UosAbsentBloc(this._repository) : super(UosAbsentInitial()) {
    on<LoadStudentsAbsent>(_onLoadStudentAbsent);
    on<LoadIsAttendanceDate>(_onLoadIsAttendanceDate);
  }

  Future<void> _onLoadStudentAbsent(
      LoadStudentsAbsent event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final pageNumber = event.pageNumber;
      final keyword = event.keyword;
      final absenceDate = event.absenceDate;
      final listStudentAbsent = await _repository.getListStudentsByUos(
          idUos, pageNumber, keyword, absenceDate);

      print("===>>> listStudentAbsent: ${listStudentAbsent}");
      emit(UosAbsentLoaded(listStudentAbsent: listStudentAbsent));
    } catch (e) {
      print("===>>> Error: $e");
      emit(UosAbsentError(message: e.toString()));
    }
  }

  Future<void> _onLoadIsAttendanceDate(
      LoadIsAttendanceDate event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final attendanceDate = event.attendanceDate;
      final isAttendanceDate =
          await _repository.getIsAttendanceDate(idUos, attendanceDate!);
      emit(UosCheckIsAttendanceDateLoaded(isAttendanceDate: isAttendanceDate));
    } catch (e) {
      emit(UosAbsentError(message: e.toString()));
    }
  }
}
