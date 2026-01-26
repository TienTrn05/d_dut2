part of 'notification_settings_bloc.dart';

class NotificationSettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationSettings extends NotificationSettingsEvent {
  @override
  List<Object?> get props => [];
}

class ToggleGeneralNotification extends NotificationSettingsEvent {
  final bool isEnabled;

  ToggleGeneralNotification({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleMyNotification extends NotificationSettingsEvent {
  final bool isEnabled;
  final String userId;

  ToggleMyNotification({required this.isEnabled, required this.userId});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleQueueNotification extends NotificationSettingsEvent {
  final bool isEnabled;

  ToggleQueueNotification({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class RemainTurnsChanged extends NotificationSettingsEvent {
  final String token;
  final int remainTurn;

  RemainTurnsChanged({required this.token, required this.remainTurn});

  @override
  List<Object?> get props => [remainTurn];
}

class ToggleExamNotification extends NotificationSettingsEvent {
  final bool isEnabled;
  final String authToken;
  final bool isTeacher;

  ToggleExamNotification({
    required this.isEnabled,
    required this.authToken,
    required this.isTeacher,
  });

  @override
  List<Object?> get props => [isEnabled];
}

class RemindBeforeChanged extends NotificationSettingsEvent {
  final int remindBefore;
  final String authToken;
  final bool isTeacher;

  RemindBeforeChanged({
    required this.remindBefore,
    required this.authToken,
    required this.isTeacher,
  });

  @override
  List<Object?> get props => [remindBefore];
}

class ClearErrorMessage extends NotificationSettingsEvent {}
