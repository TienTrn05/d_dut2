import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is AuthAuthenticated) {
              return Text("Đăng nhập thành công! Lấy dữ liệu...");
            } else if (state is AuthUserFetched) {
              return Column(
                children: [
                  Text("Tên: ${state.userData['displayName']}"),
                  Text("Email: ${state.userData['mail']}"),
                ],
              );
            } else if (state is AuthError) {
              return Text("Lỗi: ${state.message}");
            }
            return ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(MicrosoftSignInRequested());
              },
              child: Text("Đăng nhập với Microsoft"),
            );
          },
        ),
      ),
    );
  }
}
