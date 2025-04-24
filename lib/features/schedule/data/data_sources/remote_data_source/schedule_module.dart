import 'package:injectable/injectable.dart';

@module
abstract class ScheduleModule {
  @Named('scheduleAPIUrl')
  // String get scheduleAPIUrl => "https://localhost:7146";
  String get scheduleAPIUrl => "https://10.10.25.109:7146";
}
