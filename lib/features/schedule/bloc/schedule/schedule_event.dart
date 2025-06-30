part of 'schedule_bloc.dart';

class ScheduleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSchedulesByDate extends ScheduleEvent {
  final DateTime inputDate;
  final bool isTeacher;

  LoadSchedulesByDate({required this.inputDate, required this.isTeacher});
}
