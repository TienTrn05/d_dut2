part of 'calendar_bloc.dart';

class CalendarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CaledarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CaledarError extends CalendarState {
  final String message;
  CaledarError(this.message);
  @override
  List<Object?> get props => [message];
}

class CalendarEventLoaded extends CalendarState {
  final List<CalendarEventModel> calendarEvents;
  CalendarEventLoaded({required this.calendarEvents});

  @override
  List<Object> get props => [calendarEvents];
}
