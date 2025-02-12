import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/root_bloc.dart';

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
                gradient: RadialGradient(
                  colors: List.generate(3, (index) => Color.fromRGBO(247, 249, 252, 1)),
                  center: const Alignment(-1.0, -1.0),
                ),
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.only(top: 10, right: 30, left: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bottomNavigationItem(context, 0, Icons.home, 'Trang chủ'),
                  bottomNavigationItem(context, 1, Icons.search, 'Tra cứu'),
                  bottomNavigationItem(context, 2, Icons.person, 'Cá nhân'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded bottomNavigationItem(BuildContext context, int itemIndex, IconData icon, String text) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontSize: 12,
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
