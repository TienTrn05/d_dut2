part of 'calendar_bloc.dart';

class CalendarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarError extends CalendarState {
  final String message;
  CalendarError(this.message);
  @override
  List<Object?> get props => [message];
}

class CalendarEventLoaded extends CalendarState {
  final List<CalendarEventModel> calendarEvents;
  CalendarEventLoaded({required this.calendarEvents});

  @override
  List<Object> get props => [calendarEvents];
}

class CalendarWeekLoaded extends CalendarState {
  final String noWeek;
  CalendarWeekLoaded({required this.noWeek});
  @override
  List<Object> get props => [noWeek];
}
