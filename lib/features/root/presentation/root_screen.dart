import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainBloc(),
      child: const _MainView(),
    );
  }
}

class _MainView extends StatefulWidget {
  const _MainView();

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  final PageStorageBucket bucket = PageStorageBucket();
  List<Widget> dashBoardScreens = [
    const DashboardScreen(),
    const Placeholder(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.lightBlue,
              ),
              child: BlocBuilder<MainBloc, MainState>(
                builder: (context, state) {
                  return PageStorage(
                    bucket: bucket,
                    child: dashBoardScreens[state.currentPage],
                  );
                },
              ),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.only(right: 30, left: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bottomNavigationItem(context, 0, Icons.home),
                  bottomNavigationItem(context, 1, Icons.search),
                  bottomNavigationItem(context, 2, Icons.person),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded bottomNavigationItem(
      BuildContext context, int itemIndex, IconData icon) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          context.read<MainBloc>().add(ChangePage(itemIndex));
        },
        child: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            bool isSelected = state.currentPage == itemIndex;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 2,
                  width: 78,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Icon(
                  icon,
                  size: 30,
                  color: isSelected
                      ? context.theme.primaryColor
                      : Color.fromRGBO(116, 116, 116, 1),
                ),
                Container(
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
