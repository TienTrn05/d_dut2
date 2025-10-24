import 'package:injectable/injectable.dart';

@module
abstract class TuitionFeeModule {
  @Named('tuitionFeeAPIUrl')
  String get tuitionFeeAPIUrl => "https://hocphi.dev.dut.navia.io.vn";
}
