import 'package:injectable/injectable.dart';

import '../../data/data_sources/remote_data_source/grade_service.dart';
import '../../data/models/grade.dart';

@injectable
class GradeRepository {
  final GradeService _courseService;

  GradeRepository(this._courseService);

  Future<List<Grade>> getMyGrades(
    String token,
  ) async {
    try {
      final res = await _courseService.getMyGrades(
        token
      );
      return res;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }
}