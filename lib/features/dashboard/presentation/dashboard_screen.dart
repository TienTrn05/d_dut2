import 'package:card_loading/card_loading.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../root/bloc/root_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../domain/repository/dashboard_repo.dart';

import '../../../common/routes/routes.dart';
import '../../../common/utils/getit_utils.dart';
import '../../../common/widgets/snackbar/custom_snackbar.dart';
import './widgets/schedule_item.dart';
import './widgets/feature_card.dart';
import './widgets/feature_card_skeleton.dart';
import './widgets/header.dart';

import '../../auth/data/model/scope_model.dart';

import '../../../common/extensions/custom_theme_extension.dart';
import '../../../features/auth/bloc/auth_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String weekday = DateFormat.EEEE('vi').format(today);
    final String month = 'Tháng ${today.month}';
    final String day = today.day.toString().padLeft(2, '0');

    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardBloc(getIt.get<DashboardRepo>()),
          ),
          BlocProvider(
            create: (context) => ScheduleBloc(getIt.get<ScheduleRepository>()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<DashboardBloc, DashboardState>(
              listener: (context, state) {
                if (state is DashboardPermissionRequested) {
                  CustomSnackbar.showSnackBar(context, "Thông báo",
                      "Không được phép truy cập", AlertType.warning);
                  context.read<DashboardBloc>().add(DashboardResetNavigation());
                } else if (state is DashboardNavigateSuccess) {
                  Future.microtask(() async {
                    await Navigator.of(context).pushNamed(state.routeName);
                    if (context.mounted) {
                      context
                          .read<DashboardBloc>()
                          .add(DashboardResetNavigation());
                    }
                  });
                }
              },
            ),
            BlocListener<AuthBloc, AuthState>(listener: (context, authState) {
              if (authState is AuthUserAuthenticated) {
                final String userRole = authState.userData.role.name;
                final String authToken = authState.accessToken;
                context.read<ScheduleBloc>().add(LoadScheduleDashboard(
                    isTeacher: userRole == RoleModel.roleTeacher,
                    authToken: authToken));
              }
            })
          ],
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 74,
              ),
              child: Column(
                children: [
                  BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                    if (state is! AuthUserAuthenticated) {
                      return const Header(
                        displayName: "title",
                        userPrincipalName: "subtitle",
                        isLoading: true,
                      );
                    }

                    return Header(
                        displayName: state.userData.displayName,
                        userPrincipalName: state.userData.userPrincipalName,
                        onHeaderTap: () {
                          context.read<MainBloc>().add(ChangePage(1));
                        },
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.notification);
                        });
                  }),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weekday,
                              style: TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              month,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: FontSizes.medium,
                                height: 1.25,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: context.theme.primaryColor,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 10),
                        BlocConsumer<ScheduleBloc, ScheduleState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is ScheduleInitial) {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthUserAuthenticated) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (context.mounted) {
                                    final String userRole =
                                        authState.userData.role.name;
                                    final String authToken =
                                        authState.accessToken;
                                    context.read<ScheduleBloc>().add(
                                        LoadScheduleDashboard(
                                            isTeacher: userRole ==
                                                RoleModel.roleTeacher,
                                            authToken: authToken));
                                  }
                                });
                              }
                            }
                            if (state is ScheduleLoading) {
                              return Expanded(
                                  child: Column(
                                children: [
                                  CardLoading(
                                    height: 56,
                                    margin: EdgeInsets.only(bottom: 4),
                                  ),
                                ],
                              ));
                            } else if (state is ScheduleDashboardLoaded) {
                              return Expanded(
                                child: state.schedules.isEmpty
                                    ? Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              child: SvgPicture.asset(
                                                "assets/images/free-schedule.svg",
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Hôm nay không có lịch nào!",
                                            style: TextStyle(
                                              fontSize: FontSizes.medium,
                                              fontWeight: FontWeight.w600,
                                              color: context.theme.grey ??
                                                  Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: state.schedules.map((item) {
                                            return ScheduleItem(
                                              idSubject:
                                                  (item.idUnitOfStudy.isNotEmpty
                                                      ? item.idUnitOfStudy
                                                      : item.idExamShift),
                                              subject: item.subjectName,
                                              time: item.isExam
                                                  ? "${DateFormat.Hm().format(item.examTime!)}, xuất ${item.noExamShift}, nhóm ${item.noExamGroup}"
                                                  : "${item.startStudyTime.substring(0, 5)} - ${item.endStudyTime.substring(0, 5)}",
                                              room: item.room,
                                              isExam: item.isExam,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              List<Widget> gridItems = [];

                              if (state is! AuthUserAuthenticated) {
                                gridItems = [
                                  FeatureCardSkeleton(),
                                  FeatureCardSkeleton(),
                                ];
                              } else {
                                final List<ScopeModel> scopes =
                                    state.userData.scopes;
                                final String userRole =
                                    state.userData.role.name;

                                if (userRole == RoleModel.roleTeacher ||
                                    userRole == RoleModel.roleAdmin) {
                                  gridItems = [
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_calendar-broken.svg",
                                      title: "Thời khóa biểu",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.schedule));
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_users-group-rounded-broken.svg",
                                      title: "Lớp chủ nhiệm",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.listHomeRoom));
                                      },
                                      // disabled: true,
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/fluent_calendar-work-week-32-regular.svg",
                                      title: "Lịch tuần",
                                      onTap: () async {
                                        final url = Uri.parse(
                                            'https://lichtuan.dut.udn.vn');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode:
                                                  LaunchMode.inAppBrowserView);
                                        } else {
                                          CustomSnackbar.showSnackBar(
                                              context,
                                              'Không thể mở liên kết',
                                              'Vui lòng kiểm tra kết nối internet hoặc thử lại sau',
                                              AlertType.error);
                                        }
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/mdi_microsoft-teams.svg",
                                      title: "Ms Teams tool",
                                      onTap: () async {
                                        final url = Uri.parse(
                                            'https://msteamtool.dut.udn.vn');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode:
                                                  LaunchMode.inAppBrowserView);
                                        } else {
                                          CustomSnackbar.showSnackBar(
                                              context,
                                              'Không thể mở liên kết',
                                              'Vui lòng kiểm tra kết nối internet hoặc thử lại sau',
                                              AlertType.error);
                                        }
                                      },
                                    ),
                                  ];
                                } else {
                                  gridItems = [
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_calendar-broken.svg",
                                      title: "Thời khóa biểu",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.schedule));
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/hugeicons_note-edit.svg",
                                      title: "Đăng ký tín chỉ",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(scopes,
                                                Routes.courseRegistration));
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/streamline-ultimate_workflow-teamwork-user-high-five.svg",
                                      title: "Hoạt động \ncộng đồng",
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            Routes.communityActivities);
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_users-group-rounded-broken.svg",
                                      title: "Lớp sinh hoạt",
                                      // disabled: true,
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.detailHomeRoom));
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/mage_goals.svg",
                                      title: "Kết quả học tập",
                                      disabled: true,
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/tabler_coin.svg",
                                      title: "Học phí",
                                      disabled: true,
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/carbon_book.svg",
                                      title: "Chương trình đào tạo",
                                      disabled: true,
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/uil_chart-line.svg",
                                      title: "Thống kê",
                                      disabled: true,
                                    ),
                                  ];
                                }
                              }

                              return GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                clipBehavior: Clip.none,
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 150,
                                ),
                                children: gridItems,
                              );
                            },
                          ),
                          const SizedBox(height: 12)
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ));
  }
}
