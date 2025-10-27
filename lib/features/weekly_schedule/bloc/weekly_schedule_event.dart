part of 'weekly_schedule_bloc.dart';

abstract class WeeklyScheduleEvent extends Equatable {
  const WeeklyScheduleEvent(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class WeeklyScheduleRequested extends WeeklyScheduleEvent {
  const WeeklyScheduleRequested(String email) : super(email);
}

class WeeklyScheduleRefreshed extends WeeklyScheduleEvent {
  const WeeklyScheduleRefreshed(String email) : super(email);
}
