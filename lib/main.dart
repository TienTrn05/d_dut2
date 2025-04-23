import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/bloc/auth_bloc.dart';

import 'common/extensions/custom_theme_extension.dart';
import 'common/routes/routes.dart';
import 'common/utils/app_environment.dart';
import 'common/utils/getit_utils.dart';
import 'common/utils/custom_http_overrides.dart';
import 'core/data/local/storage.dart';
import 'features/auth/data/model/user_model.dart';
import 'features/auth/domain/repository/auth_repo.dart';
import 'features/loading/loading_bloc.dart';
import 'features/loading/loading_overlay.dart';

void main() async {
  await AppEnvironment.setup();
  await Storage.setup();
  await GetItUtils.setup();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final UserModel? userData = Storage.user;

  HttpOverrides.global = CustomHttpOverrides();
  runApp(MyApp(
    navigatorKey,
    userData: userData,
  ));
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
          create: (context) =>
              AuthBloc(navigatorKey, getIt.get<AuthRepository>())
                ..add(AuthInitRequested()),
        ),
        BlocProvider(create: (context) => LoadingBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          fontFamily: GoogleFonts.notoSansAnatolianHieroglyphs().fontFamily,
          extensions: [CustomThemeExtension.lightMode],
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeFactor: 1,
                fontSizeDelta: -0.0,
              ),
        ),
        darkTheme: ThemeData(
          fontFamily: GoogleFonts.roboto().fontFamily,
          extensions: [CustomThemeExtension.darkMode],
        ),
        onGenerateRoute: Routes.onGenerateRoute,
        initialRoute: userData != null ? Routes.root : Routes.auth,
        builder: (context, child) {
          return LoadingOverlay(
            child: child!,
          );
        },
      ),
    );
  }
}
