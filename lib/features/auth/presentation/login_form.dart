import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/login_bloc.dart';

import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_microsoft_button.dart';

import '../../../common/extensions/custom_theme_extension.dart';
import '../../../common/utils/app_environment.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) => Container(
        padding: EdgeInsets.only(left: 32, right: 32, top: 48, bottom: 38),
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
            Image.asset(
              AppEnvironment.logoPath,
              width: 80,
              height: 80,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Digital DUT",
                  style: TextStyle(
                    color: context.theme.primaryColor,
                    fontFamily: GoogleFonts.baloo2().fontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                )
              ],
            ),
            SizedBox(height: 24),
            AuthTextField(
                hintText: "Tên đăng nhập ...",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    "assets/icons/svg/solar_user-bold.svg",
                  ),
                ),
                iconColor: context.theme.primaryColor,
                onChanged: (value) {
                  context
                      .read<LoginBloc>()
                      .add(LoginUsernameChanged(username: value));
                }),
            SizedBox(height: 8),
            AuthTextField(
              hintText: "Mật khẩu ...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: SvgPicture.asset(
                  "assets/icons/svg/solar_lock-bold.svg",
                ),
              ),
              iconColor: context.theme.primaryColor,
              obscureText: !context.read<LoginBloc>().state.isShowPassword,
              enabledSuffixIcon: true,
              onChanged: (value) {
                context
                    .read<LoginBloc>()
                    .add(LoginPasswordChanged(password: value));
              },
              onShowPasswordChanged: () {
                context.read<LoginBloc>().add(LoginShowPasswordChanged(
                    isShowPassword: !state.isShowPassword));
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: state.isRememberMe,
                  onChanged: (value) {
                    context.read<LoginBloc>().add(LoginRememberMeChanged(
                        isRememberMe: !state.isRememberMe));
                  },
                  activeColor: context.theme.primaryColor,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return AuthButton(
                text: "Đăng nhập",
                fillColor: context.theme.primaryColor ?? Colors.blue,
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLoginRequested(
                      // read data from bloc
                      context.read<LoginBloc>().state.username,
                      context.read<LoginBloc>().state.password));
                },
              );
            }),
            SizedBox(height: 8),
            BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return AuthMicrosoftButton(
                  text: "Đăng nhập bằng Microsoft",
                  color: context.theme.primaryColor ?? Colors.blue,
                  onPressed: () {
                    context.read<AuthBloc>().add(MicrosoftSignInRequested());
                  });
            }),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 14)),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: Text(
                "Quên mật khẩu?",
                style: TextStyle(
                    color: context.theme.primaryColor,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: context.theme
                        .primaryColor, // Đảm bảo màu underline giống màu chữ
                    fontStyle: FontStyle.italic,
                    height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
