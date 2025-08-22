import 'package:e_dut/core/data/local/storage.dart';
import 'package:e_dut/core/services/notification_service.dart';
import 'package:e_dut/features/schedule/util/schedule_noti.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  NotificationSettingsBloc()
      : super(NotificationSettingsState(
            remindBefore: Storage.remindBefore,
            examEnabled: Storage.examNotification)) {
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<ToggleGeneralNotification>(_onToggleGeneralNotification);
    on<ToggleMyNotification>(_onToggleMyNotification);
    on<ToggleExamNotification>(_onToggleExamNotification);
    on<RemindBeforeChanged>(_onRemindBeforeChanged);
  }

  void _onLoadNotificationSettings(
      LoadNotificationSettings event, Emitter<NotificationSettingsState> emit) {
    emit(state.copyWith(
      generalEnabled: () => Storage.generalNotification,
      personalEnabled: () => Storage.myNotification,
      examEnabled: () => Storage.examNotification,
    ));
  }

  Future<void> _onToggleGeneralNotification(ToggleGeneralNotification event,
      Emitter<NotificationSettingsState> emit) async {
    await Storage.setGeneralNotification(event.isEnabled);
    emit(state.copyWith(generalEnabled: () => event.isEnabled));
  }

  Future<void> _onToggleMyNotification(ToggleMyNotification event,
      Emitter<NotificationSettingsState> emit) async {
    await Storage.setMyNotification(event.isEnabled);
    emit(state.copyWith(personalEnabled: () => event.isEnabled));
  }

  Future<void> _onToggleExamNotification(ToggleExamNotification event,
      Emitter<NotificationSettingsState> emit) async {
    await Storage.setExamNotification(event.isEnabled);
    await Storage.setScheduleNotifications(null);
    await NotificationService().cancelAllNotifications();

    emit(state.copyWith(examEnabled: () => event.isEnabled));

    if (event.isEnabled) {
      final isTeacher = event.isTeacher;
      final authToken = event.authToken;
      NotificationService().cancelAllNotifications();
      ScheduleNoti.setupScheduleNotifications(isTeacher, authToken);
    }
  }

  Future<void> _onRemindBeforeChanged(RemindBeforeChanged event,
      Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(remindBefore: () => event.remindBefore));

    await Storage.setRemindBefore(event.remindBefore);
    await Storage.setScheduleNotifications(null);
    await NotificationService().cancelAllNotifications();

    final isTeacher = event.isTeacher;
    final authToken = event.authToken;
    ScheduleNoti.setupScheduleNotifications(isTeacher, authToken);
  }
}
