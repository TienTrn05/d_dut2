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
    on<MyNotificationsLoadMoreRequested>(_onLoadMoreMyNotifications);
    on<GeneralNotificationsSubscriptionRequested>(_onFetchGeneralNotifications);
    on<GeneralNotificationsLoadMoreRequested>(_onLoadMoreGeneralNotifications);
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

  Future<void> _onLoadMoreMyNotifications(
      MyNotificationsLoadMoreRequested event,
      Emitter<NotificationsState> emit) async {
    try {
      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.loading));
      final notifications = await notificationRepository.fetchMyNotifications(event.token, lastVisible: state.myNotifications.last.id);

      if (notifications.isEmpty) {
        emit(state.copyWith(
            myNotificationsStatus: () => MyNotificationsStatus.unchange));
        return;
      }

      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.success,
          myNotifications: () => [...state.myNotifications, ...notifications]));
    } catch (e) {
      emit(state.copyWith(
          myNotificationsStatus: () => MyNotificationsStatus.failure,
          errorMyNotificationsMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onFetchGeneralNotifications(
      GeneralNotificationsSubscriptionRequested event,
      Emitter<NotificationsState> emit) async {
    emit(state.copyWith(generalNotificationsStatus: () => GeneralNotificationsStatus.initial));
    try {
      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.loading));
      final notifications = await notificationRepository.fetchGeneralNotifications(event.token);
      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.success,
          generalNotifications: () => notifications));
    } catch (e) {
      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.failure,
          errorGeneralNotificationsMessage: () => "Đã có lỗi xảy ra!"));
    }
  }

  Future<void> _onLoadMoreGeneralNotifications(
      GeneralNotificationsLoadMoreRequested event,
      Emitter<NotificationsState> emit) async {
    try {
      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.loading));
      final notifications = await notificationRepository.fetchGeneralNotifications(event.token, lastVisible: state.generalNotifications.last.id);

      if (notifications.isEmpty) {
        emit(state.copyWith(
            generalNotificationsStatus: () => GeneralNotificationsStatus.unchange));
        return;
      }

      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.success,
          generalNotifications: () => [...state.generalNotifications, ...notifications]));
    } catch (e) {
      emit(state.copyWith(
          generalNotificationsStatus: () => GeneralNotificationsStatus.failure,
          errorGeneralNotificationsMessage: () => "Đã có lỗi xảy ra!"));
    }
  }
}
