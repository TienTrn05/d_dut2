import 'dart:io';

import 'academic_api_client.dart' as acad;
import '../models/stats_model.dart';

class StatsRepository {
  StatsRepository(this._api);
  final acad.AcademicApiClient _api;

  Future<StatsModel> fetchStats({required String authToken}) async {
    try {
      final raw = await _api.getObject(
        '/stats',
        header: {"Authorization": "Bearer $authToken"},
      );
      final normalized = _normalizeStatsJson(raw);
      return StatsModel.fromJson(normalized);
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException('Failed to fetch stats: $e');
    }
  }

  Map<String, dynamic> _normalizeStatsJson(dynamic input) {
    if (input is! Map) return <String, dynamic>{};

    Map<String, dynamic> v = input.cast<String, dynamic>();
    if (v.containsKey('data') && v['data'] is Map) {
      v = (v['data'] as Map).cast<String, dynamic>();
    }

    final hasEnglishKeys =
        v.containsKey('semesters') && v.containsKey('overall');
    if (hasEnglishKeys) return v;

    final kyHocVN = v['Kỳ học'] ?? v['kyHoc'] ?? v['ky_hoc'];
    final gpaVN = v['GPA từng kỳ'] ?? v['gpa_tung_ky'];
    final drlVN = v['Điểm rèn luyện từng kỳ'] ?? v['drl_tung_ky'];
    final tcVN = v['Số tín chỉ đăng ký từng kì'] ?? v['tin_chi_tung_ky'];
    final ovVN = v['Tổng quan'] ?? v['tong_quan'];

    Map<String, dynamic> overall = {};
    if (ovVN is Map) {
      overall = {
        'gpa4': ovVN['GPA thang 4'] ?? ovVN['gpa4'],
        'totalAccumCredits':
            ovVN['Số tín chỉ tích luỹ'] ?? ovVN['totalAccumCredits'],
        'avgConduct': ovVN['Điểm rèn luyện trung bình'] ?? ovVN['avgConduct'],
        'stage': ovVN['Năm học'] ?? ovVN['stage'],
      };
    }

    return {
      'semesters': _toStringList(kyHocVN),
      'gpaPerSemester': _toDoubleList(gpaVN),
      'conductPerSemester': _toDoubleList(drlVN),
      'creditsPerSemester': _toIntList(tcVN),
      'overall': overall,
    };
  }

  List<String> _toStringList(dynamic v) {
    if (v is List) return v.map((e) => '$e').toList();
    return const <String>[];
  }

  List<double> _toDoubleList(dynamic v) {
    if (v is List) {
      return v
          .map((e) {
            if (e is num) return e.toDouble();
            final s = '$e'.replaceAll(',', '.');
            return double.tryParse(s);
          })
          .whereType<double>()
          .toList();
    }
    return const <double>[];
  }

  List<int> _toIntList(dynamic v) {
    if (v is List) {
      return v
          .map((e) {
            if (e is num) return e.toInt();
            return int.tryParse('$e');
          })
          .whereType<int>()
          .toList();
    }
    return const <int>[];
  }
}
