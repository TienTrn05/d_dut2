part of 'schedule_bloc.dart';

class ScheduleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}

class SchedulesLoaded extends ScheduleState {
  final DateTime selectedDay;
  final String noWeek;
  final List<ScheduleItemModel> schedules;

  SchedulesLoaded(
      {required this.selectedDay,
      required this.noWeek,
      required this.schedules});
}
