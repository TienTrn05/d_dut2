part of 'notifications_bloc.dart';

enum MyNotificationsStatus { initial, loading, success, failure }
enum GeneralNotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final MyNotificationsStatus myNotificationsStatus;
  final List<Notification> myNotifications;
  final String errorMyNotificationsMessage;

  final GeneralNotificationsStatus generalNotificationsStatus;
  final List<Notification> generalNotifications;
  final String errorGeneralNotificationsMessage;

  const NotificationsState({
    this.myNotificationsStatus = MyNotificationsStatus.initial,
    this.generalNotificationsStatus = GeneralNotificationsStatus.initial,
    this.myNotifications = const <Notification>[],
    this.generalNotifications = const <Notification>[],
    this.errorMyNotificationsMessage = '',
    this.errorGeneralNotificationsMessage = '',
  });

  NotificationsState copyWith({
    MyNotificationsStatus Function()? myNotificationsStatus,
    GeneralNotificationsStatus Function()? generalNotificationsStatus,
    List<Notification> Function()? myNotifications,
    List<Notification> Function()? generalNotifications,
    String Function()? errorMyNotificationsMessage,
    String Function()? errorGeneralNotificationsMessage,
  }) {
    return NotificationsState(
      myNotificationsStatus: myNotificationsStatus != null ? myNotificationsStatus() : this.myNotificationsStatus,
      generalNotificationsStatus: generalNotificationsStatus != null
          ? generalNotificationsStatus()
          : this.generalNotificationsStatus,
      myNotifications: myNotifications != null ? myNotifications() : this.myNotifications,
      generalNotifications: generalNotifications != null
          ? generalNotifications()
          : this.generalNotifications,
      errorMyNotificationsMessage: errorMyNotificationsMessage != null
          ? errorMyNotificationsMessage()
          : this.errorMyNotificationsMessage,
      errorGeneralNotificationsMessage: errorGeneralNotificationsMessage != null
          ? errorGeneralNotificationsMessage()
          : this.errorGeneralNotificationsMessage
    );
  }

  @override
  List<Object?> get props => [
    myNotificationsStatus,
    generalNotificationsStatus,
    myNotifications,
    generalNotifications,
    errorMyNotificationsMessage,
    errorGeneralNotificationsMessage
  ];
}
