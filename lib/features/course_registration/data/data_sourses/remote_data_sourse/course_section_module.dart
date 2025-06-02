import 'package:injectable/injectable.dart';

@module
abstract class CourseSectionModule {
  @Named('courseRegistrationAPIUrl')
  String get courseRegistrationAPIUrl => "https://dangkytinchi.dev.dut.udn.vn";
}
