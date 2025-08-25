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

class BrandBackground extends StatefulWidget {
  const BrandBackground({super.key, this.child});
  final Widget? child;

  @override
  State<BrandBackground> createState() => _BrandBackgroundState();
}

class _BrandBackgroundState extends State<BrandBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _offset1;
  late Animation<double> _fade1;
  late Animation<Offset> _offset2;
  late Animation<double> _fade2;
  late Animation<Offset> _offset3;
  late Animation<double> _fade3;
  late Animation<Offset> _offset4;
  late Animation<double> _fade4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 2 vòng trên (nhanh hơn)
    _offset1 = Tween(begin: const Offset(0, 0.3), end: Offset(-0.1, 0)).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _fade1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _offset2 = Tween(begin: const Offset(0, 0.3), end: Offset(0.1, 0)).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _fade2 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    // 2 vòng dưới (delay hơn)
    _offset3 = Tween(begin: const Offset(0, 0.3), end: Offset(-0.12, 0))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut)));
    _fade3 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn)));

    _offset4 = Tween(begin: const Offset(0, 0.3), end: Offset(0.12, 0)).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut)));
    _fade4 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          Positioned(
            left: -160,
            bottom: -310,
            child: FadeTransition(
              opacity: _fade1,
              child: SlideTransition(
                position: _offset1,
                child: _circle(450, 0.1),
              ),
            ),
          ),
          Positioned(
            right: -160,
            bottom: -310,
            child: FadeTransition(
              opacity: _fade2,
              child: SlideTransition(
                position: _offset2,
                child: _circle(450, 0.1),
              ),
            ),
          ),
          Positioned(
            left: -180,
            bottom: -360,
            child: FadeTransition(
              opacity: _fade3,
              child: SlideTransition(
                position: _offset3,
                child: _circle(450, 0.1),
              ),
            ),
          ),
          Positioned(
            right: -180,
            bottom: -360,
            child: FadeTransition(
              opacity: _fade4,
              child: SlideTransition(
                position: _offset4,
                child: _circle(450, 0.1),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
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

    // Navigate after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFF2A74BD)],
          ),
        ),
        child: SafeArea(
          bottom: false,
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static PageRoute<void> route() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 2000),
      pageBuilder: (_, __, ___) => const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Mỗi widget có một khoảng fade khác nhau
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );

    _controller.forward();
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
            bottom: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: Hero(
                      tag: 'appLogo',
                      child: _Logo(size: 120),
                    ),
                  ),
                  FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      "digital DUT",
                      style: GoogleFonts.baloo2(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF133D87),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                    return FadeTransition(
                      opacity: _buttonFade,
                      child: AuthMicrosoftButton(
                        text: "Đăng nhập bằng Microsoft",
                        color: context.theme.primaryColor ?? Colors.blue,
                        onPressed: () async {
                          var fcmToken = await NotificationService().getFCMToken();
                          context.read<AuthBloc>().add(
                                MicrosoftSignInRequested(fcmToken ?? ""),
                              );
                        },
                      ),
                    );
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
