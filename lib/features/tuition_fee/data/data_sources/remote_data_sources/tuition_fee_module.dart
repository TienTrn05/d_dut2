import 'package:injectable/injectable.dart';

@module
abstract class TuitionFeeModule {
  @Named('tuitionFeeAPIUrl')
  String get tuitionFeeAPIUrl => "https://hocphi.dut.udn.vn";
}
