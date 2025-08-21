import 'dart:convert';

import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/core/data/local/storage.dart';
import 'package:e_dut/core/services/notification_service.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/study_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/uos_model.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/util/functions.dart';

class ScheduleNoti {
  static Future<void> setupScheduleNotifications(
      bool isTeacher, String authToken, ScheduleRepository repository) async {
    try {
      final scheduleNotis =
          await repository.getScheduleNotification(isTeacher, authToken);

      // Convert scheduleNotis to JSON string for comparison
      final newScheduleJson =
          json.encode(scheduleNotis.map((uos) => uos.toJson()).toList());

      // Get stored schedule from SharedPreferences
      final storedScheduleJson = Storage.getScheduleNotifications();

      // Compare to old data
      if (storedScheduleJson != null && storedScheduleJson == newScheduleJson) {
        logger.i("Schedule notifications unchanged, skipping update");
        return;
      }

      logger.i("Schedule notifications changed, updating...");

      // Cancel all existing notifications chỉ khi có thay đổi
      await NotificationService().cancelAllNotifications();

      int notificationId = 10000; // Base ID để đảm bảo unique

      for (var uos in scheduleNotis) {
        for (var studyShift in uos.studyShifts) {
          await ScheduleNoti.scheduleStudyShiftNotifications(
            isTeacher: isTeacher,
            uos: uos,
            studyShift: studyShift,
            notificationId: notificationId++,
          );
        }

        // Process Exam Shifts
        for (var examShift in uos.examShifts) {
          await ScheduleNoti.scheduleExamShiftNotification(
            isTeacher: isTeacher,
            uos: uos,
            examShift: examShift,
            notificationId: notificationId++,
          );
        }
      }

      await Storage.setScheduleNotifications(newScheduleJson);

      logger.i(
          "Successfully setup ${scheduleNotis.length} schedule notifications");
    } catch (e) {
      logger.e("Failed to setup schedule notifications: $e");
    }
  }

  static Future<void> scheduleStudyShiftNotifications({
    required bool isTeacher,
    required UosModel uos,
    required StudyShiftModel studyShift,
    required int notificationId,
  }) async {
    try {
      final now = DateTime.now();
      final studyStartDate =
          studyShift.studyStartDate; // Ngày học thực tế của tuần startWeek

      // Parse study time (format: "HH:MM:SS")
      final timeParts = studyShift.startStudyTime.split(':');

      // Tính số tuần cần tạo thông báo (từ startWeek đến endWeek)
      final totalWeeks = studyShift.endWeek - studyShift.startWeek + 1;

      // Tạo thông báo cho từng tuần
      for (int weekOffset = 0; weekOffset < totalWeeks; weekOffset++) {
        // Tính ngày học cho tuần hiện tại (cộng thêm 7 ngày cho mỗi tuần)
        final classDate = studyStartDate.add(Duration(days: weekOffset * 7));

        // Tạo DateTime đầy đủ với thời gian học
        final classDateTime = DateTime(
          classDate.year,
          classDate.month,
          classDate.day,
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
        );

        // Chỉ tạo thông báo cho các tiết học trong tương lai
        if (classDateTime.isAfter(now)) {
          // Thông báo 15 phút trước giờ học
          final notificationTime =
              classDateTime.subtract(const Duration(minutes: 15));

          if (notificationTime.isAfter(now)) {
            await NotificationService().scheduleClassNotification(
              id: notificationId +
                  (weekOffset * 1000), // Unique ID cho mỗi notification
              title:
                  'Sắp đến giờ  ${isTeacher ? 'dạy' : 'học'}: ${uos.subjectName}',
              body:
                  'Tiết ${isTeacher ? 'dạy' : 'học'} sẽ bắt đầu lúc ${Functions.formatTime(classDateTime)} tại phòng ${studyShift.room}',
              scheduledTime: notificationTime,
            );
          }
        }
      }

      logger.d(
          "Scheduled $totalWeeks weeks of notifications for ${uos.subjectName}");
    } catch (e) {
      logger.e(
          "Failed to schedule study shift notification for ${uos.subjectName}: $e");
    }
  }

  static Future<void> scheduleExamShiftNotification({
    required bool isTeacher,
    required UosModel uos,
    required ExamShiftModel examShift,
    required int notificationId,
  }) async {
    try {
      final now = DateTime.now();
      final examDateTime = examShift.examDate;

      // Only schedule notifications cho future exams
      if (examDateTime != null && examDateTime.isAfter(now)) {
        // Schedule notification 1 day before exam
        final oneDayBefore = examDateTime.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(now)) {
          await NotificationService().scheduleClassNotification(
            id: notificationId,
            title: isTeacher
                ? 'Nhắc nhở lịch coi thi: ${examShift.examShiftName}'
                : 'Nhắc nhở lịch thi: ${uos.subjectName}',
            body:
                'Bạn có lịch ${isTeacher ? 'coi thi' : 'thi'} vào ngày mai (${Functions.formatDateTime(examDateTime)}) tại phòng ${examShift.room}',
            scheduledTime: oneDayBefore,
          );
        }
      }
    } catch (e) {
      logger
          .e("Failed to schedule exam notification for ${uos.subjectName}: $e");
    }
  }
}
