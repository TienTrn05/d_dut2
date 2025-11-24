import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/weekly_schedule_model.dart';
import '../data/weekly_schedule_repository.dart';

part 'weekly_schedule_event.dart';
part 'weekly_schedule_state.dart';

class WeeklyScheduleBloc
    extends Bloc<WeeklyScheduleEvent, WeeklyScheduleState> {
  WeeklyScheduleBloc(this._repo) : super(const WeeklyScheduleState.loading()) {
    on<WeeklyScheduleRequested>(_onRequested);
    on<WeeklyScheduleRefreshed>(_onRequested);
  }

  final WeeklyScheduleRepository _repo;

  Future<void> _onRequested(
    WeeklyScheduleEvent event,
    Emitter<WeeklyScheduleState> emit,
  ) async {
    emit(const WeeklyScheduleState.loading());
    try {
      final resp = await _repo.fetchByEmail(event.email, date: event.date);
      emit(WeeklyScheduleState.loaded(resp));
    } catch (e) {
      emit(WeeklyScheduleState.error(e.toString()));
    }
  }
}
