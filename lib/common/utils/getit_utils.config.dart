// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:e_dut/common/utils/logger.dart' as _i562;
import 'package:e_dut/core/data/remote/notification_settings_module.dart'
    as _i673;
import 'package:e_dut/core/data/remote/notification_settings_service.dart'
    as _i603;
import 'package:e_dut/features/academic/data/academic_api_client.dart' as _i395;
import 'package:e_dut/features/academic/data/academic_api_module.dart' as _i446;
import 'package:e_dut/features/app/app_router.dart' as _i514;
import 'package:e_dut/features/auth/data/data_sources/remote_data_source/auth_module.dart'
    as _i916;
import 'package:e_dut/features/auth/data/data_sources/remote_data_source/auth_service.dart'
    as _i255;
import 'package:e_dut/features/auth/domain/repository/auth_repo.dart' as _i409;
import 'package:e_dut/features/chatbot/data/services/chatbot_module.dart'
    as _i817;
import 'package:e_dut/features/chatbot/data/services/chatbot_service.dart'
    as _i1005;
import 'package:e_dut/features/chatbot/data/services/conversation_module.dart'
    as _i158;
import 'package:e_dut/features/chatbot/data/services/conversation_service.dart'
    as _i949;
import 'package:e_dut/features/chatbot/domain/repository/chatbot_repo.dart'
    as _i809;
import 'package:e_dut/features/chatbot/domain/repository/conversation_repo.dart'
    as _i733;
import 'package:e_dut/features/community_activity/data/data_sources/remote_data_source/community_module.dart'
    as _i363;
import 'package:e_dut/features/community_activity/data/data_sources/remote_data_source/community_service.dart'
    as _i33;
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart'
    as _i429;
import 'package:e_dut/features/course_registration/data/data_sourses/remote_data_sourse/course_section_module.dart'
    as _i279;
import 'package:e_dut/features/course_registration/data/data_sourses/remote_data_sourse/course_section_service.dart'
    as _i728;
import 'package:e_dut/features/course_registration/data/data_sourses/stream_data_source/signalr_service.dart'
    as _i706;
import 'package:e_dut/features/course_registration/domain/repositories/course_section_repository.dart'
    as _i513;
import 'package:e_dut/features/course_registration/domain/repositories/registration_signalr_repository.dart'
    as _i262;
import 'package:e_dut/features/course_registration/features/grade/data/data_sources/remote_data_source/grade_module.dart'
    as _i594;
import 'package:e_dut/features/course_registration/features/grade/data/data_sources/remote_data_source/grade_service.dart'
    as _i334;
import 'package:e_dut/features/course_registration/features/grade/domain/repositories/grade_repository.dart'
    as _i152;
import 'package:e_dut/features/dashboard/domain/repository/dashboard_repo.dart'
    as _i82;
import 'package:e_dut/features/homeroom/data/data_sources/remote_data_source/homeroom_module.dart'
    as _i448;
import 'package:e_dut/features/homeroom/data/data_sources/remote_data_source/homeroom_service.dart'
    as _i29;
import 'package:e_dut/features/homeroom/domain/repository/homeroom_repo.dart'
    as _i924;
import 'package:e_dut/features/notification/data/data_sources/remote_data_source/notification_module.dart'
    as _i87;
import 'package:e_dut/features/notification/data/data_sources/remote_data_source/notification_service.dart'
    as _i1008;
import 'package:e_dut/features/notification/domain/repositories/notification_repository.dart'
    as _i625;
import 'package:e_dut/features/profile/data/data_sources/remote_data_source/profile_module.dart'
    as _i90;
import 'package:e_dut/features/profile/data/data_sources/remote_data_source/profile_service.dart'
    as _i957;
import 'package:e_dut/features/profile/domain/repository/profile_repository.dart'
    as _i935;
import 'package:e_dut/features/queue/data/data_sources/remote_data_source/queue_module.dart'
    as _i456;
import 'package:e_dut/features/queue/data/data_sources/remote_data_source/queue_service.dart'
    as _i276;
import 'package:e_dut/features/queue/domain/repository/queue_repo.dart'
    as _i880;
import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_module.dart'
    as _i66;
import 'package:e_dut/features/schedule/data/data_sources/remote_data_source/schedule_service.dart'
    as _i3;
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart'
    as _i227;
import 'package:e_dut/features/scientific_profile/data/scientific_profile_repository.dart'
    as _i294;
import 'package:e_dut/features/tuition_fee/data/data_sources/remote_data_sources/tuition_fee_module.dart'
    as _i878;
import 'package:e_dut/features/tuition_fee/data/data_sources/remote_data_sources/tuition_fee_service.dart'
    as _i3;
