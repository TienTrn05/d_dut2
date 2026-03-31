import 'package:auto_route/auto_route.dart';
import 'package:e_dut/features/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/services/notification_service.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import '../../loading/loading_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'login_form.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showForm = false;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showLogo = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showForm = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        SystemNavigator.pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF010099),
                    Color(0xFF0048FF),
                    Color(0xFF010099),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoading) {
                  context.read<LoadingBloc>().add(LoadingShow());
                } else if (state is AuthUserAuthenticated) {
                  context.read<LoadingBloc>().add(LoadingHide());

                  context.router.replaceAll([const RootRoute()]);
                } else if (state is AuthError) {
                  context.read<LoadingBloc>().add(LoadingHide());
                  CustomSnackbar.showSnackBar(
                    context,
                    "Lỗi đăng nhập",
                    state.message,
                    AlertType.error,
                  );
                }
              },
              child: Stack(
                children: [
                  /// Logo trên cùng
                  Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      opacity: _showLogo ? 1 : 0,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
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
                            SizedBox(width: 8),
                            SvgPicture.asset(
                              "assets/icons/svg/dDUT_u.svg",
                              width: 52,
                              height: 52,
                              color: Color(0xFFFFFF01),
                            ),
                            SizedBox(width: 8),
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
                        offset: Offset(
                          0,
                          _showLogo ? 120 : 300,
                        ), // bắt đầu thấp hơn, trượt lên
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
