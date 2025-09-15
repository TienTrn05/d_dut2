part of 'noti_bloc.dart';

enum NotiStatus { initial, loading, success, failure }

class NotiState extends Equatable {
  final NotiStatus status;
  final List<NotiModel> notifications;
  final String errorMessage;

  const NotiState({
    this.status = NotiStatus.initial,
    this.notifications = const [],
    this.errorMessage = '',
  });

  NotiState copyWith({
    NotiStatus Function()? status,
    List<NotiModel> Function()? notifications,
    String Function()? errorMessage,
  }) {
    return NotiState(
      status: status != null ? status() : this.status,
      notifications: notifications != null ? notifications() : this.notifications,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