import 'package:e_dut/features/tuition_fee/domain/repository/tuition_fee_repo.dart'
    as _i1017;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker_flutter/talker_flutter.dart' as _i207;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final loggerModule = _$LoggerModule();
    final conversationModule = _$ConversationModule();
    final communityModule = _$CommunityModule();
    final chatbotModule = _$ChatbotModule();
    final gradeModule = _$GradeModule();
    final notificationModule = _$NotificationModule();
    final scheduleModule = _$ScheduleModule();
    final notificationSettingsModule = _$NotificationSettingsModule();
    final profileModule = _$ProfileModule();
    final homeroomModule = _$HomeroomModule();
    final tuitionFeeModule = _$TuitionFeeModule();
    final authModule = _$AuthModule();
    final queueModule = _$QueueModule();
    final courseSectionModule = _$CourseSectionModule();
    final academicApiModule = _$AcademicApiModule();
    gh.factory<_i706.SignalRService>(() => _i706.SignalRService());
    gh.singleton<_i207.Talker>(() => loggerModule.talker());
    gh.singleton<_i514.AppRouter>(() => _i514.AppRouter());
    gh.singleton<_i82.DashboardRepo>(() => _i82.DashboardRepo());
    gh.lazySingleton<_i294.ScientificProfileRepository>(
      () => _i294.ScientificProfileRepository(),
    );
    gh.factory<String>(
      () => conversationModule.chatbotConversationAPIKey,
      instanceName: 'chatbotConversationAPIKey',
    );
    gh.factory<String>(
      () => communityModule.communityAPIUrl,
      instanceName: 'communityAPIUrl',
    );
    gh.factory<String>(
      () => chatbotModule.chatBotDataPath,
      instanceName: 'chatBotDataPath',
    );
    gh.factory<String>(
      () => gradeModule.courseRegistrationAPIUrl,
      instanceName: 'courseRegistrationGradeAPIUrl',
    );
    gh.factory<String>(
      () => notificationModule.pushNotificationAPIUrl,
      instanceName: 'pushNotificationAPIUrl',
    );
    gh.factory<String>(
      () => scheduleModule.scheduleAPIUrl,
      instanceName: 'scheduleAPIUrl',
    );
    gh.factory<String>(
      () => notificationSettingsModule.notificationSettingsAPIUrl,
      instanceName: 'notificationSettingsAPIUrl',
    );
    gh.factory<String>(
      () => profileModule.profileAPIUrl,
      instanceName: 'profileAPIUrl',
    );
    gh.factory<_i262.RegistrationSignalRRepository>(
      () => _i262.RegistrationSignalRRepository(gh<_i706.SignalRService>()),
    );
    gh.factory<String>(
      () => homeroomModule.homeroomAPIUrl,
      instanceName: 'homeroomAPIUrl',
    );
    gh.factory<_i3.ScheduleService>(
      () => _i3.ScheduleService(gh<String>(instanceName: 'scheduleAPIUrl')),
    );
    gh.factory<String>(
      () => tuitionFeeModule.tuitionFeeAPIUrl,
      instanceName: 'tuitionFeeAPIUrl',
    );
    gh.factory<String>(
      () => conversationModule.chatbotConversationHost,
      instanceName: 'chatbotConversationHost',
    );
    gh.factory<String>(
      () => conversationModule.chatbotConversationChatbotId,
      instanceName: 'chatbotConversationChatbotId',
    );
    gh.factory<String>(() => authModule.apiUrl, instanceName: 'apiUrl');
    gh.factory<String>(
      () => queueModule.queueAPIUrl,
      instanceName: 'queueAPIUrl',
    );
    gh.factory<String>(
      () => courseSectionModule.courseRegistrationAPIUrl,
      instanceName: 'courseRegistrationAPIUrl',
    );
    gh.factory<String>(
      () => academicApiModule.academicAPIUrl,
      instanceName: 'academicAPIUrl',
    );
    gh.factory<String>(
      () => conversationModule.chatbotConversationJwt,
      instanceName: 'chatbotConversationJwt',
    );
    gh.factory<_i395.AcademicApiClient>(
      () => _i395.AcademicApiClient(gh<String>(instanceName: 'academicAPIUrl')),
    );
    gh.singleton<_i227.ScheduleRepository>(
      () => _i227.ScheduleRepository(gh<_i3.ScheduleService>()),
    );
    gh.factory<_i3.TuitionFeeService>(
      () => _i3.TuitionFeeService(gh<String>(instanceName: 'tuitionFeeAPIUrl')),
    );
    gh.factory<_i949.ConversationService>(
      () => _i949.ConversationService(
        gh<String>(instanceName: 'chatbotConversationHost'),
        gh<String>(instanceName: 'chatbotConversationJwt'),
        gh<String>(instanceName: 'chatbotConversationAPIKey'),
        gh<String>(instanceName: 'chatbotConversationChatbotId'),
      ),
    );
    gh.factory<_i29.HomeroomService>(
      () => _i29.HomeroomService(gh<String>(instanceName: 'homeroomAPIUrl')),
    );
    gh.factory<_i1008.NotificationService>(
      () => _i1008.NotificationService(
        gh<String>(instanceName: 'pushNotificationAPIUrl'),
      ),
    );
    gh.factory<_i625.NotificationRepository>(
      () => _i625.NotificationRepository(gh<_i1008.NotificationService>()),
    );
    gh.factory<_i276.QueueService>(
      () => _i276.QueueService(gh<String>(instanceName: 'queueAPIUrl')),
    );
    gh.singleton<_i880.QueueRepository>(
      () => _i880.QueueRepository(gh<_i276.QueueService>()),
    );
    gh.factory<_i1005.ChatbotService>(
      () => _i1005.ChatbotService(gh<String>(instanceName: 'chatBotDataPath')),
    );
    gh.factory<_i728.CourseSectionService>(
      () => _i728.CourseSectionService(
        gh<String>(instanceName: 'courseRegistrationAPIUrl'),
      ),
    );
    gh.factory<_i33.CommunityService>(
      () => _i33.CommunityService(gh<String>(instanceName: 'communityAPIUrl')),
    );
    gh.factory<_i957.ProfileService>(
      () => _i957.ProfileService(gh<String>(instanceName: 'profileAPIUrl')),
    );
    gh.factory<_i334.GradeService>(
      () => _i334.GradeService(
        gh<String>(instanceName: 'courseRegistrationGradeAPIUrl'),
      ),
    );
    gh.factory<_i603.NotificationSettingsService>(
      () => _i603.NotificationSettingsService(
        gh<String>(instanceName: 'notificationSettingsAPIUrl'),
      ),
    );
    gh.factory<_i255.AuthService>(
      () => _i255.AuthService(gh<String>(instanceName: 'apiUrl')),
    );
    gh.singleton<_i1017.TuitionFeeRepository>(
      () => _i1017.TuitionFeeRepository(gh<_i3.TuitionFeeService>()),
    );
    gh.factory<_i513.CourseSectionRepository>(
      () => _i513.CourseSectionRepository(gh<_i728.CourseSectionService>()),
    );
    gh.factory<_i935.ProfileRepository>(
      () => _i935.ProfileRepository(gh<_i957.ProfileService>()),
    );
    gh.factory<_i733.ConversationRepo>(
      () => _i733.ConversationRepo(
        conversationService: gh<_i949.ConversationService>(),
      ),
    );
    gh.factory<_i809.ChatbotRepo>(
      () => _i809.ChatbotRepo(chatbotService: gh<_i1005.ChatbotService>()),
    );
    gh.factory<_i924.HomeroomRepository>(
      () =>
          _i924.HomeroomRepository(homeroomService: gh<_i29.HomeroomService>()),
    );
    gh.factory<_i429.CommunityRepository>(
      () => _i429.CommunityRepository(gh<_i33.CommunityService>()),
    );
    gh.factory<_i152.GradeRepository>(
      () => _i152.GradeRepository(gh<_i334.GradeService>()),
    );
    gh.singleton<_i409.AuthRepository>(
      () => _i409.AuthRepository(gh<_i255.AuthService>()),
    );
    return this;
  }
}

class _$LoggerModule extends _i562.LoggerModule {}

class _$ConversationModule extends _i158.ConversationModule {}

class _$CommunityModule extends _i363.CommunityModule {}

class _$ChatbotModule extends _i817.ChatbotModule {}

class _$GradeModule extends _i594.GradeModule {}

class _$NotificationModule extends _i87.NotificationModule {}

class _$ScheduleModule extends _i66.ScheduleModule {}

class _$NotificationSettingsModule extends _i673.NotificationSettingsModule {}

class _$ProfileModule extends _i90.ProfileModule {}

class _$HomeroomModule extends _i448.HomeroomModule {}

class _$TuitionFeeModule extends _i878.TuitionFeeModule {}

class _$AuthModule extends _i916.AuthModule {}

class _$QueueModule extends _i456.QueueModule {}

class _$CourseSectionModule extends _i279.CourseSectionModule {}

class _$AcademicApiModule extends _i446.AcademicApiModule {}
