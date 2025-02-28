import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import '../bloc/dashboard_bloc.dart';
import '../domain/repository/dashboard_repo.dart';

import '../../../common/routes/routes.dart';
import '../../../common/utils/getit_utils.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import './widgets/schedule_item.dart';
import './widgets/feature_card.dart';
import './widgets/notification_button.dart';

import '../../auth/data/model/scope_model.dart';

import '../../../common/extensions/custom_theme_extension.dart';
import '../../../features/auth/bloc/auth_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(getIt.get<DashboardRepo>()),
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardPermissionRequested) {
            CustomSnackbar.showSnackBar(context, "Thông báo",
                "Không được phép truy cập", AlertType.warning);
            context.read<DashboardBloc>().add(DashboardResetNavigation());
          } else if (state is DashboardNavigateSuccess) {
            Future.microtask(() async {
              await Navigator.of(context).pushNamed(state.routeName);
              if (context.mounted) {
                context.read<DashboardBloc>().add(DashboardResetNavigation());
              }
            });
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 74,
            ),
            child: Column(
              children: [
                Container(
                    width: double.infinity,
                    height: 72,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://www.udn.vn/Portals/0/3doan%20bk.jpg',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final String displayName =
                                      (state is AuthUserAuthenticated)
                                          ? state.userData.displayName
                                          : 'No Name';

                                  final String userPrincipalName =
                                      (state is AuthUserAuthenticated)
                                          ? state.userData.userPrincipalName
                                          : 'No Email';

                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          displayName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: GoogleFonts.notoSans()
                                                .fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          userPrincipalName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: GoogleFonts.notoSans()
                                                .fontFamily,
                                            fontSize: 12,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        NotificationButton(
                          notificationCount: 2,
                          onTap: () => {
                            Navigator.of(context).pushNamed(Routes.notification)
                          },
                        ),
                      ],
                    )),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thứ 2',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tháng 2',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            '13',
                            style: TextStyle(
                              color: context.theme.primaryColor,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScheduleItem(
                                subject: 'Điện toán đám mây',
                                time: '7:00 - 9:50',
                                room: 'F109',
                              ),
                              const SizedBox(height: 4),
                              ScheduleItem(
                                subject: 'Lập trình di động',
                                time: '10:00 - 12:50',
                                room: 'F109',
                                isExam: true,
                              ),
                              const SizedBox(height: 4),
                              ScheduleItem(
                                subject: 'Đồ án 1',
                                time: '13:00 - 15:50',
                                room: 'F109',
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<DashboardBloc, DashboardState>(
                            builder: (context, state) {
                              final List<ScopeModel> scopes = context
                                      .read<AuthBloc>()
                                      .state is AuthUserAuthenticated
                                  ? (context.read<AuthBloc>().state
                                          as AuthUserAuthenticated)
                                      .userData
                                      .scopes
                                  : [];

                              final String userType = context
                                      .read<AuthBloc>()
                                      .state is AuthUserAuthenticated
                                  ? (context.read<AuthBloc>().state
                                          as AuthUserAuthenticated)
                                      .userData
                                      .userType
                                      .name
                                  : "Student";

                              if (userType == "Teacher" ||
                                  userType == "Admin") {
                                return GridView(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        200, // Chiều rộng tối đa của item
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                                  children: [
                                    FeatureCard(
                                      icon: Mdi.calendar,
                                      title: "Thời khóa biểu",
                                      subtitle: "Tra cứu thời khóa biểu",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.schedule));
                                      },
                                    ),
                                    FeatureCard(
                                      icon: Mdi.calendar,
                                      title: "Lịch tuần",
                                      subtitle: "Lên lịch họp",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, "/calendar"));
                                      },
                                    ),
                                  ],
                                );
                              }

                              return GridView(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      200, // Chiều rộng tối đa của item
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                children: [
                                  FeatureCard(
                                    icon: Mdi.calendar,
                                    title: "Thời khóa biểu",
                                    subtitle: "Tra cứu thời khóa biểu",
                                    onTap: () {
                                      context.read<DashboardBloc>().add(
                                          DashboardNavigateRequested(
                                              scopes, Routes.schedule));
                                    },
                                  ),
                                  FeatureCard(
                                    icon: Mdi.book_open,
                                    title: "Kết quả học tập",
                                    subtitle: "Tra cứu kết quả học tập",
                                  ),
                                  FeatureCard(
                                    icon: Mdi.cash,
                                    title: "Học phí",
                                    subtitle: "Học phí",
                                  ),
                                  FeatureCard(
                                    icon: Mdi.book_alert,
                                    title: "Chương trình đào tạo",
                                    subtitle: "Chương trình đào tạo",
                                  ),
                                  FeatureCard(
                                    icon: Mdi.calendar,
                                    title: "MS Team tool",
                                    subtitle: "Học trực tuyến",
                                    onTap: () {
                                      context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.msteamtool),
                                          );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
