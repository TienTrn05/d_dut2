import 'package:injectable/injectable.dart';

@module
abstract class CourseSectionModule {
  @Named('courseRegistrationAPIUrl')
  String get courseRegistrationAPIUrl => "https://wifi.dev.dut.udn.vn";
}
