import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/features/schedule/data/model/calendar_event_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/full_info_uos_detail_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_students_absent_model.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class ScheduleService {
  final String _url;
  final Dio _dio;

  ScheduleService(@Named('scheduleAPIUrl') String url)
      : _url = url,
        _dio = Dio();

  Future<List<SemesterModel>> getListSemester(String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/Timetable/GetListSemesters",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;

        final List<dynamic> data = responseData['data'];

        final semesters = data.map((e) => SemesterModel.fromJson(e)).toList();
        // semesters.sort(Functions.compareSemesters);
        return semesters;
      } else {
        throw Exception(
            "Failed to load semesters : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Failed to load semesters: $e");
      throw Exception("Failed to fetch semesters: $e");
    }
  }

  Future<List<UosItemModel>> getListUOSBySemester(
      String idSemester, bool isTeacher, String authToken) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _dio.get(
          "$_url/api/Timetable/GetListTeacherTimetablesBySemester",
          queryParameters: {'idSemester': idSemester},
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      } else {
        response = await _dio.get(
          "$_url/api/Timetable/GetListStudentTimetablesBySemester",
          queryParameters: {'idSemester': idSemester},
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      }

      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        return data.map((e) => UosItemModel.fromJson(e)).toList();
      } else {
        throw Exception(
            "Failed to load list UOSItem : ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to fetch UOSItem: $e");
    }
  }

  Future<List<ScheduleItemModel>> getSchedulesByDate(
      DateTime inputDate, bool isTeacher, String authToken) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _dio.get(
          "$_url/api/Timetable/GetListTeacherTimetablesByDate",
          queryParameters: {
            'date': DateFormat('yyyy-MM-dd').format(inputDate),
          },
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      } else {
        response = await _dio.get(
          "$_url/api/Timetable/GetListStudentTimetablesByDate",
          queryParameters: {
            'date': DateFormat('yyyy-MM-dd').format(inputDate),
          },
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      }
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        final schedules = Functions.sortSchedulesByTime(
            data.map((e) => ScheduleItemModel.fromJson(e)).toList());
        return schedules;
      } else {
        throw Exception(
            "Failed to load list ScheduleItem : ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Failed to load ScheduleItem: $e");
      throw Exception("Failed to fetch ScheduleItem: $e");
    }
  }

  Future<List<CalendarEventModel>> getCalendarEvents(
      int month, int year, bool isTeacher, String authToken) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _dio.get(
          "$_url/api/Timetable/GetTeacherCalendarEvents",
          queryParameters: {
            'month': month,
            'year': year,
          },
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      } else {
        response = await _dio.get(
          "$_url/api/Timetable/GetStudentCalendarEvents",
          queryParameters: {
            'month': month,
            'year': year,
          },
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      }

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

  Future<String> getSemesterByDate(DateTime inputDate, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/Timetable/GetWeekSemester",
        queryParameters: {
          'date': DateFormat('yyyy-MM-dd').format(inputDate),
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
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
            "Failed to load idSemester: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Failed to load semester: $e");
      throw Exception("Failed to fetch semester: $e");
    }
  }

  Future<String> getWeekByDate(DateTime inputDate, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/Timetable/GetWeekSemester",
        queryParameters: {
          'date': DateFormat('yyyy-MM-dd').format(inputDate),
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
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
      String idUos, bool isTeacher, String authToken) async {
    try {
      dynamic response;
      if (isTeacher) {
        response = await _dio.get(
          "$_url/api/UOS/GetTeacherUosDetail",
          queryParameters: {'idUos': idUos},
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      } else {
        response = await _dio.get(
          "$_url/api/UOS/GetStudentUosDetail",
          queryParameters: {'idUos': idUos},
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
          }),
        );
      }
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final detailStudentUos = FullInfoUosDetailModel.fromJson(data);

        return detailStudentUos;
      } else {
        throw Exception(
            "Failed to load student uos detail: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to fetch student uos detail: $e");
    }
  }

  Future<ExamShiftDetailModel> getTeacherExamShiftDetail(
      String idExamShift, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/UOS/GetTeacherExamShiftDetail",
        queryParameters: {
          'idExamShift': idExamShift,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final examShiftDetail = ExamShiftDetailModel.fromJson(data);

        return examShiftDetail;
      } else {
        throw Exception(
            "Failed to load exam shift detail: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to fetch student uos detail: $e");
    }
  }

  Future<StudentsExamShiftModel> getListStudentsByExamShift(String idExamShift,
      String keyword, int pageNumber, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/UOS/GetListStudentsByExamShift",
        queryParameters: {
          'idExamShift': idExamShift,
          'keyword': keyword,
          'pageNumber': pageNumber,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data['statusCode'] == 200) {
        final responseData = response.data;
        final data = responseData['data'];
        final listStudents = StudentsExamShiftModel.fromJson(data);

        return listStudents;
      } else {
        throw Exception(
            "Failed to load list students of examshift: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to fetch list students of examshift: $e");
    }
  }

  Future<UosStudentsAbsentModel> getListStudentsByUos(
      String idUos,
      int pageNumber,
      String? keyword,
      DateTime absenceDate,
      String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/UOS/GetListStudentsByUos",
        queryParameters: {
          "idUos": idUos,
          "pageNumber": pageNumber,
          if (keyword != null) "keyword": keyword,
          "absenceDate": absenceDate,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        final listStudentAbsent = UosStudentsAbsentModel.fromJson(data);
        return listStudentAbsent;
      } else {
        throw Exception(
            "Failed to load list students of uos: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to fetch list students of uos: $e");
    }
  }

  Future<bool> isAttendanceDate(
      String idUos, DateTime? attendanceDate, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/Absence/CheckAttendanceDate",
        queryParameters: {
          "idUos": idUos,
          "attendanceDate": attendanceDate,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data;
      } else {
        throw Exception(
            "Failed to check isAttendanceDate: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to check isAttendanceDate: $e");
    }
  }

  Future<bool> takeAttendance(
      {required String idUnitOfStudy,
      required DateTime absenceDate,
      required List<String> idStudentsAbsent,
      required authToken}) async {
    try {
      final response = await _dio.post(
        "$_url/api/Absence/TakeAttendance",
        data: {
          "idUnitOfStudy": idUnitOfStudy,
          "absenceDate": absenceDate.toIso8601String(),
          "idStudentsAbsent": idStudentsAbsent,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data == "Điểm danh thành công.";
      } else {
        throw Exception(
            "Failed to takeAttendance: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to takeAttendance: $e");
    }
  }

  Future<bool> deleteAttendanceHistory(
      String idUos, DateTime? attendanceDate, String authToken) async {
    try {
      final response = await _dio.delete(
        "$_url/api/Absence/DeleteAttendanceHistory",
        queryParameters: {
          "idUos": idUos,
          "attendanceDate": attendanceDate,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data["statusCode"] == 200) {
        final data = response.data["data"];
        return data == "Xoá lịch sử điểm danh thành công.";
      } else {
        throw Exception(
            "Failed to deleteAttendanceHistory: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to deleteAttendanceHistory: $e");
    }
  }

  Future<List<DateTime>> getListAbsentDate(
      String idUos, String? idStudent, String authToken) async {
    try {
      final response = await _dio.get(
        "$_url/api/Absence/GetListAbsentDate",
        queryParameters: {
          "idUos": idUos,
          if (idStudent != null) "idStudent": idStudent,
        },
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );
      if (response.data["statusCode"] == 200) {
        final List<dynamic> data = response.data["data"];
        return data.map((e) => DateTime.parse(e.toString())).toList();
      } else {
        throw Exception(
            "Failed to getListAbsentDate: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Failed to getListAbsentDate: $e");
    }
  }
}
