import 'package:e_dut/features/schedule/presentation/detail_uos_teacher_screen.dart';
import 'package:flutter/material.dart';

import '../../../features/auth/presentation/auth_screen.dart';
import '../../../features/root/presentation/root_screen.dart';
import '../../../features/notification/presentation/notification_screen.dart';
import '../../../features/schedule/presentation/schedule_screen.dart';
import '../../features/schedule/presentation/exam_shift_detail_screen.dart';

class Routes {
  static const String root = "/";
  static const String auth = "/auth";
  static const String notification = "/notification";
  static const String schedule = "/schedule";
  static const String msteamtool = "/msteamtool";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (context) => const RootScreen());

      case auth:
        return MaterialPageRoute(builder: (context) => const AuthScreen());

      case notification:
        return MaterialPageRoute(
            builder: (settings) => const NotificationScreen());

      case schedule:
        return MaterialPageRoute(
            builder: (context) => const DetailUOSTeacherScreen());

      case msteamtool:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('MSTeamTool Screen'),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('No page route provided'),
            ),
          ),
        );
    }
  }
}
