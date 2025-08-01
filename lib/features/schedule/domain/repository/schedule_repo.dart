import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/full_info_uos_detail_model.dart';
import 'package:injectable/injectable.dart';

@singleton
class ScheduleRepository {
  final ScheduleService _scheduleService;

  ScheduleRepository(this._scheduleService);

  Future<List<SemesterModel>> getListSemester(String authToken) {
    return _scheduleService.getListSemester(authToken);
  }

  Future<List<UosItemModel>> getListUOSBySemester(
      String idSemester, bool isTeacher, String authToken) {
    return _scheduleService.getListUOSBySemester(
        idSemester, isTeacher, authToken);
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(
      DateTime inputDate, bool isTeacher, String authToken) {
    return _scheduleService.getSchedulesByDate(inputDate, isTeacher, authToken);
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
      int month, int year, bool isTeacher, String authToken) {
    return _scheduleService.getCalendarEvents(
        month, year, isTeacher, authToken);
  }

  Future<String> getSemesterByDate(DateTime inputDate, String authToken) {
    return _scheduleService.getSemesterByDate(inputDate, authToken);
  }

  Future<String> getWeekByDate(DateTime inputDate, String authToken) {
    return _scheduleService.getWeekByDate(inputDate, authToken);
  }

  Future<FullInfoUosDetailModel> getFullInfoUosDetail(
      String idUos, bool isTeacher, String authToken) {
    return _scheduleService.getFullInfoUosDetail(idUos, isTeacher, authToken);
  }

  Future<ExamShiftDetailModel> getTeacherExamShiftDetail(
      String idExamShift, String authToken) {
    return _scheduleService.getTeacherExamShiftDetail(idExamShift, authToken);
  }

  Future<StudentsExamShiftModel> getListStudentsByExamShift(
      String idExamShift, String keyword, int pageNumber, String authToken) {
    return _scheduleService.getListStudentsByExamShift(
        idExamShift, keyword, pageNumber, authToken);
  }
}
