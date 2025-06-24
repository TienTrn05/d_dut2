import 'dart:ui';

import 'package:e_dut/features/auth/data/model/activity_status_style.dart';

class UserActivityStatus {
  static const String registered = "registered";
  static const String canceled = "canceled";
  static const String submitted = "submitted";
  static const String approved = "approved";
  static const String rejected = "rejected";

  static const List<String> activityStatusKeys = [
    UserActivityStatus.registered,
    UserActivityStatus.canceled,
    UserActivityStatus.submitted,
    UserActivityStatus.approved,
    UserActivityStatus.rejected,
  ];

  static const Map<String, ActivityStatusStyle> activityStatusStyles = {
    UserActivityStatus.registered: ActivityStatusStyle(
      label: 'Đã đăng ký',
      bgColor: Color(0xFFFCFFE6),
      borderColor: Color(0xFFEAFF8F),
      textColor: Color(0xFF7CB305),
    ),
    UserActivityStatus.canceled: ActivityStatusStyle(
      label: 'Mở đăng ký',
      bgColor: Color(0xFFFFFBE6),
      borderColor: Color(0xFFFFE58F),
      textColor: Color(0xFFD48806),
    ),
    UserActivityStatus.submitted: ActivityStatusStyle(
      label: 'Hoàn thành',
      bgColor: Color(0xFFE6FFFB),
      borderColor: Color(0xFFC3F4EE),
      textColor: Color(0xFF47B5C1),
    ),
    UserActivityStatus.approved: ActivityStatusStyle(
      label: 'Được chấp nhận',
      bgColor: Color(0xFFF6FFED),
      borderColor: Color(0xFFB7EB8F),
      textColor: Color(0xFF389E0D),
    ),
    UserActivityStatus.rejected: ActivityStatusStyle(
      label: 'Bị từ chối',
      bgColor: Color(0xFFFFF1F0),
      borderColor: Color(0xFFFFA39E),
      textColor: Color(0xFFCF1322),
    ),
  };
}
