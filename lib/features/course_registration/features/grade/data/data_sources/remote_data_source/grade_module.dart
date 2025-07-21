import 'package:injectable/injectable.dart';

@module
abstract class GradeModule {
  @Named('courseRegistrationGradeAPIUrl')
  String get courseRegistrationAPIUrl => "https://dangkytinchi.dut.udn.vn";
}
