import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/bloc/auth_bloc.dart';

import 'common/extensions/custom_theme_extension.dart';
import 'common/routes/routes.dart';
import 'common/utils/app_environment.dart';
import 'common/utils/getit_utils.dart';
import 'core/data/local/storage.dart';
import 'features/auth/data/model/user_model.dart';
import 'features/auth/domain/repository/auth_repo.dart';

void main() async {
  await AppEnvironment.setup();
  await Storage.setup();
  await GetItUtils.setup();
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final String? token = await Storage.accessToken;
  final UserModel? userData = Storage.user;

  runApp(MyApp(
    navigatorKey,
    token: token,
    userData: userData,
  ));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String? token;
  final UserModel? userData;

  const MyApp(this.navigatorKey, {super.key, this.token, this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(navigatorKey, getIt.get<AuthRepository>())..add(AuthInitRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          fontFamily: GoogleFonts.roboto().fontFamily,
          extensions: [CustomThemeExtension.lightMode], // Gán theme extension
        ),
        darkTheme: ThemeData(
          fontFamily: GoogleFonts.roboto().fontFamily,
          extensions: [CustomThemeExtension.darkMode], // Gán theme extension cho dark mode
        ),
        onGenerateRoute: Routes.onGenerateRoute,
        initialRoute: userData != null ? Routes.root : Routes.auth,
      ),
    );
  }
}
