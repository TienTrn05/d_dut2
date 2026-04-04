import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../academic/presentation/results.dart';
import '../academic/presentation/statistics.dart';
import '../auth/presentation/auth_screen.dart';
import '../chatbot/presentations/chat_bot_screen.dart';
import '../community_activity/data/model/user_proof_model.dart';
import '../community_activity/presentation/screens/community_activities_screen.dart';
import '../community_activity/presentation/screens/detail_user_proof_screen.dart';
import '../course_registration/features/grade/presentation/grade_screen.dart';
import '../course_registration/presentation/screens/course_registration_screen.dart';
import '../homeroom/presentation/screens/detail_homeroom_screen.dart';
import '../homeroom/presentation/screens/list_homeroom_screen.dart';
import '../notification/presentation/notification_screen.dart';
import '../queue/presentation/queue_screen.dart';
import '../root/presentation/root_screen.dart';
import '../schedule/presentation/screens/detail_exam_shift_screen.dart';
import '../schedule/presentation/screens/detail_uos_screen.dart';
import '../schedule/presentation/screens/detail_uos_teacher_screen.dart';
import '../schedule/presentation/screens/schedule_screen.dart';
import '../scientific_profile/presentation/scientific_profile.dart';
import '../tuition_fee/presentations/tuition_fee_screen.dart';
import '../weekly_schedule/presentation/weekly_schedule.dart';
import 'auth_guard.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  final AuthGuard authGuard = AuthGuard();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RootRoute.page, path: '/', guards: [authGuard]),

    AutoRoute(page: AuthRoute.page, path: '/auth'),

    AutoRoute(
      page: NotificationRoute.page,
      path: '/notification',
      guards: [authGuard],
    ),
    AutoRoute(page: ScheduleRoute.page, path: '/schedule', guards: [authGuard]),

    // AutoRoute(page: DetailExamShiftRoute.page, path: '/msteamtool'),
    AutoRoute(
      page: DetailUOSRoute.page,
      path: '/detailUnitOfStudy',
      guards: [authGuard],
    ),
    AutoRoute(
      page: DetailUOSTeacherRoute.page,
      path: '/detailUOSTeacher',
      guards: [authGuard],
    ),
    AutoRoute(
      page: DetailExamShiftRoute.page,
      path: '/detailExamShiftTeacher',
      guards: [authGuard],
    ),

    AutoRoute(
      page: CourseRegistrationRoute.page,
      path: '/courseRegistration',
      guards: [authGuard],
    ),
    AutoRoute(
      page: GradeRoute.page,
      path: '/courseRegistrationGrade',
      guards: [authGuard],
    ),

    // community activity
    AutoRoute(
      page: CommunityActivitiesRoute.page,
      path: '/communityActivities',
      guards: [authGuard],
    ),
    // AutoRoute(page: DetailUOSTeacherRoute.page, path: '/detailUserActivity'),
    AutoRoute(
      page: DetailUserProofRoute.page,
      path: '/detailUserProof',
      guards: [authGuard],
    ),

    // homeroom
    AutoRoute(
      page: ListHomeroomRoute.page,
      path: '/listHomeRoom',
      guards: [authGuard],
    ),
    AutoRoute(
      page: DetailHomeroomRoute.page,
      path: '/detailHomeRoom',
      guards: [authGuard],
    ),

    // academic
    AutoRoute(
      page: ResultsRoute.page,
      path: '/academic/results',
      guards: [authGuard],
    ),
    AutoRoute(
      page: StatisticsRoute.page,
      path: '/academic/statistics',
      guards: [authGuard],
    ),

    // chat bot
    AutoRoute(page: ChatBotRoute.page, path: '/chatBot', guards: [authGuard]),

    // tuition fee
    AutoRoute(
      page: TuitionFeeRoute.page,
      path: '/tuitionFee',
      guards: [authGuard],
    ),

    // weekly schedule
    AutoRoute(
      page: WeeklyScheduleRoute.page,
      path: '/weekly_schedule',
      guards: [authGuard],
    ),

    // scientific profile
    AutoRoute(
      page: ScientificProfileRoute.page,
      path: '/scientific_profile',
      guards: [authGuard],
    ),

    // queue
    AutoRoute(page: QueueRoute.page, path: '/queue', guards: [authGuard]),
  ];
}
