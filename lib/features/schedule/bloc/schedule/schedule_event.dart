part of 'schedule_bloc.dart';

class ScheduleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSchedulesByDate extends ScheduleEvent {
  final DateTime inputDate;

  LoadSchedulesByDate({required this.inputDate});
}

class LoadCalendarEvents extends ScheduleEvent{
  final int month;
  final int year;

  LoadCalendarEvents({required this.month, required this.year});
}
