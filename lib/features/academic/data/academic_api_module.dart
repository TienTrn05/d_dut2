import 'package:injectable/injectable.dart';

@module
abstract class AcademicApiModule {
  @Named('academicAPIUrl')
  String get academicAPIUrl => "https://xemdiem.dut.udn.vn/api";
}
