import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';

class ScheduleRepository {
  final ScheduleService _scheduleService;

  ScheduleRepository(this._scheduleService);

  Future<List<SemesterModel>> getListSemester() {
    return _scheduleService.getListSemester();
  }
}
