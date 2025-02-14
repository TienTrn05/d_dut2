import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_microsoft_button.dart';

import '../../../common/routes/routes.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Đường dẫn ảnh
            fit: BoxFit.cover, // Căn chỉnh ảnh phủ toàn màn hình
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUserFetched) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.root, (route) => false);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(178),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'eDUT',
                          style: TextStyle(
                            color: Color.fromRGBO(19, 61, 135, 1),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 24),
                    AuthTextField(
                        hintText: "Tên đăng nhập",
                        controller: TextEditingController()),
                    SizedBox(height: 10),
                    AuthTextField(
                        hintText: "Mật khẩu",
                        prefixIcon: Icons.lock,
                        controller: TextEditingController(),
                        obscureText: true),
                    SizedBox(height: 4),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text("Error message",
                    //       style: TextStyle(color: Colors.red, fontSize: 14),
                    //       textAlign: TextAlign.left),
                    // ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                              // Giảm khoảng cách xung quanh Checkbox
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Nhớ mật khẩu",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                EdgeInsets.zero), // Đặt padding = 0
                            overlayColor: WidgetStateProperty.all(
                                Colors.transparent),
                          ),
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(
                              color: Color.fromRGBO(19, 61, 135, 1),
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    AuthButton(
                      text: "Đăng nhập",
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                      return AuthMicrosoftButton(
                          text: "Đăng nhập bằng Microsoft",
                          enabled: state is! AuthLoading,
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(MicrosoftSignInRequested());
                          });
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
