import 'package:e_dut/features/homeroom/data/data_sources/remote_data_source/homeroom_service.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeroomRepository {
  final HomeroomService _homeroomService;

  HomeroomRepository({required HomeroomService homeroomService})
      : _homeroomService = homeroomService;

  Future<List<StudentModel>> getStudents(String token, String classId) async {
    return _homeroomService.getStudents(token, classId);
  }
}
