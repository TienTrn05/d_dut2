import 'dart:ui';

import 'package:e_dut/features/auth/data/model/activity_status_style.dart';

import 'activity_status.dart';

class Constant {
  static const List<String> activityStatusKeys = [
    ActivityStatus.registrationExpired,
    ActivityStatus.registrationOpen,
    ActivityStatus.registered,
    ActivityStatus.completed,
    ActivityStatus.full,
  ];
  static const Map<String, ActivityStatusStyle> activityStatusStyles = {
    ActivityStatus.registrationOpen: ActivityStatusStyle(
      label: 'Mở đăng ký',
      bgColor: Color(0xFFFFFBE6),
      borderColor: Color(0xFFFFE58F),
      textColor: Color(0xFFD48806),
    ),
    ActivityStatus.registered: ActivityStatusStyle(
      label: 'Đã đăng ký',
      bgColor: Color(0xFFF6FFED),
      borderColor: Color(0xFFB7EB8F),
      textColor: Color(0xFF389E0D),
    ),
    ActivityStatus.completed: ActivityStatusStyle(
      label: 'Hoàn thành',
      bgColor: Color(0xFFE6FFFB),
      borderColor: Color(0xFFC3F4EE),
      textColor: Color(0xFF47B5C1),
    ),
    ActivityStatus.full: ActivityStatusStyle(
      label: 'Đã đầy',
      bgColor: Color(0xFFFFF1F0),
      borderColor: Color(0xFFFFA39E),
      textColor: Color(0xFFCF1322),
    ),
    ActivityStatus.registrationExpired: ActivityStatusStyle(
      label: 'Hết hạn đăng ký',
      bgColor: Color(0xFFFCFFE6),
      borderColor: Color(0xFFEAFF8F),
      textColor: Color(0xFF7CB305),
    ),
  };
}
