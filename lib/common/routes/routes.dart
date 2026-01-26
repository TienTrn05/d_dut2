import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/screens/community_activities_screen.dart';
import 'package:e_dut/features/community_activity/presentation/screens/detail_user_proof_screen.dart';
import 'package:e_dut/features/homeroom/presentation/screens/detail_homeroom_screen.dart';
import 'package:e_dut/features/homeroom/presentation/screens/list_homeroom_screen.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_args.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_absent_args.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/presentation/screens/detail_uos_screen.dart';
import 'package:e_dut/features/schedule/presentation/screens/detail_exam_shift_screen.dart';
import 'package:e_dut/features/tuition_fee/presentations/tuition_fee_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:e_dut/features/academic/presentation/results.dart';
import 'package:e_dut/features/academic/presentation/statistics.dart';

import '../../../features/auth/presentation/auth_screen.dart';
import '../../../features/root/presentation/root_screen.dart';
import '../../../features/notification/presentation/notification_screen.dart';
import '../../features/chatbot/presentations/chat_bot_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
import '../../features/schedule/presentation/screens/detail_uos_teacher_screen.dart';
import '../../features/course_registration/presentation/screens/course_registration_screen.dart';
import '../../features/course_registration/features/grade/presentation/grade_screen.dart';

import 'package:e_dut/features/weekly_schedule/bloc/weekly_schedule_bloc.dart';
import 'package:e_dut/features/weekly_schedule/presentation/weekly_schedule.dart';
import 'package:e_dut/features/weekly_schedule/data/weekly_schedule_repository.dart';

import 'package:e_dut/features/scientific_profile/bloc/scientific_profile_bloc.dart';
import 'package:e_dut/features/scientific_profile/bloc/scientific_profile_event.dart';
import 'package:e_dut/features/scientific_profile/data/scientific_profile_repository.dart';
import 'package:e_dut/features/scientific_profile/presentation/scientific_profile.dart';

String _resolveApiBase() {
  const fromDefine = String.fromEnvironment('API_BASE', defaultValue: '');
  if (fromDefine.isNotEmpty) return fromDefine;
  try {
    return dotenv.env['API_BASE'] ?? '';
  } catch (_) {
    return '';
  }
}

// Endpoint cho Weekly Schedule
String _resolveWeeklyApiBase() {
  const fromDefine = String.fromEnvironment(
    'WEEKLY_SCHEDULE_API_BASE',
    defaultValue: '',
  );
  if (fromDefine.isNotEmpty) return fromDefine;
  try {
    return dotenv.env['WEEKLY_SCHEDULE_API_BASE'] ?? '';
  } catch (_) {
    return '';
  }
}

// Endpoint cho Scientific Profile
String _resolveScientificApiBase() {
  const fromDefine = String.fromEnvironment(
    'SCIENTIFIC_PROFILE_API_BASE',
    defaultValue: '',
  );
  if (fromDefine.isNotEmpty) return fromDefine;
  try {
    return dotenv.env['SCIENTIFIC_PROFILE_API_BASE'] ?? '';
  } catch (_) {
    return '';
  }
}

class Routes {
  static const String root = "/";
  static const String auth = "/auth";
  static const String notification = "/notification";
  static const String schedule = "/schedule";
  static const String msteamtool = "/msteamtool";

  // timetable
  static const String detailUnitOfStudy = "/detailUnitOfStudy";
  static const String detailUnitOfStudyTeacher = "/detailUOSTeacher";
  static const String detailExamShiftTeacher = "/detailExamShiftTeacher";

  // course registration
  static const String courseRegistration = "/courseRegistration";
  static const String courseRegistrationGrade = "/courseRegistrationGrade";

  // community activity
  static const String communityActivities = "/communityActivities";
  static const String detailUserActivity = "/detailUserActivityScreen";
  static const String detailUserProof = "/detailUserProof";

  // homeroom
  static const String listHomeRoom = "/listHomeRoom";
  static const String detailHomeRoom = "/detailHomeRoom";

  // academic
  static const String academicResults = "/academic/results";
  static const String academicStatistics = "/academic/statistics";

  // chat bot
  static const String chatBot = "/chatBot";

