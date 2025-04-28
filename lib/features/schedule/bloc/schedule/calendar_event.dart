part of 'calendar_bloc.dart';

class CalendarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final int month;
  final int year;

  LoadCalendarEvents({required this.month, required this.year});
}

class LoadCalendarWeek extends CalendarEvent {
  final DateTime inputDate;
  LoadCalendarWeek({required this.inputDate});
}
