import 'package:flutter/material.dart';

import '../../../common/routes/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          width: double.infinity,
          height: 70,
          color: Colors.blue,
          child: SafeArea(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ))),
      MaterialButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
          },
          child: Text('Logout')),
    ]);
  }
}
