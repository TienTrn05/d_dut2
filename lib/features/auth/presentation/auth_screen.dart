import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Đăng nhập thành công!")),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lỗi: ${state.message}")),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Auth Screen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home', (route) => false);
                  },
                  child: const Text('Sign In'),
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () {
                    context.read<AuthBloc>().add(MicrosoftSignInRequested());
                  },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign with Microsoft'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
