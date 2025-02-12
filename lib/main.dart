import 'package:flutter/material.dart';

import './common/routes/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      onGenerateRoute: Routes.onGenerateRoute,
      initialRoute: Routes.auth,
    );
  }
}
