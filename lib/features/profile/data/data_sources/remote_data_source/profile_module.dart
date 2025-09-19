import 'package:injectable/injectable.dart';

@module
abstract class ProfileModule {
  @Named('profileAPIUrl')
  String get profileAPIUrl => "https://profile.dut.udn.vn";
}
