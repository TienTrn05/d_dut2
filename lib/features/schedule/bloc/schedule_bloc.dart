import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _scheduleRepository;

  ScheduleBloc(this._scheduleRepository) : super(ScheduleInitial()) {}
}
