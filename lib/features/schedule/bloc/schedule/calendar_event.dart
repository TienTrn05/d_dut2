part of 'calendar_bloc.dart';

class CalendarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final int month;
  final int year;
  final bool isTeacher;

  LoadCalendarEvents(
      {required this.month, required this.year, required this.isTeacher});
}

class LoadCalendarWeek extends CalendarEvent {
  final DateTime inputDate;
  LoadCalendarWeek({required this.inputDate});
}
