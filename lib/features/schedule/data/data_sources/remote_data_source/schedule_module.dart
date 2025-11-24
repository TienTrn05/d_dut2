import 'package:injectable/injectable.dart';

@module
abstract class ScheduleModule {
  @Named('scheduleAPIUrl')
  String get scheduleAPIUrl => "https://timetable.dut.udn.vn";
}
