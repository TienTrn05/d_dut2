import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/screens/community_activities_screen.dart';
import 'package:e_dut/features/community_activity/presentation/screens/detail_user_activity_screen.dart';
import 'package:e_dut/features/schedule/presentation/screens/detail_uos_screen.dart';
import 'package:e_dut/features/schedule/presentation/screens/detaitl_exam_shift_screen.dart';
import 'package:flutter/material.dart';

import '../../../features/auth/presentation/auth_screen.dart';
import '../../../features/root/presentation/root_screen.dart';
import '../../../features/notification/presentation/notification_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
import '../../features/schedule/presentation/screens/detail_uos_teacher_screen.dart';
import '../../features/course_registration/presentation/screens/course_registration_screen.dart';
import '../../features/course_registration/features/grade/presentation/grade_screen.dart';

class Routes {
  static const String root = "/";
  static const String auth = "/auth";
  static const String notification = "/notification";
  static const String schedule = "/schedule";
  static const String msteamtool = "/msteamtool";
  static const String detailUnitOfStudy = "/detailUnitOfStudy";
  static const String detailUnitOfStudyTeacher = "/detailUOSTeacher";
  static const String detailExamShiftTeacher = "/detailExamShiftTeacher";
  static const String courseRegistration = "/courseRegistration";
  static const String courseRegistrationGrade = "/courseRegistrationGrade";
  static const String communityActivities = "/communityActivities";
  static const String detailCommunityActivity = "/detailCommunityActivity";
  static const String detailUserActivityScreen = "/detailUserActivityScreen";

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
        return MaterialPageRoute(builder: (context) => const ScheduleScreen());

      case detailUnitOfStudy:
        final idUos = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DetailUnitOfStudy(idUos: idUos),
        );

      case detailUnitOfStudyTeacher:
        final idUos = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DetailUOSTeacherScreen(idUos: idUos),
        );

      case detailExamShiftTeacher:
        return MaterialPageRoute(
            builder: (context) => DetaitlExamShiftScreen());

      case msteamtool:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('MSTeamTool Screen')),
          ),
        );

      case courseRegistration:
        return MaterialPageRoute(
          builder: (context) => const CourseRegistrationScreen(),
        );

      case courseRegistrationGrade:
        return MaterialPageRoute(
          builder: (context) => const GradeScreen(),
        );

      case communityActivities:
        return MaterialPageRoute(
            builder: (context) => const CommunityActivitiesScreen());

      case detailUserActivityScreen:
        final userActivity = settings.arguments as UserActivityModel;
        return MaterialPageRoute(
            builder: (context) =>
                DetailUserActivityScreen(userActivity: userActivity));
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
