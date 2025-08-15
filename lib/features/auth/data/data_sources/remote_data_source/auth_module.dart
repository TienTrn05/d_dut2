import 'package:injectable/injectable.dart';

@module
abstract class AuthModule {
  @Named('apiUrl')
  String get apiUrl => "https://sso.dut.udn.vn";
}
