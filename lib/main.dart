import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/bloc/auth_bloc.dart';

import 'common/extensions/custom_theme_extension.dart';
import 'common/routes/routes.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('accessToken');
  final String? userDataString = prefs.getString('userData');

  runApp(MyApp(
    navigatorKey,
    token: token,
    userData: userDataString != null ? jsonDecode(userDataString) : null,
  ));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String? token;
  final Map<String, dynamic>? userData;

  const MyApp(this.navigatorKey, {super.key, this.token, this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(navigatorKey),
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
