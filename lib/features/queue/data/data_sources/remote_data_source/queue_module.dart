import 'package:injectable/injectable.dart';

@module
abstract class QueueModule {
  @Named('queueAPIUrl')
  String get queueAPIUrl => "https://queuemanager.dut.udn.vn";
}