  // tuition fee
  static const String tuitionFee = "/tuitionFee";

  // weekly schedule
  static const String weeklySchedule = "/weekly_schedule";

  // scientific profile
  static const String scientificProfile = "/scientific_profile";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (context) => const RootScreen());

      case auth:
        return MaterialPageRoute(builder: (context) => const AuthScreen());

      case notification:
        final args = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (settings) => NotificationScreen(initialTabIndex: args ?? 0),
        );

      case msteamtool:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('MSTeamTool Screen')),
              ),
        );

      // ***** TIMETABLE ***** //
      case schedule:
        return MaterialPageRoute(builder: (context) => const ScheduleScreen());

      case detailUnitOfStudy:
        final idUos = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DetailUnitOfStudy(idUos: idUos),
        );

      case detailUnitOfStudyTeacher:
        final args = settings.arguments as UosAbsentArgs;
        return MaterialPageRoute(
          builder:
              (context) => DetailUOSTeacherScreen(
                idUos: args.idUos,
                selectedDay: args.selectedDay,
              ),
        );

      case detailExamShiftTeacher:
        final args = settings.arguments as ExamShiftArgs;
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (_) => UosDetailBloc(getIt.get<ScheduleRepository>())..add(
                      LoadExamShiftDetail(
                        idExamShift: args.idExamShift,
                        authToken: args.authToken,
                      ),
                    ),
                child: DetailExamShiftScreen(
                  idExamShift: args.idExamShift,
                  examShiftName: args.examShiftName,
                ),
              ),
        );

      // ***** COURSE REGISTRATION ***** //
      case courseRegistration:
        return MaterialPageRoute(
          builder: (context) => const CourseRegistrationScreen(),
        );

      case courseRegistrationGrade:
        return MaterialPageRoute(builder: (context) => const GradeScreen());

      // ***** COMMUNITY ACTIVITY ***** //
      case communityActivities:
        return MaterialPageRoute(
          builder: (context) => const CommunityActivitiesScreen(),
        );

      case detailUserProof:
        final userProof = settings.arguments as UserProofModel;
        return MaterialPageRoute(
          builder: (context) => DetailUserProofScreen(userProof: userProof),
        );

      // ***** HOMEROOM ***** //
      case listHomeRoom:
        return MaterialPageRoute(builder: (context) => ListHomeroomScreen());

      case detailHomeRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final classId = args?["id"] as String?;
        final homeroomName = args?["name"] as String?;
        return MaterialPageRoute(
          builder:
              (context) => DetailHomeroomScreen(
                classId: classId,
                homeroomName: homeroomName,
              ),
        );

      // ***** ACADEMIC ***** //
      case academicResults:
        {
          final studentId = settings.arguments as String;
          final apiBase = _resolveApiBase();
          return MaterialPageRoute(
            builder:
                (context) =>
                    ResultsPage(studentId: studentId, apiBase: apiBase),
          );
        }

      case academicStatistics:
        {
          final apiBase = _resolveApiBase();
          return MaterialPageRoute(
            builder: (context) => StatisticsPage(apiBase: apiBase),
          );
        }

      // ***** WEEKLY SCHEDULE ***** //
      case weeklySchedule:
        {
          final email = settings.arguments as String;

          final repo = WeeklyScheduleRepository(
            endpoint: _resolveWeeklyApiBase(),
          );

          return MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (_) =>
                          WeeklyScheduleBloc(repo)
                            ..add(WeeklyScheduleRequested(email)),
                  child: WeeklySchedulePage(email: email),
                ),
          );
        }

      // ***** SCIENTIFIC PROFILE ***** //
      case scientificProfile:
        {
          final microsoftEmail = settings.arguments as String;

          return MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (_) => ScientificProfileBloc(
                        getIt.get<ScientificProfileRepository>(),
                      )..add(FetchProfile(microsoftEmail)),
                  child: const ScientificProfileScreen(),
                ),
          );
        }

      case chatBot:
        return MaterialPageRoute(builder: (context) => ChatBotScreen());

      case tuitionFee:
        return MaterialPageRoute(builder: (context) => TuitionFeeScreen());

      // ===== default ===== //
      default:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('No page route provided')),
              ),
        );
    }
  }
}
