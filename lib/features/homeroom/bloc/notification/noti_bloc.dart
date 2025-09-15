import 'package:e_dut/features/homeroom/domain/repository/homeroom_repo.dart';
import 'package:e_dut/features/profile/domain/repository/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/utils/logger.dart';
import '../../../notification/domain/repositories/notification_repository.dart';
import '../../data/model/noti_model.dart';

part 'noti_event.dart';
part 'noti_state.dart';

class NotiBloc extends Bloc<NotiEvent, NotiState> {
  final NotificationRepository notificationRepository;
  final ProfileRepository profileRepository;
  final HomeroomRepository homeroomRepository;

  NotiBloc(this.notificationRepository, this.profileRepository,
      this.homeroomRepository)
      : super(NotiState()) {
    on<LoadNotiEvent>(_onLoadNoti);
    on<AddNotiEvent>(_onAddNoti);
    on<DeleteNotiEvent>(_onDeleteNoti);
  }

  Future<void> _onLoadNoti(LoadNotiEvent event, Emitter<NotiState> emit) async {
    emit(state.copyWith(status: () => NotiStatus.loading));

    try {
      List<NotiModel> notifications = await profileRepository
          .getNotificationsByClassId(event.authToken, event.classId);

      emit(state.copyWith(
        notifications: () => notifications,
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
    emit(state.copyWith(status: () => NotiStatus.loading));

    try {
      // ignore: unused_local_variable
      final notificationId = await profileRepository.createNotification(
          event.authToken,
          event.classId,
          event.newNoti.title,
          event.newNoti.content);

      final students = await homeroomRepository.getStudents(
        event.authToken,
        event.classId,
      );

      final listEmail = students.map((e) => "${e.id}@sv1.dut.udn.vn").toList();

      await notificationRepository.sendNotificationToMultiUsers(
        "event.token",
        userIds: listEmail,
        title: event.newNoti.title,
        body: event.newNoti.content,
        link: "",
      );

      final updatedList = List<NotiModel>.from(state.notifications);
      updatedList.insert(0, event.newNoti);
      emit(state.copyWith(
          notifications: () => updatedList, status: () => NotiStatus.success));
    } catch (e) {
      logger.e("Error adding notification: $e");
      emit(state.copyWith(
          status: () => NotiStatus.failure,
          errorMessage: () => "Có lỗi xảy ra khi tạo thông báo"));
    }
  }

  Future<void> _onDeleteNoti(
      DeleteNotiEvent event, Emitter<NotiState> emit) async {
    emit(state.copyWith(status: () => NotiStatus.loading));
    // try {
    //   // Gọi API xóa trên server
    //   final notificationId = await scheduleRepository.deleteNotification(
    //     event.authToken,
    //     event.idNotification,
    //   );

    //   // Lấy danh sách user liên quan để xóa thông báo của họ
    //   final listEmails = await scheduleRepository.getListStudentForNotiByUos(
    //     event.idUos,
    //     event.authToken,
    //   );

    //   await notificationRepository.deleteNotificationsByUsersAndTimeTable(
    //     userIds: listEmails,
    //     notiTimeTableId: notificationId,
    //   );

    //   // 🔥 Xóa item khỏi danh sách local
    //   final updatedList = List<NotiModel>.from(state.notifications)
    //     ..removeWhere((noti) => noti.id == event.idNotification);

    //   // Emit state mới với danh sách đã cập nhật
    //   emit(state.copyWith(
    //     status: () => NotiStatus.success,
    //     notifications: () => updatedList,
    //   ));
    // } catch (e) {
    //   logger.e("Error deleting notification: $e");
    //   emit(state.copyWith(
    //     status: () => NotiStatus.failure,
    //     errorMessage: () => e.toString(),
    //   ));
    // }
  }
}
