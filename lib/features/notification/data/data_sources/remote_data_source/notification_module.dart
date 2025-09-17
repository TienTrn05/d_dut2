import 'package:injectable/injectable.dart';

@module
abstract class NotificationModule {
  @Named('pushNotificationAPIUrl')
  String get pushNotificationAPIUrl => "https://notifications.dut.udn.vn";
}
