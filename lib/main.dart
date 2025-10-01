import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/bloc/notification_settings/notification_settings_bloc.dart';
import 'core/services/notification_service.dart';
import 'core/services/auto_redirect_service.dart';
import 'features/auth/bloc/auth_bloc.dart';

import 'common/extensions/custom_theme_extension.dart';
import 'common/routes/routes.dart';
import 'common/utils/app_environment.dart';
import 'common/utils/getit_utils.dart';
import 'core/data/local/storage.dart';
import 'core/services/navigation_service.dart';

import 'features/auth/data/model/user_model.dart';
import 'features/auth/domain/repository/auth_repo.dart';
import 'features/loading/loading_bloc.dart';
import 'features/loading/loading_overlay.dart';
import 'features/notification/domain/repositories/notification_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  await AppEnvironment.setup();
  await Storage.setup();
  await GetItUtils.setup();

  await NotificationService().init();
  NotificationService().registerMessageHandlers();

  final details =
      await NotificationService().flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp ?? false) {
    AutoRedirectService.pendingPayload = details!.notificationResponse?.payload;
  }

  final UserModel? userData = Storage.user;

  runApp(MyApp(navigatorKey, userData: userData));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final UserModel? userData;

  const MyApp(this.navigatorKey, {super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AuthBloc(
                navigatorKey,
                getIt.get<AuthRepository>(),
                getIt.get<NotificationRepository>(),
              )..add(AuthInitRequested()),
        ),
        BlocProvider(create: (context) => LoadingBloc()),
        BlocProvider(
          create:
              (context) =>
                  NotificationSettingsBloc()..add(LoadNotificationSettings()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          fontFamily: GoogleFonts.notoSansAnatolianHieroglyphs().fontFamily,
          extensions: [CustomThemeExtension.lightMode],
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontSizeFactor: 1, fontSizeDelta: 0.0),
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          fontFamily: GoogleFonts.roboto().fontFamily,
          extensions: [CustomThemeExtension.darkMode],
        ),
        onGenerateRoute: Routes.onGenerateRoute,
        initialRoute: userData != null ? Routes.root : Routes.auth,
        builder: (context, child) {
          return LoadingOverlay(child: child!);
        },
      ),
    );
  }
}
