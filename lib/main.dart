import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import 'core/bloc/notification_settings/notification_settings_bloc.dart';
import 'core/data/local/storage.dart';
import 'core/data/remote/notification_settings_service.dart';
import 'core/services/auto_redirect_service.dart';
import 'core/services/notification_service.dart';

// Common
import 'common/extensions/custom_theme_extension.dart';
import 'common/utils/app_environment.dart';
import 'common/utils/getit_utils.dart';

// Features
import 'features/app/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/model/user_model.dart';
import 'features/auth/domain/repository/auth_repo.dart';
import 'features/loading/loading_bloc.dart';
import 'features/loading/loading_overlay.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/schedule/bloc/schedule/calendar_bloc.dart';
import 'features/schedule/domain/repository/schedule_repo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // Initialize app dependencies
  await AppEnvironment.setup();
  await Storage.setup();
  await GetItUtils.setup();

  // Initialize notification services
  final notificationService = NotificationService();
  await notificationService.init();
  notificationService.registerMessageHandlers();

  // Handle pending payload if app launched from notification
  final details =
      await notificationService.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp ?? false) {
    AutoRedirectService.pendingPayload = details!.notificationResponse?.payload;
  }

  final userData = Storage.user;
  final accessToken = await Storage.accessToken;
  runApp(MyApp(userData: userData, accessToken: accessToken));
}

class MyApp extends StatelessWidget {
  final UserModel? userData;
  final String? accessToken;

  MyApp({super.key, this.userData, this.accessToken});

  final _appRouter = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AuthBloc(
                navigatorKey: _appRouter.navigatorKey,
                authRepository: getIt.get<AuthRepository>(),
                notificationRepository: getIt.get<NotificationRepository>(),
                accessToken: accessToken,
                userData: userData,
              ),
        ),
        BlocProvider(create: (_) => LoadingBloc()),
        BlocProvider(
          create:
              (_) => NotificationSettingsBloc(
                notificationSettingsService:
                    getIt<NotificationSettingsService>(),
              )..add(LoadNotificationSettings()),
        ),

        BlocProvider<CalendarBloc>(
          create: (_) => CalendarBloc(getIt.get<ScheduleRepository>()),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return MultiBlocListener(
            listeners: [
              // 🔔 Auth State Listener
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is! AuthUserAuthenticated) return;

                  final notificationService = NotificationService();
                  final username = state.userData.userPrincipalName;

                  if (Storage.myNotification) {
                    if (await notificationService.areNotificationsAllowed()) {
                      notificationService.subscribeToTopic(
                        "personal_$username",
                      );
                    }
                  } else {
                    notificationService.unsubscribeFromTopic(
                      "personal_$username",
                    );
                  }

                  if (Storage.queueNotification) {
                    if (await notificationService.areNotificationsAllowed()) {
                      notificationService.subscribeToTopic("queue_$username");
                    }
                  } else {
                    notificationService.unsubscribeFromTopic("queue_$username");
                  }
                },
              ),

              // 🔔 Notification Settings Listener
              BlocListener<NotificationSettingsBloc, NotificationSettingsState>(
                listener: (context, state) async {
                  final notificationService = NotificationService();

                  // General Notifications
                  if (state.generalEnabled) {
                    if (await notificationService.areNotificationsAllowed()) {
                      notificationService.subscribeToTopic("general");
                    }
                  } else {
                    notificationService.unsubscribeFromTopic("general");
                  }

                  // Personal Notifications
                  if (authState is AuthUserAuthenticated) {
                    final username = authState.userData.userPrincipalName;
                    if (state.personalEnabled) {
                      if (await notificationService.areNotificationsAllowed()) {
                        notificationService.subscribeToTopic(
                          "personal_$username",
                        );
                      }
                    } else {
                      notificationService.unsubscribeFromTopic(
                        "personal_$username",
                      );
                    }

                    if (Storage.queueNotification) {
                      if (await notificationService.areNotificationsAllowed()) {
                        notificationService.subscribeToTopic("queue_$username");
                      }
                    } else {
                      notificationService.unsubscribeFromTopic(
                        "queue_$username",
                      );
                    }
                  }
                },
              ),
            ],
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: _appRouter.config(),
              theme: _lightTheme(context),
              darkTheme: _darkTheme(),
              builder: (context, child) => LoadingOverlay(child: child!),
            ),
          );
        },
      ),
    );
  }

  ThemeData _lightTheme(BuildContext context) => ThemeData(
    fontFamily: GoogleFonts.notoSansAnatolianHieroglyphs().fontFamily,
    extensions: [CustomThemeExtension.lightMode],
    textTheme: Theme.of(context).textTheme,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF2A74BD), // Color(0xFF2A74BD)
      brightness: Brightness.light,
      background: Colors.white,
    ),
  );

  ThemeData _darkTheme() => ThemeData(
    fontFamily: GoogleFonts.roboto().fontFamily,
    extensions: [CustomThemeExtension.darkMode],
  );
}
