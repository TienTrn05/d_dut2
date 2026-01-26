import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/root_bloc.dart';

import '/common/routes/routes.dart';
import '/core/services/auto_redirect_service.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/core/services/app_update_service.dart';

import '../../dashboard/presentation/dashboard_screen.dart';
// import '../../searching/presentation/searching_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => MainBloc(), child: const _MainView());
  }
}

class _MainView extends StatefulWidget {
  const _MainView();

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  List<Widget> dashBoardScreens = [
    const DashboardScreen(),
    // const SearchingScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      AppUpdateService().checkAndPromptUpdate(context);
      final redirect = AutoRedirectService.parsePayload(
        AutoRedirectService.pendingPayload,
      );

      switch (redirect) {
        case AutoRedirectName.redirectToNotificationScreen:
          Navigator.pushNamed(context, Routes.notification);
          break;
        case AutoRedirectName.redirectToNotificationScreenGeneralTab:
          Navigator.pushNamed(context, Routes.notification, arguments: 1);
          break;
        case AutoRedirectName.redirectToScheduleScreen:
          Navigator.pushNamed(context, Routes.schedule);
          break;
        case AutoRedirectName.unknown:
          // Không redirect nếu không xác định được payload
          break;
      }

      AutoRedirectService.pendingPayload = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double bottomItemWidth = 72;

    int itemCount = dashBoardScreens.length;
    double offsetLeft =
        ((screenWidth - 48) - bottomItemWidth * itemCount) / (itemCount + 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(color: context.theme.lightBlue),
              child: BlocBuilder<MainBloc, MainState>(
                builder: (context, state) {
                  return IndexedStack(
                    index: state.currentPage,
                    children: dashBoardScreens,
                  );
                },
              ),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: BlocBuilder<MainBloc, MainState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 0,
                        left:
                            (offsetLeft + bottomItemWidth) * state.currentPage +
                            offsetLeft,
                        child: Container(
                          height: 2,
                          width: bottomItemWidth,
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // Các icon tab
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          bottomNavigationItem(
                            context,
                            0,
                            Assets.icons.svg.iconoirHomeAlt,
                            bottomItemWidth,
                          ),
                          bottomNavigationItem(
                            context,
                            1,
                            Assets.icons.svg.solarUserBroken,
                            bottomItemWidth,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomNavigationItem(
    BuildContext context,
    int itemIndex,
    String iconUrl,
    double width,
  ) {
    return InkWell(
      onTap: () {
        context.read<MainBloc>().add(ChangePage(itemIndex));
      },
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          bool isSelected = state.currentPage == itemIndex;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconUrl,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? (context.theme.primaryColor ?? Colors.blue)
                      : (context.theme.grey ?? Colors.grey),
                  BlendMode.srcIn,
                ),
              ),
              Container(
                height: 2,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
