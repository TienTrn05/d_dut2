import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ScheduleRepository _repository;

  CalendarBloc(this._repository) : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<LoadCalendarWeek>(_onLoadCalendarWeek);
  }

  Future<void> _onLoadCalendarEvents(
      LoadCalendarEvents event, Emitter<CalendarState> emit) async {
    emit(CalendarLoading());
    try {
      final events =
          await _repository.getCalendarEvents(event.month, event.year);
      emit(CalendarEventLoaded(calendarEvents: events));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onLoadCalendarWeek(
      LoadCalendarWeek event, Emitter<CalendarState> emit) async {
    emit(CalendarLoading());
    try {
      final events = await _repository.getWeekByDate(event.inputDate);
      emit(CalendarWeekLoaded(noWeek: events));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }
}
