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