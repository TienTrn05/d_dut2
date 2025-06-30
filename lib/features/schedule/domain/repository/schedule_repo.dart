import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/uos_item_model.dart';
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

  Future<List<CalendarEventModel>> getCalendarEvents(int month, int year) {
    return _scheduleService.getCalendarEvents(month, year);
  }

  Future<String> getSemesterByDate(DateTime inputDate) {
    return _scheduleService.getSemesterByDate(inputDate);
  }

  Future<String> getWeekByDate(DateTime inputDate) {
    return _scheduleService.getWeekByDate(inputDate);
  }
}
