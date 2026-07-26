// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [ChatBotScreen]
class ChatBotRoute extends PageRouteInfo<void> {
  const ChatBotRoute({List<PageRouteInfo>? children})
    : super(ChatBotRoute.name, initialChildren: children);

  static const String name = 'ChatBotRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatBotScreen();
    },
  );
}

/// generated route for
/// [CommunityActivitiesScreen]
class CommunityActivitiesRoute extends PageRouteInfo<void> {
  const CommunityActivitiesRoute({List<PageRouteInfo>? children})
    : super(CommunityActivitiesRoute.name, initialChildren: children);

  static const String name = 'CommunityActivitiesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CommunityActivitiesScreen();
    },
  );
}

/// generated route for
/// [CourseRegistrationScreen]
class CourseRegistrationRoute extends PageRouteInfo<void> {
  const CourseRegistrationRoute({List<PageRouteInfo>? children})
    : super(CourseRegistrationRoute.name, initialChildren: children);

  static const String name = 'CourseRegistrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CourseRegistrationScreen();
    },
  );
}

/// generated route for
/// [DetailExamShiftScreen]
class DetailExamShiftRoute extends PageRouteInfo<DetailExamShiftRouteArgs> {
  DetailExamShiftRoute({
    Key? key,
    required String idExamShift,
    required String examShiftName,
    required String authToken,
    List<PageRouteInfo>? children,
  }) : super(
         DetailExamShiftRoute.name,
         args: DetailExamShiftRouteArgs(
           key: key,
           idExamShift: idExamShift,
           examShiftName: examShiftName,
           authToken: authToken,
         ),
         initialChildren: children,
       );

  static const String name = 'DetailExamShiftRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailExamShiftRouteArgs>();
      return DetailExamShiftScreen(
        key: args.key,
        idExamShift: args.idExamShift,
        examShiftName: args.examShiftName,
        authToken: args.authToken,
      );
    },
  );
}

class DetailExamShiftRouteArgs {
  const DetailExamShiftRouteArgs({
    this.key,
    required this.idExamShift,
    required this.examShiftName,
    required this.authToken,
  });

  final Key? key;

  final String idExamShift;

  final String examShiftName;

  final String authToken;

  @override
  String toString() {
    return 'DetailExamShiftRouteArgs{key: $key, idExamShift: $idExamShift, examShiftName: $examShiftName, authToken: $authToken}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailExamShiftRouteArgs) return false;
    return key == other.key &&
        idExamShift == other.idExamShift &&
        examShiftName == other.examShiftName &&
        authToken == other.authToken;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      idExamShift.hashCode ^
      examShiftName.hashCode ^
      authToken.hashCode;
}

/// generated route for
/// [DetailHomeroomScreen]
class DetailHomeroomRoute extends PageRouteInfo<DetailHomeroomRouteArgs> {
  DetailHomeroomRoute({
    Key? key,
    String? classId,
    String? homeroomName,
    List<PageRouteInfo>? children,
  }) : super(
         DetailHomeroomRoute.name,
         args: DetailHomeroomRouteArgs(
           key: key,
           classId: classId,
           homeroomName: homeroomName,
         ),
         initialChildren: children,
       );

  static const String name = 'DetailHomeroomRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailHomeroomRouteArgs>(
        orElse: () => const DetailHomeroomRouteArgs(),
      );
      return DetailHomeroomScreen(
        key: args.key,
        classId: args.classId,
        homeroomName: args.homeroomName,
      );
    },
  );
}

class DetailHomeroomRouteArgs {
  const DetailHomeroomRouteArgs({this.key, this.classId, this.homeroomName});

  final Key? key;

  final String? classId;

  final String? homeroomName;

  @override
  String toString() {
    return 'DetailHomeroomRouteArgs{key: $key, classId: $classId, homeroomName: $homeroomName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailHomeroomRouteArgs) return false;
    return key == other.key &&
        classId == other.classId &&
        homeroomName == other.homeroomName;
  }

  @override
  int get hashCode => key.hashCode ^ classId.hashCode ^ homeroomName.hashCode;
}

/// generated route for
/// [DetailUOSScreen]
class DetailUOSRoute extends PageRouteInfo<DetailUOSRouteArgs> {
  DetailUOSRoute({
    Key? key,
    required String idUos,
    List<PageRouteInfo>? children,
  }) : super(
         DetailUOSRoute.name,
         args: DetailUOSRouteArgs(key: key, idUos: idUos),
         initialChildren: children,
       );

  static const String name = 'DetailUOSRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailUOSRouteArgs>();
      return DetailUOSScreen(key: args.key, idUos: args.idUos);
    },
  );
}

