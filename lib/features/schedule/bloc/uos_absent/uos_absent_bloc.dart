import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_event.dart';
import 'package:e_dut/features/schedule/bloc/uos_absent/uos_absent_state.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UosAbsentBloc extends Bloc<UosAbsentEvent, UosAbsentState> {
  final ScheduleRepository _repository;
  UosAbsentBloc(this._repository) : super(UosAbsentInitial()) {
    on<LoadStudentsAbsent>(_onLoadStudentAbsent);
    on<LoadIsAttendanceDate>(_onLoadIsAttendanceDate);
    on<LoadIsAttendanceDateValid>(_onLoadIsAttendanceDateValid);
    on<TakeAttendance>(_onLoadTakeAttendance);
    on<DeleteAttendanceHistory>(_onLoadDeleteAttendanceHistory);
  }

  Future<void> _onLoadStudentAbsent(
      LoadStudentsAbsent event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final absenceDate = event.absenceDate;
      final authToken = event.authToken;
      final listStudentAbsent =
          await _repository.getListStudentsByUos(idUos, absenceDate, authToken);

      emit(UosAbsentLoaded(listStudentAbsent: listStudentAbsent));
    } catch (e) {
      emit(UosAbsentError(message: "Có lỗi xảy ra"));
    }
  }

  Future<void> _onLoadIsAttendanceDate(
      LoadIsAttendanceDate event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final attendanceDate = event.attendanceDate;
      final authToken = event.authToken;
      final isAttendanceDate = await _repository.getIsAttendanceDate(
          idUos, attendanceDate!, authToken);
      emit(UosCheckIsAttendanceDateLoaded(isAttendanceDate: isAttendanceDate));
    } catch (e) {
      emit(UosAbsentError(message: "Có lỗi xảy ra"));
    }
  }

  Future<void> _onLoadIsAttendanceDateValid(
      LoadIsAttendanceDateValid event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final attendanceDate = event.attendanceDate;
      final authToken = event.authToken;
      final isAttendanceDate = await _repository.getIsAttendanceDateValid(
          idUos, attendanceDate!, authToken);
      emit(UosCheckIsAttendanceDateValidLoaded(
          isAttendanceDateValid: isAttendanceDate));
    } catch (e) {
      emit(UosAbsentError(message: "Có lỗi xảy ra"));
    }
  }

  Future<void> _onLoadTakeAttendance(
      TakeAttendance event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUnitOfStudy = event.idUnitOfStudy;
      final absenceDate = event.absenceDate;
      final idStudentsAbsent = event.idStudentsAbsent;
      final authToken = event.authToken;
      final isSuccess = await _repository.takeAttendance(
          idUnitOfStudy, absenceDate, idStudentsAbsent, authToken);
      emit(UosTakeAttendanceLoaded(isSuccess: isSuccess));
    } catch (e) {
      emit(UosAbsentError(message: "Có lỗi xảy ra"));
    }
  }

  Future<void> _onLoadDeleteAttendanceHistory(
      DeleteAttendanceHistory event, Emitter<UosAbsentState> emit) async {
    emit(UosAbsentLoading());
    try {
      final idUos = event.idUos;
      final attendanceDate = event.attendanceDate;
      final authToken = event.authToken;
      final isSuccess = await _repository.deleteAttendanceHistory(
          idUos, attendanceDate, authToken);
      emit(UosDeleteAttendanceHistoryLoaded(isSuccess: isSuccess));
    } catch (e) {
      emit(UosAbsentError(message: "Có lỗi xảy ra"));
    }
  }
}
