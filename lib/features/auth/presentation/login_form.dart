import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/auth_microsoft_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.onPressed});

  final Function()? onPressed;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  bool _showContainer = false;

  bool _showTitle = false;
  bool _showSubTitle = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Hiện dần container
    Future.delayed(const Duration(milliseconds: 500), () {
<<<<<<< HEAD
      setState(() => _showContainer = true);
    });

    // Sau đó lần lượt các phần tử
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _showTitle = true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() => _showSubTitle = true);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      setState(() => _showButton = true);
=======
      if (mounted) {
        setState(() => _showTitle = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showSubtitle = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() => _showButton = true);
      }
>>>>>>> 67eb34d4d2aa914856adfde884b3ec0ea3aec2bc
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) => AnimatedOpacity(
        opacity: _showContainer ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: _showTitle ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                "Welcome to digital DUT",
                style: GoogleFonts.baloo2(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
=======
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Title
        AnimatedOpacity(
          opacity: _showTitle ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: Text(
            "Welcome to digital DUT",
            style: GoogleFonts.baloo2(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 36),

        /// Subtitle
        AnimatedOpacity(
          opacity: _showSubtitle ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: Column(
            children: [
              Text(
                "Đăng nhập với tài khoản email của",
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Color(0xFFECECEC),
>>>>>>> 67eb34d4d2aa914856adfde884b3ec0ea3aec2bc
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
<<<<<<< HEAD
            ),
            const SizedBox(height: 36),
            AnimatedOpacity(
              opacity: _showSubTitle ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    "Đăng nhập với tài khoản email của",
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Color(0xFFECECEC),
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Trường (Office 365)",
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Color(0xFFECECEC),
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _showButton ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthMicrosoftButton(
                    text: "ĐĂNG NHẬP",
                    onPressed: () async {
                      var fcmToken = await NotificationService().getFCMToken();
                      context.read<AuthBloc>().add(
                            MicrosoftSignInRequested(fcmToken ?? ""),
                          );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
=======
              Text(
                "Trường (Office 365)",
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Color(0xFFECECEC),
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        /// Button
        AnimatedOpacity(
            opacity: _showButton ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: AuthMicrosoftButton(
              text: "ĐĂNG NHẬP",
              onPressed: widget.onPressed,
            )),
        const SizedBox(height: 18),
      ],
>>>>>>> 67eb34d4d2aa914856adfde884b3ec0ea3aec2bc
    );
  }
}
