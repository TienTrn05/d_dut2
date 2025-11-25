import 'package:bloc/bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';

part 'export_absent_state.dart';
part 'export_absent_event.dart';

class ExportAbsentBloc extends Bloc<ExportAbsentEvent, ExportAbsentState> {
  final ScheduleRepository _repository;

  ExportAbsentBloc(this._repository) : super(ExportAbsentInitial()) {
    on<ExportAbsentSummary>(_onExportAbsentSummary);
  }

  Future<void> _onExportAbsentSummary(
    ExportAbsentSummary event,
    Emitter<ExportAbsentState> emit,
  ) async {
    emit(ExportAbsentLoading());
    try {
      await _repository.exportAttendanceSummary(event.authToken, event.idUos);
      emit(ExportAbsentSuccess());
    } catch (e) {
      emit(ExportAbsentError(e.toString()));
    }
  }
}
