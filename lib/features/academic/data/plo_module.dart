import 'package:injectable/injectable.dart';

@module
abstract class PLOModule {
  @Named('ploAPIUrl')
  String get ploAPIUrl => "https://chuandaura.dut.udn.vn";
}
