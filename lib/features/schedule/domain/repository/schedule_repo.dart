import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/full_info_uos_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_students_absent_model.dart';
import 'package:injectable/injectable.dart';

@singleton
class ScheduleRepository {
  final ScheduleService _scheduleService;

  ScheduleRepository(this._scheduleService);

  Future<List<SemesterModel>> getListSemester() {
    return _scheduleService.getListSemester();
  }

  Future<List<UosItemModel>> getListUOSBySemester(
      String idSemester, bool isTeacher) {
    return _scheduleService.getListUOSBySemester(idSemester, isTeacher);
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(
      DateTime inputDate, bool isTeacher) {
    return _scheduleService.getSchedulesByDate(inputDate, isTeacher);
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
      int month, int year, bool isTeacher) {
    return _scheduleService.getCalendarEvents(month, year, isTeacher);
  }

  Future<String> getSemesterByDate(DateTime inputDate) {
    return _scheduleService.getSemesterByDate(inputDate);
  }

  Future<String> getWeekByDate(DateTime inputDate) {
    return _scheduleService.getWeekByDate(inputDate);
  }

  Future<FullInfoUosDetailModel> getFullInfoUosDetail(
      String idUos, bool isTeacher) {
    return _scheduleService.getFullInfoUosDetail(idUos, isTeacher);
  }

  Future<ExamShiftDetailModel> getTeacherExamShiftDetail(String idExamShift) {
    return _scheduleService.getTeacherExamShiftDetail(idExamShift);
  }

  Future<StudentsExamShiftModel> getListStudentsByExamShift(
      String idExamShift, String keyword, int pageNumber) {
    return _scheduleService.getListStudentsByExamShift(
        idExamShift, keyword, pageNumber);
  }

  Future<UosStudentsAbsentModel> getListStudentsByUos(
      String idUos, int pageNumber, String? keyword, DateTime absenceDate) {
    return _scheduleService.getListStudentsByUos(
        idUos, pageNumber, keyword, absenceDate);
  }

  Future<bool> getIsAttendanceDate(String idUos, DateTime attendanceDate) {
    return _scheduleService.isAttendanceDate(idUos, attendanceDate);
  }

  Future<bool> takeAttendance(String idUnitOfStudy, DateTime absenceDate,
      List<String> idStudentsAbsent) {
    return _scheduleService.takeAttendance(
        idUnitOfStudy: idUnitOfStudy,
        absenceDate: absenceDate,
        idStudentsAbsent: idStudentsAbsent);
  }

  Future<bool> deleteAttendanceHistory(String idUos, DateTime attendanceDate) {
    return _scheduleService.deleteAttendanceHistory(idUos, attendanceDate);
  }

  Future<List<DateTime>> getListAbsentDate(String idUos, String idStudent) {
    return _scheduleService.getListAbsentDate(idUos, idStudent);
  }
}
