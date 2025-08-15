import 'package:injectable/injectable.dart';

@module
abstract class CourseSectionModule {
  @Named('courseRegistrationAPIUrl')
  String get courseRegistrationAPIUrl => "https://dangkytinchi.dut.udn.vn";
}
