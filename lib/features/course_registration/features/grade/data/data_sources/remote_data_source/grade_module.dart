import 'package:injectable/injectable.dart';

@module
abstract class GradeModule {
  @Named('courseRegistrationGradeAPIUrl')
  String get courseRegistrationAPIUrl => "https://dangkytinchi.dev.dut.udn.vn";
}
