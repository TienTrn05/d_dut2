import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../bloc/root_bloc.dart';

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

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (_) => AppUpdateService().checkAndPromptUpdate(context),
    );
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
                            "assets/icons/svg/iconoir_home-alt.svg",
                            bottomItemWidth,
                          ),
                          // bottomNavigationItem(
                          //     context,
                          //     1,
                          //     "assets/icons/svg/flowbite_search-outline.svg",
                          //     bottomItemWidth),
                          bottomNavigationItem(
                            context,
                            1,
                            "assets/icons/svg/solar_user-broken.svg",
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
