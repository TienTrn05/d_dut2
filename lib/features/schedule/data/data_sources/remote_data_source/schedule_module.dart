import 'package:injectable/injectable.dart';

@module
abstract class ScheduleModule {
  @Named('scheduleAPIUrl')
  String get scheduleAPIUrl => "https://localhost:7146";
  // String get scheduleAPIUrl => "https://192.168.2.15:7146";
  // String get scheduleAPIUrl => "https://10.10.31.124:7146";
}
