import 'dart:io';
import '../../../core/services/api_client.dart';
import '../models/stats_model.dart';

class StatsRepository {
  StatsRepository(this._api);
  final ApiClient _api;

  /// Lấy thống kê GPA & tín chỉ.
  Future<StatsModel> fetchStats({required String studentId}) async {
    if (studentId.trim().isEmpty) {
      throw ArgumentError('studentId is required and must not be empty');
    }

    try {
      final obj = await _api.getObject(
        '/stats',
        query: {'studentId': studentId},
      );
      // { semesters: [...], gpaPerSemester: [...], creditsPerSemester: [...], overall: {...} }
      return StatsModel.fromJson(obj);
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException('Failed to fetch stats for $studentId: $e');
    }
  }
}
