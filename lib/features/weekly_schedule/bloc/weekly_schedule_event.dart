part of 'weekly_schedule_bloc.dart';

abstract class WeeklyScheduleEvent extends Equatable {
  const WeeklyScheduleEvent(this.email, {this.date});

  final String email;
  final DateTime? date;

  @override
  List<Object?> get props => [email, date];
}

class WeeklyScheduleRequested extends WeeklyScheduleEvent {
  const WeeklyScheduleRequested(String email, {DateTime? date})
    : super(email, date: date);
}

class WeeklyScheduleRefreshed extends WeeklyScheduleEvent {
  const WeeklyScheduleRefreshed(String email, {DateTime? date})
    : super(email, date: date);
}
