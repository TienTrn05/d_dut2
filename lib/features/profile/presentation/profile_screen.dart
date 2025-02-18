import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/routes/routes.dart';

import '../../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        }
      },
      child: Column(children: [
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
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthUserFetched &&
              state.userData.containsKey('displayName')) {
            return Text(
              state.userData['displayName'] ?? "No Name",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            );
          }
          return Container();
        }),
      ]),
    );
  }
}
