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
    on<UpdateMsTeamsInfo>(_onUpdateMsTeamsInfo);
    on<CreateMsTeams>(_onCreateMsTeams);
  }

  Future<void> _onLoadFullInfoUosDetail(
    LoadFullInfoUosDetail event,
    Emitter<UosDetailState> emit,
  ) async {
    emit(UosDetailLoading());
    try {
      final idUos = event.idUos;
      final isTeacher = event.isTeacher;
      final authToken = event.authToken;

      final fullInfoUosDetail = await _repository.getFullInfoUosDetail(
        idUos,
        isTeacher,
        authToken,
      );

      emit(FullInfoUosLoaded(fullInfoUosDetail: fullInfoUosDetail));
    } catch (e) {
      emit(UosDetailError(message: e.toString()));
    }
  }

  Future<void> _onLoadExamShiftDetail(
    LoadExamShiftDetail event,
    Emitter<UosDetailState> emit,
  ) async {
    emit(UosDetailLoading());
    try {
      final idExamShift = event.idExamShift;
      final authToken = event.authToken;

      final examShiftDetail = await _repository.getTeacherExamShiftDetail(
        idExamShift,
        authToken,
      );

      final listStudents = await _repository.getListStudentsByExamShift(
        idExamShift,
        authToken,
      );

      emit(
        ExamShiftDetailLoaded(
          examShiftDetail: examShiftDetail,
          examShiftWithStudents: listStudents,
        ),
      );
    } catch (e) {
      emit(UosDetailError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMsTeamsInfo(
    UpdateMsTeamsInfo event,
    Emitter<UosDetailState> emit,
  ) async {
    emit(UosDetailLoading());
    try {
      final idUos = event.idUos;
      final isTeacher = event.isTeacher;
      final authToken = event.authToken;
      final msTeamCode = event.msTeamCode;
      final msTeamLink = event.msTeamLink;

      final isUpdateSuccess = await _repository.updateMsTeamsInfo(
        authToken,
        idUos,
        msTeamCode,
        msTeamLink,
      );

      if (isUpdateSuccess) {
        try {
          final fullInfoUosDetail = await _repository.getFullInfoUosDetail(
            idUos,
            isTeacher,
            authToken,
          );

          emit(FullInfoUosLoaded(fullInfoUosDetail: fullInfoUosDetail));
        } catch (e) {
          emit(UosDetailError(message: e.toString()));
        }
      }
    } catch (e) {
      emit(UosDetailError(message: e.toString()));
    }
  }

  Future<bool> _onCreateMsTeams(
    CreateMsTeams event,
    Emitter<UosDetailState> emit,
  ) async {
    emit(UosDetailLoading());
    try {
      final idUos = event.idUos;
      final authToken = event.authToken;

      final isSuccess = await _repository.createMsTeamsForUos(authToken, idUos);

      if (isSuccess) {
        try {
          final fullInfoUosDetail = await _repository.getFullInfoUosDetail(
            idUos,
            true,
            authToken,
          );
          emit(
            FullInfoUosLoaded(
              fullInfoUosDetail: fullInfoUosDetail,
              typeSuccess: 'createTeams',
              errorMessage: null,
            ),
          );
        } catch (e) {
          emit(UosDetailError(message: e.toString()));
        }
      } else {
        throw Exception("Yêu cầu bị từ chối hoặc lỗi hệ thống");
      }

      return isSuccess;
    } catch (e) {
      try {
        final fullInfoUosDetail = await _repository.getFullInfoUosDetail(
          event.idUos,
          true,
          event.authToken,
        );

        emit(
          FullInfoUosLoaded(
            fullInfoUosDetail: fullInfoUosDetail,
            errorMessage:
                'Không thể tạo teams. Vui lòng thử lại (Lỗi: ${e.toString()})',
          ),
        );
      } catch (e) {
        emit(UosDetailError(message: e.toString()));
      }
      return false;
    }
  }
}
