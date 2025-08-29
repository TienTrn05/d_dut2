import 'dart:async';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/notification_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/login_bloc.dart';
import 'widgets/auth_microsoft_button.dart';
import '../../../common/extensions/custom_theme_extension.dart';
import '../../../common/utils/app_environment.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  bool _showContainer = false;
  bool _showLogo = false;
  bool _showTitle = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Hiện dần container
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showContainer = true);
    });

    // Sau đó lần lượt các phần tử
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _showLogo = true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => _showTitle = true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() => _showButton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) => AnimatedOpacity(
        opacity: _showContainer ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/svg/logo_dut.svg",
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: Text(
                      "Trường Đại học Bách Khoa - ĐH Đà Nẵng",
                      style: TextStyle(
                          color: context.theme.grey,
                          fontSize: FontSizes.medium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 32,
              ),
              AnimatedOpacity(
                opacity: _showLogo ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: SvgPicture.asset(
                  AppEnvironment.logoPath,
                  width: 100,
                  height: 100,
                  color: context.theme.primaryColor,
                ),
              ),
              AnimatedOpacity(
                opacity: _showTitle ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "Digital DUT",
                  style: GoogleFonts.baloo2(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: context.theme.primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedOpacity(
                opacity: _showButton ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AuthMicrosoftButton(
                      text: "Đăng nhập bằng email Microsoft",
                      color: context.theme.primaryColor ?? Colors.blue,
                      onPressed: () async {
                        var fcmToken =
                            await NotificationService().getFCMToken();
                        context.read<AuthBloc>().add(
                              MicrosoftSignInRequested(fcmToken ?? ""),
                            );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
