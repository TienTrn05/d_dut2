import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/utils/logger.dart';
import '../../../notification/domain/repositories/notification_repository.dart';
import '../../data/model/noti_model.dart';

part 'noti_event.dart';
part 'noti_state.dart';

class NotiBloc extends Bloc<NotiEvent, NotiState> {
  final NotificationRepository notificationRepository;
  final ScheduleRepository scheduleRepository;

  NotiBloc(this.notificationRepository, this.scheduleRepository)
      : super(NotiState()) {
    on<LoadNotiEvent>(_onLoadNoti);
    on<AddNotiEvent>(_onAddNoti);
  }

  Future<void> _onLoadNoti(NotiEvent event, Emitter<NotiState> emit) async {
    emit(state.copyWith(status: () => NotiStatus.loading));

    try {
      emit(state.copyWith(
        notifications: () => NotiModel.mockData,
        status: () => NotiStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => NotiStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onAddNoti(
    AddNotiEvent event,
    Emitter<NotiState> emit,
  ) async {
    try {
      final listEmails = await scheduleRepository.getListStudentForNotiByUos(
        event.idUos,
        event.authToken,
      );

      await notificationRepository.sendNotificationToMultiUsers(
        "event.token",
        userIds: listEmails,
        title: event.newNoti.title,
        body: event.newNoti.content,
        link: "",
      );

      final updatedList = List<NotiModel>.from(state.notifications);
      updatedList.insert(0, event.newNoti);
      emit(state.copyWith(notifications: () => updatedList));
    } catch (e) {
      logger.e("Error adding notification: $e");
      emit(state.copyWith(errorMessage: () => e.toString()));
    }
  }
}