class DetailUOSRouteArgs {
  const DetailUOSRouteArgs({this.key, required this.idUos});

  final Key? key;

  final String idUos;

  @override
  String toString() {
    return 'DetailUOSRouteArgs{key: $key, idUos: $idUos}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailUOSRouteArgs) return false;
    return key == other.key && idUos == other.idUos;
  }

  @override
  int get hashCode => key.hashCode ^ idUos.hashCode;
}

/// generated route for
/// [DetailUOSTeacherScreen]
class DetailUOSTeacherRoute extends PageRouteInfo<DetailUOSTeacherRouteArgs> {
  DetailUOSTeacherRoute({
    Key? key,
    required String idUos,
    required DateTime selectedDay,
    List<PageRouteInfo>? children,
  }) : super(
         DetailUOSTeacherRoute.name,
         args: DetailUOSTeacherRouteArgs(
           key: key,
           idUos: idUos,
           selectedDay: selectedDay,
         ),
         initialChildren: children,
       );

  static const String name = 'DetailUOSTeacherRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailUOSTeacherRouteArgs>();
      return DetailUOSTeacherScreen(
        key: args.key,
        idUos: args.idUos,
        selectedDay: args.selectedDay,
      );
    },
  );
}

class DetailUOSTeacherRouteArgs {
  const DetailUOSTeacherRouteArgs({
    this.key,
    required this.idUos,
    required this.selectedDay,
  });

  final Key? key;

  final String idUos;

  final DateTime selectedDay;

  @override
  String toString() {
    return 'DetailUOSTeacherRouteArgs{key: $key, idUos: $idUos, selectedDay: $selectedDay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailUOSTeacherRouteArgs) return false;
    return key == other.key &&
        idUos == other.idUos &&
        selectedDay == other.selectedDay;
  }

  @override
  int get hashCode => key.hashCode ^ idUos.hashCode ^ selectedDay.hashCode;
}

/// generated route for
/// [DetailUserProofScreen]
class DetailUserProofRoute extends PageRouteInfo<DetailUserProofRouteArgs> {
  DetailUserProofRoute({
    Key? key,
    required UserProofModel userProof,
    List<PageRouteInfo>? children,
  }) : super(
         DetailUserProofRoute.name,
         args: DetailUserProofRouteArgs(key: key, userProof: userProof),
         initialChildren: children,
       );

  static const String name = 'DetailUserProofRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailUserProofRouteArgs>();
      return DetailUserProofScreen(key: args.key, userProof: args.userProof);
    },
  );
}

class DetailUserProofRouteArgs {
  const DetailUserProofRouteArgs({this.key, required this.userProof});

  final Key? key;

  final UserProofModel userProof;

  @override
  String toString() {
    return 'DetailUserProofRouteArgs{key: $key, userProof: $userProof}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailUserProofRouteArgs) return false;
    return key == other.key && userProof == other.userProof;
  }

  @override
  int get hashCode => key.hashCode ^ userProof.hashCode;
}

/// generated route for
/// [GradeScreen]
class GradeRoute extends PageRouteInfo<void> {
  const GradeRoute({List<PageRouteInfo>? children})
    : super(GradeRoute.name, initialChildren: children);

  static const String name = 'GradeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GradeScreen();
    },
  );
}

/// generated route for
/// [ListHomeroomScreen]
class ListHomeroomRoute extends PageRouteInfo<void> {
  const ListHomeroomRoute({List<PageRouteInfo>? children})
    : super(ListHomeroomRoute.name, initialChildren: children);

  static const String name = 'ListHomeroomRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ListHomeroomScreen();
    },
  );
}

/// generated route for
/// [NotificationScreen]
class NotificationRoute extends PageRouteInfo<NotificationRouteArgs> {
  NotificationRoute({
    Key? key,
    required int initialTabIndex,
    List<PageRouteInfo>? children,
  }) : super(
         NotificationRoute.name,
         args: NotificationRouteArgs(
           key: key,
           initialTabIndex: initialTabIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationRouteArgs>();
      return NotificationScreen(
        key: args.key,
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class NotificationRouteArgs {
  const NotificationRouteArgs({this.key, required this.initialTabIndex});

  final Key? key;

  final int initialTabIndex;

  @override
  String toString() {
    return 'NotificationRouteArgs{key: $key, initialTabIndex: $initialTabIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationRouteArgs) return false;
    return key == other.key && initialTabIndex == other.initialTabIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialTabIndex.hashCode;
}

/// generated route for
/// [QueueScreen]
class QueueRoute extends PageRouteInfo<void> {
  const QueueRoute({List<PageRouteInfo>? children})
    : super(QueueRoute.name, initialChildren: children);

  static const String name = 'QueueRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QueueScreen();
    },
  );
}

/// generated route for
/// [ResultsPage]
class ResultsRoute extends PageRouteInfo<ResultsRouteArgs> {
  ResultsRoute({
    Key? key,
    required String studentId,
    List<PageRouteInfo>? children,
  }) : super(
         ResultsRoute.name,
         args: ResultsRouteArgs(key: key, studentId: studentId),
         initialChildren: children,
       );

  static const String name = 'ResultsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultsRouteArgs>();
      return ResultsPage(key: args.key, studentId: args.studentId);
    },
  );
}

class ResultsRouteArgs {
  const ResultsRouteArgs({this.key, required this.studentId});

