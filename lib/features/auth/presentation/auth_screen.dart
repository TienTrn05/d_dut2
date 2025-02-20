import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/routes/routes.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import '../../loading/loading_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/login_bloc.dart';
import 'login_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUserFetched) {
              context.read<LoadingBloc>().add(LoadingHide());
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.root, (route) => false);
            } else if (state is AuthError) {
              context.read<LoadingBloc>().add(LoadingHide());
              CustomSnackbar.showSnackBar(
                  context, "Lỗi đăng nhập", state.message, AlertType.error);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: BlocProvider(
                create: (context) => LoginBloc(),
                child: LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
