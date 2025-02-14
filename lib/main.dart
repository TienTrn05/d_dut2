import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/presentation/auth_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(MyApp(navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const MyApp(this.navigatorKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(navigatorKey),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,  // Truyền navigatorKey vào MaterialApp
        home: AuthScreen(),
      ),
    );
  }
}
