part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class MyNotificationsSubscriptionRequested extends NotificationsEvent {
  final String token;

  const MyNotificationsSubscriptionRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}

class MyNotificationsLoadMoreRequested extends NotificationsEvent {
  final String token;

  const MyNotificationsLoadMoreRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}

class GeneralNotificationsSubscriptionRequested extends NotificationsEvent {
  final String token;

  const GeneralNotificationsSubscriptionRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}

class GeneralNotificationsLoadMoreRequested extends NotificationsEvent {
  final String token;

  const GeneralNotificationsLoadMoreRequested({
    required this.token,
  });
  
  @override
  List<Object> get props => [token];
}