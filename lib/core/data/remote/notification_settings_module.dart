import 'package:injectable/injectable.dart';

@module
abstract class NotificationSettingsModule {
  @Named('notificationSettingsAPIUrl')
  String get notificationSettingsAPIUrl => "https://notifications.dut.udn.vn";
}
