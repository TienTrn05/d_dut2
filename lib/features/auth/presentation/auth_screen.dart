import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/routes/routes.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import '../../../common/widgets/loading/custom_loading.dart'; // Import CustomLoading
import '../bloc/auth_bloc.dart';
import '../bloc/login_bloc.dart';
import 'login_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUserFetched) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.root, (route) => false);
                } else if (state is AuthError) {
                  CustomSnackbar.showSnackBar(context, "Lỗi đăng nhập", state.message, AlertType.error);
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

          /// Hiển thị Loading khi AuthLoading state xuất hiện
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return Container(
                  color: Colors.black.withAlpha(80),
                  child: CustomLoading(
                    message: "Đang xử lý...",
                    size: 60.0,
                  ),
                );
              }
              return SizedBox.shrink(); // Không hiển thị gì nếu không loading
            },
          ),
        ],
      ),
    );
  }
}
