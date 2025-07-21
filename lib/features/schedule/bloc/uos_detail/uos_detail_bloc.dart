import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/full_info_uos_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'uos_detail_event.dart';
part 'uos_detail_state.dart';

class UosDetailBloc extends Bloc<UosDetailEvent, UosDetailState> {
  final ScheduleRepository _repository;

  UosDetailBloc(this._repository) : super(UosDetailInitial()) {
    on<LoadFullInfoUosDetail>(_onLoadFullInfoUosDetail);
    on<LoadExamShiftDetail>(_onLoadExamShiftDetail);
  }

  Future<void> _onLoadFullInfoUosDetail(
      LoadFullInfoUosDetail event, Emitter<UosDetailState> emit) async {
    emit(UosDetailLoading());
    try {
      final idUos = event.idUos;
      final isTeacher = event.isTeacher;
      final fullInfoUosDetail =
          await _repository.getFullInfoUosDetail(idUos, isTeacher);

      emit(FullInfoUosLoaded(fullInfoUosDetail: fullInfoUosDetail));
    } catch (e) {
      emit(UosDetailError(message: e.toString()));
    }
  }

  Future<void> _onLoadExamShiftDetail(
      LoadExamShiftDetail event, Emitter<UosDetailState> emit) async {
    emit(UosDetailLoading());
    try {
      final idExamShift = event.idExamShift;
      final keyword = event.keyword;
      final pageNumber = event.pageNumber;
      final examShiftDetail =
          await _repository.getTeacherExamShiftDetail(idExamShift);

      final listStudents = await _repository.getListStudentsByExamShift(
          idExamShift, keyword, pageNumber);

      emit(ExamShiftDetailLoaded(
          examShiftDetail: examShiftDetail, listStudents: listStudents));
    } catch (e) {
      emit(UosDetailError(message: e.toString()));
    }
  }
}
