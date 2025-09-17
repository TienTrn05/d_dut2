import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/services/notification_service.dart';
import '../../../common/routes/routes.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import '../../loading/loading_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'login_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
<<<<<<< HEAD
=======
      if (mounted) {
        setState(() => _showLogo = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
>>>>>>> 67eb34d4d2aa914856adfde884b3ec0ea3aec2bc
      if (mounted) {
        setState(() {
          _showForm = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF010099),
              Color(0xFF0048FF),
              Color(0xFF010099),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 92),
                    child: SvgPicture.asset(
                      "assets/icons/svg/logo_dDUTcolor.svg",
                      width: 92,
                      height: 92,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, 120),
                  child: SvgPicture.asset(
                    "assets/icons/svg/bg_pattern.svg",
                    width: MediaQuery.of(context).size.width * 1.1,
                    fit: BoxFit.cover,
                    color: const Color(0xFF0048FF),
                  ),
                ),
              ),
            ],
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                context.read<LoadingBloc>().add(LoadingShow());
              } else if (state is AuthUserAuthenticated) {
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
                child: AnimatedOpacity(
                  opacity: _showForm ? 1 : 0,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
<<<<<<< HEAD
                  child: BlocProvider(
                    create: (context) => LoginBloc(),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
=======
                  child: Padding(
                    padding: EdgeInsets.only(top: 92),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/svg/dDUT_d.svg",
                          width: 92,
                          height: 92,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        SvgPicture.asset(
                          "assets/icons/svg/dDUT_u.svg",
                          width: 52,
                          height: 52,
                          color: Color(0xFFFFFF01),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        SvgPicture.asset(
                          "assets/icons/svg/dDUT_t.svg",
                          width: 52,
                          height: 52,
                          color: Color(0xFFCC0102),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Hình nền dưới
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  opacity: _showLogo ? 1 : 0,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  child: Transform.translate(
                    offset: Offset(0,
                        _showLogo ? 120 : 300), // bắt đầu thấp hơn, trượt lên
                    child: Image.asset(
                      "assets/images/bg_pattern.png",
                      width: MediaQuery.of(context).size.width * 1.1,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showForm ? 1 : 0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    child: LoginForm(
                      onPressed: () async {
                        var fcmToken =
                            await NotificationService().getFCMToken();
                        context.read<AuthBloc>().add(
                              MicrosoftSignInRequested(fcmToken ?? ""),
                            );
                      },
                    ),
                  ),
                ),
              ),
            ]),
>>>>>>> 67eb34d4d2aa914856adfde884b3ec0ea3aec2bc
          ),
        ],
      ),
    );
  }
}
