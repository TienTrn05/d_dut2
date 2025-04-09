import 'package:injectable/injectable.dart';

@module
abstract class ScheduleModule {
  @Named('scheduleAPIUrl')
  String get scheduleAPIUrl => "http://10.10.55.168:5012/";
}
