part of 'weekly_schedule_bloc.dart';

class WeeklyScheduleState extends Equatable {
  final bool isLoading;
  final WeeklyScheduleResponse? data;
  final String? error;

  const WeeklyScheduleState._({required this.isLoading, this.data, this.error});

  const WeeklyScheduleState.loading() : this._(isLoading: true);

  const WeeklyScheduleState.loaded(WeeklyScheduleResponse data)
    : this._(isLoading: false, data: data);

  const WeeklyScheduleState.error(String message)
    : this._(isLoading: false, error: message);

  @override
  List<Object?> get props => [isLoading, data, error];
}
