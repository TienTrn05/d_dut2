part of 'calendar_bloc.dart';

class CalendarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final int month;
  final int year;
  final bool isTeacher;
  final String authToken;

  LoadCalendarEvents(
      {required this.month,
      required this.year,
      required this.isTeacher,
      required this.authToken});
}

class LoadCalendarWeek extends CalendarEvent {
  final DateTime inputDate;
  final String authToken;
  LoadCalendarWeek({required this.inputDate, required this.authToken});
}
