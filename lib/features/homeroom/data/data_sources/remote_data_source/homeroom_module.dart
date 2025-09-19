import 'package:injectable/injectable.dart';

@module
abstract class HomeroomModule {
  @Named('homeroomAPIUrl')
  String get homeroomAPIUrl => "https://profile.dut.udn.vn";
}
