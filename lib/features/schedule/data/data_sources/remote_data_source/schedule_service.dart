import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/core/services/api_client.dart';
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
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../model/noti_model.dart' show NotiModel;

@injectable
class ScheduleService {
  final String _url;
  final ApiClient _apiClient;

  ScheduleService(@Named('scheduleAPIUrl') String url)
    : _url = url,
      _apiClient = ApiClient(url);

  Future<List<SemesterModel>> getListSemester(String authToken) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Timetable/GetListSemesters",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final semesters = data.map((e) => SemesterModel.fromJson(e)).toList();
        // semesters.sort(Functions.compareSemesters);
        return semesters;
      } else {
        throw Exception(
          "Failed to load semesters : ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to load semesters: $e");
      throw Exception("Failed to fetch semesters: $e");
    }
  }

  Future<List<UosItemModel>> getListUOSBySemester(
    String idSemester,
    bool isTeacher,
    String authToken,
  ) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetListTeacherTimetablesBySemester",
          queryParameters: {'idSemester': idSemester},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      } else {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetListStudentTimetablesBySemester",
          queryParameters: {'idSemester': idSemester},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      }

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        return data.map((e) => UosItemModel.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to load list UOSItem : ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch UOSItem: $e");
    }
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(
    DateTime inputDate,
    bool isTeacher,
    String authToken,
  ) async {
    logger.d(authToken);
    try {
      dynamic response;
      if (isTeacher) {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetListTeacherTimetablesByDate",
          queryParameters: {'date': DateFormat('yyyy-MM-dd').format(inputDate)},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      } else {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetListStudentTimetablesByDate",
          queryParameters: {'date': DateFormat('yyyy-MM-dd').format(inputDate)},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      }
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        final schedules = Functions.sortSchedulesByTime(
          data.map((e) => ScheduleItemModel.fromJson(e)).toList(),
        );
        return schedules;
      } else {
        throw Exception(
          "Failed to load list ScheduleItem : ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to load ScheduleItem: $e");
      throw Exception("Failed to fetch ScheduleItem: $e");
    }
  }

  Future<List<UosModel>> getScheduleNotification(
    bool isTeacher,
    String authToken,
  ) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetTeacherTimetablesForNoti",
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      } else {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetStudentTimetablesForNoti",
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      }

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];
        return data.map((item) => UosModel.fromJson(item)).toList();
      } else {
        throw Exception(
          "Fail to load Schedule Notifications: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Fail to load Schedule Notifications: $e");
      throw Exception("Failed to fetch Schedule Notifications: $e");
    }
  }

  Future<List<AcademicEventModel>> getAcademicEventForReminder(
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/AcademicEvent/GetAcademicEventsForReminder",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];
        return data.map((item) => AcademicEventModel.fromJson(item)).toList();
      } else {
        throw Exception(
          "Fail to load Academic Event For Reminder: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Fail to load Academic Event For Reminder: $e");
      throw Exception("Failed to fetch Academic Event For Reminder: $e");
    }
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
    int month,
    int year,
    bool isTeacher,
    String authToken,
  ) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetTeacherCalendarEvents",
          queryParameters: {'month': month, 'year': year},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      } else {
        response = await _apiClient.dio.get(
          "$_url/api/Timetable/GetStudentCalendarEvents",
          queryParameters: {'month': month, 'year': year},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      }

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];
        return data.map((item) => CalendarEventModel.fromJson(item)).toList();
      } else {
        throw Exception(
          "Fail to load Calendar Events: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Fail to load Calendar Events: $e");
      throw Exception("Failed to fetch CalendarEvents: $e");
    }
  }

  Future<List<CalendarEventModel>> getCalendarAbsentEvents(
    int month,
    int year,
    String idUos,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Timetable/GetTeacherCalendarEventsByUOS",
        queryParameters: {'month': month, 'year': year, 'idUos': idUos},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];
        return data.map((item) => CalendarEventModel.fromJson(item)).toList();
      } else {
        throw Exception(
          "Fail to load Calendar Absent Events: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Fail to load Calendar Absent Events: $e");
      throw Exception("Failed to fetch CalendarAbsentEvents: $e");
    }
  }

  Future<String> getSemesterByDate(DateTime inputDate, String authToken) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Timetable/GetWeekSemester",
        queryParameters: {'date': DateFormat('yyyy-MM-dd').format(inputDate)},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];

        final idSemester = data['idSemester'] as String?;
        if (idSemester != null && idSemester.isNotEmpty) {
          return idSemester;
        } else {
          throw Exception("idSemester is null or empty.");
        }
      } else {
        throw Exception(
          "Failed to load idSemester: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to load semester: $e");
      throw Exception("Failed to fetch semester: $e");
    }
  }

  Future<String> getWeekByDate(DateTime inputDate, String authToken) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Timetable/GetWeekSemester",
        queryParameters: {'date': DateFormat('yyyy-MM-dd').format(inputDate)},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];

        final noWeek = data['noWeek'] != null ? data['noWeek'].toString() : "";
        return noWeek;
      } else {
        throw Exception("Failed to load noWeek: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Failed to load week: $e");
      throw Exception("Failed to fetch week: $e");
    }
  }

  Future<FullInfoUosDetailModel> getFullInfoUosDetail(
    String idUos,
    bool isTeacher,
    String authToken,
  ) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _apiClient.dio.get(
          "$_url/api/UOS/GetTeacherUosDetail",
          queryParameters: {'idUos': idUos},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      } else {
        response = await _apiClient.dio.get(
          "$_url/api/UOS/GetStudentUosDetail",
          queryParameters: {'idUos': idUos},
          options: Options(headers: {"Authorization": "Bearer $authToken"}),
        );
      }
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final detailStudentUos = FullInfoUosDetailModel.fromJson(data);

        return detailStudentUos;
      } else {
        throw Exception(
          "Failed to load student uos detail: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch student uos detail: $e");
    }
  }

  Future<ExamShiftDetailModel> getTeacherExamShiftDetail(
    String idExamShift,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/UOS/GetTeacherExamShiftDetail",
        queryParameters: {'idExamShift': idExamShift},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final examShiftDetail = ExamShiftDetailModel.fromJson(data);

        return examShiftDetail;
      } else {
        throw Exception(
          "Failed to load exam shift detail: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch student uos detail: $e");
    }
  }

  Future<StudentsExamShiftModel> getListStudentsByExamShift(
    String idExamShift,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/UOS/GetListStudentsByExamShift",
        queryParameters: {'idExamShift': idExamShift},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final listStudents = StudentsExamShiftModel.fromJson(data);

        return listStudents;
      } else {
        throw Exception(
          "Failed to load list students of examshift: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch list students of examshift: $e");
    }
  }

  Future<UosStudentsAbsentModel> getListStudentsByUos(
    String idUos,
    DateTime absenceDate,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/UOS/GetListStudentsByUos",
        queryParameters: {"idUos": idUos, "absenceDate": absenceDate},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        final listStudentAbsent = UosStudentsAbsentModel.fromJson(data);
        return listStudentAbsent;
      } else {
        throw Exception(
          "Failed to load list students of uos: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch list students of uos: $e");
    }
  }

  Future<bool> isAttendanceDate(
    String idUos,
    DateTime? attendanceDate,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Absence/CheckAttendanceDate",
        queryParameters: {"idUos": idUos, "attendanceDate": attendanceDate},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data;
      } else {
        throw Exception(
          "Failed to check isAttendanceDate: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to check isAttendanceDate: $e");
    }
  }

  Future<bool> isAttendanceDateValid(
    String idUos,
    DateTime? attendanceDate,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Absence/CheckAttendanceDateValid",
        queryParameters: {"idUos": idUos, "attendanceDate": attendanceDate},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data;
      } else {
        throw Exception(
          "Failed to check isAttendanceDateValid: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to check isAttendanceDateValid: $e");
    }
  }

  Future<bool> takeAttendance({
    required String idUnitOfStudy,
    required DateTime absenceDate,
    required List<String> idStudentsAbsent,
    required authToken,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        "$_url/api/Absence/TakeAttendance",
        data: {
          "idUnitOfStudy": idUnitOfStudy,
          "absenceDate": absenceDate.toIso8601String(),
          "idStudentsAbsent": idStudentsAbsent,
        },
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data == "Điểm danh thành công.";
      } else {
        throw Exception(
          "Failed to takeAttendance: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to takeAttendance: $e");
    }
  }

  Future<bool> deleteAttendanceHistory(
    String idUos,
    DateTime? attendanceDate,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.delete(
        "$_url/api/Absence/DeleteAttendanceHistory",
        queryParameters: {"idUos": idUos, "attendanceDate": attendanceDate},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data == "Xoá lịch sử điểm danh thành công.";
      } else {
        throw Exception(
          "Failed to deleteAttendanceHistory: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to deleteAttendanceHistory: $e");
    }
  }

  Future<List<DateTime>> getListAbsentDate(
    String idUos,
    String? idStudent,
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Absence/GetListAbsentDate",
        queryParameters: {
          "idUos": idUos,
          if (idStudent != null) "idStudent": idStudent,
        },
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
      if (response.data["statusCode"] == 200) {
        final List<dynamic> data = response.data["data"];
        return data.map((e) => DateTime.parse(e.toString())).toList();
      } else {
        throw Exception(
          "Failed to getListAbsentDate: ${response.data['message']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to getListAbsentDate: $e");
    }
  }

  Future<bool> updateMsTeamsInfo(
    String token,
    String idUOS,
    String msTeamCode,
    String msTeamLink,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        "$_url/api/UOS/UpdateMsTeamInfo/$idUOS",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: {"msTeamCode": msTeamCode, "msTeamLink": msTeamLink},
      );

      return response.statusCode == 200 &&
          response.data['message'] == 'Success';
    } catch (e) {
      logger.e("Error update Ms Teams info: $e");
      rethrow;
    }
  }

  Future<List<String>> getListStudentForNotiByUos(
    String token,
    String idUOS,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/UOS/GetListStudentsForNotiByUos",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {"idUos": idUOS},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        // map sang list email
        return data
            .map((e) => (e as Map<String, dynamic>)['studentMail'] as String)
            .toList();
      } else {
        throw Exception(
          "Failed to load list students for notification: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Error fetching list students for notification: $e");
      throw Exception("Failed to fetch list students for notification: $e");
    }
  }

  Future<String> createNotificationByIdUOS(
    String token,
    String idUos,
    String title,
    String content,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        "$_url/api/Notification/CreateNotificationByIdUOS",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {"IdUnitOfStudy": idUos, "Title": title, "Content": content},
      );

      if (response.statusCode == 200) {
        final String data = response.data['data'];

        // notificationId
        return data;
      } else {
        throw Exception(
          "Failed to create notification by IdUOS: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to create notification by IdUOS: $e");
      throw Exception("Failed to create notification by IdUOS: $e");
    }
  }

  Future<List<NotiModel>> getNotificationByIdUOS(
    String token,
    String idUOS,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/Notification/GetNotificationByIdUOS",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {"idUos": idUOS},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        // map sang list
        return data
            .map(
              (e) => NotiModel(
                id: e['idNotification'],
                title: e['title'],
                content: e['content'],
                date: DateTime.parse(e['createdDate']),
              ),
            )
            .toList();
      } else {
        throw Exception(
          "Failed to get notification by IdUOS: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Error fetching notification by IdUOS: $e");
      throw Exception("Failed to fetch notification by IdUOS: $e");
    }
  }

  Future<String> deleteNotification(String token, String idNotification) async {
    try {
      final response = await _apiClient.dio.put(
        "$_url/api/Notification/DeleteNotification",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {"idNotification": idNotification},
      );

      if (response.statusCode == 200) {
        final String data = response.data['data'];

        // notificationId
        return data;
      } else {
        throw Exception(
          "Failed to delete notification by IdUOS: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Failed to delete notification by IdUOS: $e");
      throw Exception("Failed to delete notification by IdUOS: $e");
    }
  }

  Future<bool> exportAttendanceSummary(String token, String idUos) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/ExportExcel/ExportAttendanceSummary",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {"idUos": idUos},
      );
      if (response.statusCode == 200) return true;
      
      final msg = response.data['data'] ?? 'Unknown error';
      logger.e("Export failed: $msg");
      return false;
    } catch (e) {
      logger.e("Error export Attendance Summary: $e");
      throw Exception("Error export Attendance Summary: $e");
    }
  }
}
