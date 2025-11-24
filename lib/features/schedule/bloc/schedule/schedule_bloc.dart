import 'dart:collection';

import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/util/schedule_noti.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/schedule_widget_service.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _repository;

  final int _cacheLimit = 5;
  final LinkedHashMap<DateTime, List<ScheduleItemModel>> _schedulesCache =
      LinkedHashMap();

  ScheduleBloc(this._repository) : super(ScheduleInitial()) {
    on<LoadSchedulesByDate>(_onLoadSchedulesByDate);
    on<LoadScheduleDashboard>(_onLoadSchedulesDashboard);
  }

  Future<void> _onLoadSchedulesByDate(
    LoadSchedulesByDate event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final inputDate = event.inputDate;
      final isTeacher = event.isTeacher;
      final authToken = event.authToken;

      final noWeek = await _repository.getWeekByDate(inputDate, authToken);
      if (_schedulesCache.containsKey(inputDate)) {
        emit(
          SchedulesLoaded(
            selectedDay: inputDate,
            noWeek: noWeek,
            schedules: _schedulesCache[inputDate]!,
          ),
        );
      } else {
        final schedules = await _repository.getSchedulesByDate(
          inputDate,
          isTeacher,
          authToken,
        );
        if (_schedulesCache.length > _cacheLimit) {
          _schedulesCache.remove(_schedulesCache.keys.first);
        }
        _schedulesCache[inputDate] = schedules;
        emit(
          SchedulesLoaded(
            selectedDay: inputDate,
            noWeek: noWeek,
            schedules: schedules,
          ),
        );
      }
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onLoadSchedulesDashboard(
    LoadScheduleDashboard event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final currentDate = DateTime.now();
      final isTeacher = event.isTeacher;
      final authToken = event.authToken;

      final schedules = await _repository.getSchedulesByDate(
        currentDate,
        isTeacher,
        authToken,
      );

      // Gửi yêu cầu Android refresh widget
      await ScheduleWidgetService().updateWidget(schedules);

      emit(ScheduleDashboardLoaded(schedules: schedules));

      ScheduleNoti.setupScheduleNotifications(isTeacher, authToken);
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
