import 'package:dio/dio.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:injectable/injectable.dart';

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
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data.map((e) => SemesterModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load semesters : ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Failed to fetch semesters: $e");
    }
  }
}
