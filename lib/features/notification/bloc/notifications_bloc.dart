import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/notification.dart';
import '../domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository notificationRepository;

  NotificationsBloc({required this.notificationRepository})
      : super(const NotificationsState()) {
    on<MyNotificationsSubscriptionRequested>(_onFetchMyNotifications);
  }

  Future<void> _onFetchMyNotifications(
      MyNotificationsSubscriptionRequested event,
      Emitter<NotificationsState> emit) async {
    emit(state.copyWith(myNotificationsStatus: () => MyNotificationsStatus.initial));
    try {
      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.loading));
      final notifications = await notificationRepository.fetchMyNotifications(event.token);
      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.success,
          myNotifications: () => notifications));
    } catch (e) {
      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.failure,
          errorMyNotificationsMessage: () => "Đã có lỗi xảy ra!"));
    }
  }
}
