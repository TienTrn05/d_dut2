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
