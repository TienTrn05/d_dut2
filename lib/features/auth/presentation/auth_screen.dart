import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_microsoft_button.dart';

import '../../../common/extensions/custom_theme_extension.dart';
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
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 80, bottom: 100),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(178),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
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
                            fontFamily: GoogleFonts.baloo2().fontFamily,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'eDUT',
                          style: TextStyle(
                            color: context.theme.primaryColor,
                            fontFamily: GoogleFonts.baloo2().fontFamily,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 24),
                    AuthTextField(
                        hintText: "Tên đăng nhập ...",
                        prefixIcon: "assets/icons/solar_user-bold.png",
                        iconColor: context.theme.primaryColor,
                        controller: TextEditingController()),
                    SizedBox(height: 10),
                    AuthTextField(
                      hintText: "Mật khẩu ...",
                      prefixIcon: "assets/icons/solar_lock-bold.png",
                      iconColor: context.theme.primaryColor,
                      controller: TextEditingController(),
                      obscureText: true,
                      enabledSuffixIcon: true,
                    ),
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
                              value: true,
                              onChanged: (value) {},
                              activeColor: context.theme.primaryColor,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "Nhớ mật khẩu",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: GoogleFonts.notoSans().fontFamily,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(
                              color: context.theme.primaryColor,
                              fontFamily: GoogleFonts.notoSans().fontFamily,
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
                      fillColor: context.theme.primaryColor ?? Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.root, (route) => false);
                      },
                    ),
                    SizedBox(height: 10),
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      return AuthMicrosoftButton(
                          text: "Đăng nhập bằng Microsoft",
                          enabled: state is! AuthLoading,
                          color: context.theme.primaryColor ?? Colors.blue,
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
