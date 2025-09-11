import 'dart:io';

import 'academic_api_client.dart' as acad;
import '../models/stats_model.dart';

class StatsRepository {
  StatsRepository(this._api);

  final acad.AcademicApiClient _api;

  // Lấy thống kê GPA, ĐRL, tín chỉ theo kỳ + tổng quan.
  Future<StatsModel> fetchStats({required String studentId}) async {
    final id = studentId.trim();
    if (id.isEmpty) {
      throw ArgumentError('studentId is required and must not be empty');
    }

    try {
      final obj = await _api.getObject(
        '/stats',
        query: {'studentId': id},
      );
      return StatsModel.fromJson(obj);
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException('Failed to fetch stats for $id: $e');
    }
  }
}
