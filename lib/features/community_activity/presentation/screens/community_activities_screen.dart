import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/all_activities/all_activities_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/user_info/user_info_bloc.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/community_mode/activity_grade.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/community_mode/all_activities.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/community_mode/my_activities.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/community_mode/proof_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class CommunityActivitiesScreen extends StatefulWidget {
  const CommunityActivitiesScreen({super.key});

  @override
  State<CommunityActivitiesScreen> createState() =>
      _CommunityActivitiesScreenState();
}

class _CommunityActivitiesScreenState extends State<CommunityActivitiesScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Tất cả hoạt động",
      "iconPath": "assets/icons/svg/gg_list.svg",
    },
    {
      "title": "Hoạt động của tôi",
      "iconPath": "assets/icons/svg/mynaui_activity-square.svg",
    },
    {
      "title": "Minh chứng của tôi",
      "iconPath": "assets/icons/svg/lucide_file-check-2.svg",
    },
    {
      "title": "Điểm của tôi",
      "iconPath": "assets/icons/svg/ph_list-heart-bold.svg",
    },
  ];
  String selectedMenu = "Tất cả hoạt động";
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is! AuthUserAuthenticated) {
        return Center(
          child: Text(
            'Bạn cần đăng nhập để sử dụng tính năng này.',
            style: TextStyle(fontSize: FontSizes.large),
          ),
        );
      }
      return MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) =>
                    AllActivitiesBloc(getIt.get<CommunityRepository>())),
            BlocProvider(
                create: (_) => UserInfoBloc(getIt.get<CommunityRepository>()))
          ],
          child: Scaffold(
            backgroundColor: context.theme.lightBlue,
            appBar: CustomAppbar(label: selectedMenu),
            body: _buildBodyContent(authState.accessToken),
            floatingActionButton: Builder(
              builder: (context) => Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(2, 2),
                  )
                ]),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  backgroundColor: context.theme.primaryColor,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
              ),
            ),
            endDrawer: Drawer(
                backgroundColor: Colors.white,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 18, right: 18, top: 48, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hoạt động cộng đồng',
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            color: context.theme.primaryColor ?? Colors.blue,
                          ),
                        ),
                      ),
                      Divider(color: context.theme.primaryColor),
                      ...menuItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildMenuItem(
                              item["title"],
                              iconPath: item["iconPath"],
                              isSelected: selectedMenu == item["title"],
                              onPressed: () {
                                setState(() {
                                  selectedMenu = item["title"];
                                });
                                Navigator.pop(context);
                              },
                              context: context,
                            ),
                          )),
                    ],
                  ),
                )),
          ));
    });
  }

  Widget _buildMenuItem(
    String title, {
    required String iconPath,
    required bool isSelected,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? context.theme.primaryColor ?? Colors.blue
            : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.all(16),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.black, BlendMode.srcIn),
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(String authToken) {
    switch (selectedMenu) {
      case "Tất cả hoạt động":
        return AllActivities(authToken: authToken);
      case "Hoạt động của tôi":
        return const MyActivities();
      case "Minh chứng của tôi":
        return const ProofActivity();
      case "Điểm của tôi":
        return const ActivityGrade();
      default:
        return const Center(child: Text("Không tìm thấy nội dung"));
    }
  }
}
