import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/utils/logger.dart';
import '/core/data/local/storage.dart';
import '/core/services/notification_service.dart';
import '/core/data/remote/notification_settings_service.dart';

import '/features/schedule/util/schedule_noti.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final NotificationSettingsService notificationSettingsService;
  NotificationSettingsBloc({required this.notificationSettingsService})
    : super(
        NotificationSettingsState(
          remindBefore: Storage.remindBefore,
          examEnabled: Storage.examNotification,
        ),
      ) {
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<ToggleGeneralNotification>(_onToggleGeneralNotification);
    on<ToggleMyNotification>(_onToggleMyNotification);
    on<ToggleQueueNotification>(_onToggleQueueNotification);
    on<RemainTurnsChanged>(_onRemainTurnChanged);
    on<ToggleExamNotification>(_onToggleExamNotification);
    on<RemindBeforeChanged>(_onRemindBeforeChanged);
    on<ClearErrorMessage>((event, emit) {
      emit(state.copyWith(errorMessage: () => null));
    });
  }

  void _onLoadNotificationSettings(
    LoadNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    bool isAllowed = await NotificationService().areNotificationsAllowed();
    if (!isAllowed) {
      await Storage.setGeneralNotification(false);
      await Storage.setMyNotification(false);
      await Storage.setExamNotification(false);
      await Storage.setQueueNotification(false);
      return emit(
        state.copyWith(
          generalEnabled: () => false,
          personalEnabled: () => false,
          examEnabled: () => false,
          queueEnabled: () => false,
          remainTurn: () => Storage.remainTurn
        ),
      );
    }

    emit(
      state.copyWith(
        generalEnabled: () => Storage.generalNotification,
        personalEnabled: () => Storage.myNotification,
        examEnabled: () => Storage.examNotification,
        queueEnabled: () => Storage.queueNotification,
        remainTurn: () => Storage.remainTurn
      ),
    );
  }

  Future<void> _onToggleGeneralNotification(
    ToggleGeneralNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      if (state.generalEnabled &&
          !await NotificationService().areNotificationsAllowed()) {
        // open app settings if not allowed
        await NotificationService().openAppSettings();
        return;
      }
      await Storage.setGeneralNotification(event.isEnabled);
      emit(state.copyWith(generalEnabled: () => event.isEnabled));
    } catch (e) {
      emit(state.copyWith(errorMessage: () => "Đã có lỗi xảy ra"));
    }
  }

  Future<void> _onToggleMyNotification(
    ToggleMyNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      if (event.isEnabled &&
          !await NotificationService().areNotificationsAllowed()) {
        await NotificationService().openAppSettings();
        return;
      }
      await Storage.setMyNotification(event.isEnabled);
      emit(state.copyWith(personalEnabled: () => event.isEnabled));
    } catch (e) {
      emit(state.copyWith(errorMessage: () => "Đã có lỗi xảy ra"));
    }
  }

  Future<void> _onToggleQueueNotification(
    ToggleQueueNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      if (event.isEnabled &&
          !await NotificationService().areNotificationsAllowed()) {
        await NotificationService().openAppSettings();
        return;
      }
      await Storage.setQueueNotification(event.isEnabled);
      emit(state.copyWith(queueEnabled: () => event.isEnabled));
    } catch (e) {
      emit(state.copyWith(errorMessage: () => "Đã có lỗi xảy ra"));
    }
  }

  Future<void> _onRemainTurnChanged(
    RemainTurnsChanged event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    final oldRemainTurn = state.remainTurn;
    emit(state.copyWith(remainTurn: () => event.remainTurn));
    try {
      await Storage.setRemainTurn(event.remainTurn);
      await notificationSettingsService.setRemainTurn(event.token, event.remainTurn);
    } catch (e) {
      await Storage.setRemainTurn(oldRemainTurn);
      logger.e("Failed to change remain turns setting: $e");
    }
  }

  Future<void> _onToggleExamNotification(
    ToggleExamNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await Storage.setExamNotification(event.isEnabled);
      await Storage.setScheduleNotifications(null);
      await NotificationService().cancelAllNotifications();

      bool setupSuccess = true;

      if (event.isEnabled) {
        final isTeacher = event.isTeacher;
        final authToken = event.authToken;

        // Kiểm tra kết quả setup
        setupSuccess = await ScheduleNoti.setupScheduleNotifications(
          isTeacher,
          authToken,
        );

        if (!setupSuccess) {
          // Nếu setup thất bại, rollback setting về false
          await Storage.setExamNotification(false);
          emit(state.copyWith(errorMessage: () => "Đã có lỗi xảy ra"));
        }
      }

      // Chỉ emit state với giá trị thực tế sau khi setup
      final finalValue = event.isEnabled && setupSuccess;
      emit(state.copyWith(examEnabled: () => finalValue));
    } catch (e) {
      await Storage.setExamNotification(false);
      emit(state.copyWith(examEnabled: () => false));
    }
  }

  Future<void> _onRemindBeforeChanged(
    RemindBeforeChanged event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    // Lưu giá trị cũ để rollback nếu cần
    final oldRemindBefore = state.remindBefore;

    try {
      await Storage.setRemindBefore(event.remindBefore);
      await Storage.setScheduleNotifications(null);
      await NotificationService().cancelAllNotifications();

      final isTeacher = event.isTeacher;
      final authToken = event.authToken;

      // Kiểm tra kết quả setup notifications
      final setupSuccess = await ScheduleNoti.setupScheduleNotifications(
        isTeacher,
        authToken,
      );

      if (setupSuccess) {
        emit(state.copyWith(remindBefore: () => event.remindBefore));
      } else {
        await Storage.setRemindBefore(oldRemindBefore);
        emit(state.copyWith(errorMessage: () => "Đã có lỗi xảy ra"));
      }
    } catch (e) {
      // Rollback về giá trị cũ
      await Storage.setRemindBefore(oldRemindBefore);
      try {
        await ScheduleNoti.setupScheduleNotifications(
          event.isTeacher,
          event.authToken,
        );
      } catch (setupError) {
        logger.e("Failed to rollback setup notifications: $setupError");
      }
    }
  }
}
