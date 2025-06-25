import 'package:injectable/injectable.dart';

@module
abstract class AuthModule {
  @Named('apiUrl')
  String get apiUrl => "https://sso.dev.dut.navia.io.vn";
}
