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

  ToggleMyNotification({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleExamNotification extends NotificationSettingsEvent {
  final bool isEnabled;
  final String authToken;
  final bool isTeacher;

  ToggleExamNotification(
      {required this.isEnabled,
      required this.authToken,
      required this.isTeacher});

  @override
  List<Object?> get props => [isEnabled];
}

class RemindBeforeChanged extends NotificationSettingsEvent {
  final int remindBefore;
  final String authToken;
  final bool isTeacher;

  RemindBeforeChanged(
      {required this.remindBefore,
      required this.authToken,
      required this.isTeacher});

  @override
  List<Object?> get props => [remindBefore];
}
