import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/utils/app_environment.dart';
import 'package:e_dut/core/services/notification_service.dart';
import 'package:e_dut/features/auth/presentation/widgets/auth_microsoft_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/routes/routes.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import '../../loading/loading_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/login_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: SplashScreen(),
      ),
    );
  }
}

class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF2A74BD)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative arcs (3 big partial circles)
          Positioned(
            left: -180,
            bottom: -310,
            child: _circle(450, 0.1),
          ),
          Positioned(
            right: -180,
            bottom: -310,
            child: _circle(450, 0.1),
          ),
          Positioned(
            left: -190,
            bottom: -360,
            child: _circle(450, 0.1),
          ),
          Positioned(
            right: -190,
            bottom: -360,
            child: _circle(450, 0.1),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.85, end: 1.08).chain(
            CurveTween(curve: Curves.easeOutBack),
          ),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.08, end: 1.0).chain(
            CurveTween(curve: Curves.easeIn),
          ),
          weight: 40),
    ]).animate(_controller);

    _controller.forward();

    // Navigate after short delay for a pleasant finish to the animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<LoginBloc>(),
            child: LoginScreen(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackground(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                        tag: 'appLogo',
                        child: _Logo(
                          size: 120,
                        )),
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static PageRoute<void> route() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1200),
      reverseTransitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (context, animation, secondary, child) {
        final fade = animation.drive(
          CurveTween(curve: Interval(0.0, 1.0, curve: Curves.easeInOutCubic)),
        );

        return FadeTransition(
          opacity: fade,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) => BrandBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                      tag: 'appLogo',
                      child: _Logo(
                        size: 120,
                      )),
                  Text("digital DUT",
                      style: GoogleFonts.baloo2(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF133D87),
                        decoration: TextDecoration.none,
                      )),
                  SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                    return AuthMicrosoftButton(
                        text: "Đăng nhập bằng Microsoft",
                        color: context.theme.primaryColor ?? Colors.blue,
                        onPressed: () async {
                          var FCMtoken =
                              await context.read<FirebaseAPI>().init();
                          context
                              .read<AuthBloc>()
                              .add(MicrosoftSignInRequested(FCMtoken ?? ""));
                        });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(AppEnvironment.logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain, errorBuilder: (_, __, ___) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF133D87).withOpacity(0.08),
        ),
        child: const Text(
          'dD',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF133D87),
            letterSpacing: 0.5,
          ),
        ),
      );
    });
  }
}