  final Key? key;

  final String studentId;

  @override
  String toString() {
    return 'ResultsRouteArgs{key: $key, studentId: $studentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResultsRouteArgs) return false;
    return key == other.key && studentId == other.studentId;
  }

  @override
  int get hashCode => key.hashCode ^ studentId.hashCode;
}

/// generated route for
/// [RootScreen]
class RootRoute extends PageRouteInfo<void> {
  const RootRoute({List<PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootScreen();
    },
  );
}

/// generated route for
/// [ScheduleScreen]
class ScheduleRoute extends PageRouteInfo<void> {
  const ScheduleRoute({List<PageRouteInfo>? children})
    : super(ScheduleRoute.name, initialChildren: children);

  static const String name = 'ScheduleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScheduleScreen();
    },
  );
}

/// generated route for
/// [ScientificProfileScreen]
class ScientificProfileRoute extends PageRouteInfo<ScientificProfileRouteArgs> {
  ScientificProfileRoute({
    Key? key,
    required String microsoftEmail,
    List<PageRouteInfo>? children,
  }) : super(
         ScientificProfileRoute.name,
         args: ScientificProfileRouteArgs(
           key: key,
           microsoftEmail: microsoftEmail,
         ),
         initialChildren: children,
       );

  static const String name = 'ScientificProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScientificProfileRouteArgs>();
      return ScientificProfileScreen(
        key: args.key,
        microsoftEmail: args.microsoftEmail,
      );
    },
  );
}

class ScientificProfileRouteArgs {
  const ScientificProfileRouteArgs({this.key, required this.microsoftEmail});

  final Key? key;

  final String microsoftEmail;

  @override
  String toString() {
    return 'ScientificProfileRouteArgs{key: $key, microsoftEmail: $microsoftEmail}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScientificProfileRouteArgs) return false;
    return key == other.key && microsoftEmail == other.microsoftEmail;
  }

  @override
  int get hashCode => key.hashCode ^ microsoftEmail.hashCode;
}

/// generated route for
/// [StatisticsPage]
class StatisticsRoute extends PageRouteInfo<StatisticsRouteArgs> {
  StatisticsRoute({
    Key? key,
    required String apiBase,
    List<PageRouteInfo>? children,
  }) : super(
         StatisticsRoute.name,
         args: StatisticsRouteArgs(key: key, apiBase: apiBase),
         initialChildren: children,
       );

  static const String name = 'StatisticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StatisticsRouteArgs>();
      return StatisticsPage(key: args.key, apiBase: args.apiBase);
    },
  );
}

class StatisticsRouteArgs {
  const StatisticsRouteArgs({this.key, required this.apiBase});

  final Key? key;

  final String apiBase;

  @override
  String toString() {
    return 'StatisticsRouteArgs{key: $key, apiBase: $apiBase}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StatisticsRouteArgs) return false;
    return key == other.key && apiBase == other.apiBase;
  }

  @override
  int get hashCode => key.hashCode ^ apiBase.hashCode;
}

/// generated route for
/// [TuitionFeeScreen]
class TuitionFeeRoute extends PageRouteInfo<void> {
  const TuitionFeeRoute({List<PageRouteInfo>? children})
    : super(TuitionFeeRoute.name, initialChildren: children);

  static const String name = 'TuitionFeeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TuitionFeeScreen();
    },
  );
}

/// generated route for
/// [WeeklySchedulePage]
class WeeklyScheduleRoute extends PageRouteInfo<WeeklyScheduleRouteArgs> {
  WeeklyScheduleRoute({
    Key? key,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
         WeeklyScheduleRoute.name,
         args: WeeklyScheduleRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'WeeklyScheduleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WeeklyScheduleRouteArgs>();
      return WeeklySchedulePage(key: args.key, email: args.email);
    },
  );
}

class WeeklyScheduleRouteArgs {
  const WeeklyScheduleRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'WeeklyScheduleRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WeeklyScheduleRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}
