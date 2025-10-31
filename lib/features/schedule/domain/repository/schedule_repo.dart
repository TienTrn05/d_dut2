import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/academic_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/uos_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/full_info_uos_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_students_absent_model.dart';
import 'package:injectable/injectable.dart';

import '../../data/model/noti_model.dart';

@singleton
class ScheduleRepository {
  final ScheduleService _scheduleService;

  ScheduleRepository(this._scheduleService);

  Future<List<SemesterModel>> getListSemester(String authToken) {
    return _scheduleService.getListSemester(authToken);
  }

  Future<List<UosItemModel>> getListUOSBySemester(
    String idSemester,
    bool isTeacher,
    String authToken,
  ) {
    return _scheduleService.getListUOSBySemester(
      idSemester,
      isTeacher,
      authToken,
    );
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(
    DateTime inputDate,
    bool isTeacher,
    String authToken,
  ) {
    return _scheduleService.getSchedulesByDate(inputDate, isTeacher, authToken);
  }

  Future<List<UosModel>> getScheduleNotification(
    bool isTeacher,
    String authToken,
  ) {
    return _scheduleService.getScheduleNotification(isTeacher, authToken);
  }

  Future<List<AcademicEventModel>> getAcademicEventForReminder(
    String authToken,
  ) {
    return _scheduleService.getAcademicEventForReminder(authToken);
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
    int month,
    int year,
    bool isTeacher,
    String authToken,
  ) {
    return _scheduleService.getCalendarEvents(
      month,
      year,
      isTeacher,
      authToken,
    );
  }

  Future<List<CalendarEventModel>> getCalendarAbsentEvents(
    int month,
    int year,
    String idUos,
    String authToken,
  ) {
    return _scheduleService.getCalendarAbsentEvents(
      month,
      year,
      idUos,
      authToken,
    );
  }

  Future<String> getSemesterByDate(DateTime inputDate, String authToken) {
    return _scheduleService.getSemesterByDate(inputDate, authToken);
  }

  Future<String> getWeekByDate(DateTime inputDate, String authToken) {
    return _scheduleService.getWeekByDate(inputDate, authToken);
  }

  Future<FullInfoUosDetailModel> getFullInfoUosDetail(
    String idUos,
    bool isTeacher,
    String authToken,
  ) {
    return _scheduleService.getFullInfoUosDetail(idUos, isTeacher, authToken);
  }

  Future<ExamShiftDetailModel> getTeacherExamShiftDetail(
    String idExamShift,
    String authToken,
  ) {
    return _scheduleService.getTeacherExamShiftDetail(idExamShift, authToken);
  }

  Future<StudentsExamShiftModel> getListStudentsByExamShift(
    String idExamShift,
    String authToken,
  ) {
    return _scheduleService.getListStudentsByExamShift(idExamShift, authToken);
  }

  Future<UosStudentsAbsentModel> getListStudentsByUos(
    String idUos,
    DateTime absenceDate,
    String authToken,
  ) {
    return _scheduleService.getListStudentsByUos(idUos, absenceDate, authToken);
  }

  Future<bool> getIsAttendanceDate(
    String idUos,
    DateTime attendanceDate,
    String authToken,
  ) {
    return _scheduleService.isAttendanceDate(idUos, attendanceDate, authToken);
  }

  Future<bool> getIsAttendanceDateValid(
    String idUos,
    DateTime attendanceDate,
    String authToken,
  ) {
    return _scheduleService.isAttendanceDateValid(
      idUos,
      attendanceDate,
      authToken,
    );
  }

  Future<bool> takeAttendance(
    String idUnitOfStudy,
    DateTime absenceDate,
    List<String> idStudentsAbsent,
    String authToken,
  ) {
    return _scheduleService.takeAttendance(
      idUnitOfStudy: idUnitOfStudy,
      absenceDate: absenceDate,
      idStudentsAbsent: idStudentsAbsent,
      authToken: authToken,
    );
  }

  Future<bool> deleteAttendanceHistory(
    String idUos,
    DateTime attendanceDate,
    String authToken,
  ) {
    return _scheduleService.deleteAttendanceHistory(
      idUos,
      attendanceDate,
      authToken,
    );
  }

  Future<List<DateTime>> getListAbsentDate(
    String idUos,
    String? idStudent,
    String authToken,
  ) {
    return _scheduleService.getListAbsentDate(idUos, idStudent, authToken);
  }

  Future<bool> updateMsTeamsInfo(
    String token,
    String idUOS,
    String msTeamCode,
    String msTeamLink,
  ) {
    return _scheduleService.updateMsTeamsInfo(
      token,
      idUOS,
      msTeamCode,
      msTeamLink,
    );
  }

  Future<List<String>> getListStudentForNotiByUos(
    String idUos,
    String authToken,
  ) {
    return _scheduleService.getListStudentForNotiByUos(authToken, idUos);
  }

  Future<String> createNotificationByIdUOS(
    String token,
    String idUos,
    String title,
    String content,
  ) {
    return _scheduleService.createNotificationByIdUOS(
      token,
      idUos,
      title,
      content,
    );
  }

  Future<List<NotiModel>> getNotificationByIdUOS(String token, String idUos) {
    return _scheduleService.getNotificationByIdUOS(token, idUos);
  }

  Future<String> deleteNotification(String token, String idNotification) {
    return _scheduleService.deleteNotification(token, idNotification);
  }
}
