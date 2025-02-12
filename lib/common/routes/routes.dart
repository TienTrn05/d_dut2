import 'package:flutter/material.dart';

import '../../../features/auth/presentation/auth_screen.dart';
import '../../../features/root/presentation/root_screen.dart';

class Routes {
  static const String root = "/";
  static const String auth = "/auth";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (context) => const RootScreen());

      case auth:
        return MaterialPageRoute(builder: (context) => const AuthScreen());

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
