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

  ToggleExamNotification({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class RemindBeforeChanged extends NotificationSettingsEvent {
  final int remindBefore;

  RemindBeforeChanged({required this.remindBefore});

  @override
  List<Object?> get props => [remindBefore];
}