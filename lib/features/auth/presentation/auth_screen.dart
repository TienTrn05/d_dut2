import 'package:flutter/material.dart';

import '../../../common/routes/routes.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Auth Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          MaterialButton(
            minWidth: double.infinity,
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.root, (route) => false);
              },
              child: Text('Sign In')),
        ]),
      ),
    );
  }
}
