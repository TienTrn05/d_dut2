import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/uos_item_model.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class ScheduleService {
  final String _url;
  final Dio _dio;

  ScheduleService(@Named('scheduleAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<SemesterModel>> getListSemester() async {
    try {
      final response = await _dio.get("$_url/api/Timetable/GetListSemesters");
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        return data.map((e) => SemesterModel.fromJson(e)).toList();
      } else {
        throw Exception(
            "Failed to load semesters : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Failed to load semesters: $e");
      throw Exception("Failed to fetch semesters: $e");
    }
  }

  Future<List<UosItemModel>> getListUOSBySemester(String idSemester) async {
    try {
      final response = await _dio.get(
          "$_url/api/Timetable/GetListTimetablesBySemester",
          queryParameters: {'idSemester': idSemester});

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        return data.map((e) => UosItemModel.fromJson(e)).toList();
      } else {
        throw Exception(
            "[51:schedule_service]Failed to load list UOSItem : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("[54:schedule_service]Failed to load UOSItem: $e");
      throw Exception("Failed to fetch UOSItem: $e");
    }
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(DateTime inputDate) async {
    try {
      final response = await _dio
          .get("$_url/api/Timetable/GetListTimetablesByDate", queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(inputDate),
      });
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        final schedules = Functions.sortSchedulesByTime(
            data.map((e) => ScheduleItemModel.fromJson(e)).toList());
        return schedules;
      } else {
        throw Exception(
            "[69:schedule_service]Failed to load list ScheduleItem : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("[72:schedule_service]Failed to load ScheduleItem: $e");
      throw Exception("Failed to fetch ScheduleItem: $e");
    }
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
      int month, int year) async {
    try {
      final response = await _dio
          .get("$_url/api/Timetable/GetCalendarEvents", queryParameters: {
        'month': month,
        'year': year,
      });

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];
        return data.map((item) => CalendarEventModel.fromJson(item)).toList();
      } else {
        throw Exception(
            "Fail to load Calendar Events: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Fail to load Calendar Events: $e");
      throw Exception("Failed to fetch CalendarEvents: $e");
    }
  }
}
