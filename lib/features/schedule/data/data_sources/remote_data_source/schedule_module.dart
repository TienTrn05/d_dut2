import 'package:injectable/injectable.dart';

@module
abstract class ScheduleModule {
  @Named('scheduleAPIUrl')
  // String get scheduleAPIUrl => "https://localhost:7146";
  String get scheduleAPIUrl => "https://192.168.2.28:7146";
}
