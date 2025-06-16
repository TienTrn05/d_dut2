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
    final String day = '${today.day}';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardBloc(getIt.get<DashboardRepo>()),
        ),
        BlocProvider(
          create: (_) => ScheduleBloc(getIt.get<ScheduleRepository>())
            ..add(LoadSchedulesByDate(inputDate: DateTime.now())),
        ),
      ],
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
                            // fit: BoxFit.scaleDown, //thu nhỏ nếu không đủ chỗ
                            child: Text(
                              day,
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
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
                      BlocBuilder<ScheduleBloc, ScheduleState>(
                        builder: (context, state) {
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
                          } else if (state is SchedulesLoaded) {
                            return Expanded(
                              child: state.schedules.isEmpty
                                  ? Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: SvgPicture.asset(
                                              "assets/icons/svg/undraw_online-calendar_zaoc.svg",
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
                                            idSubject: item.idUnitOfStudy,
                                            subject: item.subjectName,
                                            time: item.isExam
                                                ? "${DateFormat.Hm().format(item.examTime!)}, xuất ${item.noExamShift}, nhóm ${item.noExamGroup}"
                                                : "${item.startStudyTime!.substring(0, 5)} - ${item.endStudyTime!.substring(0, 5)}",
                                            room: item.room,
                                            isExam: item.isExam,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            );
                          } else {
                            return Text("loading");
                          }
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is! AuthUserAuthenticated) {
                                return GridView(
                                    shrinkWrap: true,
                                    clipBehavior: Clip.none,
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          200, // Chiều rộng tối đa của item
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 130,
                                    ),
                                    children: [
                                      FeatureCardSkeleton(),
                                      FeatureCardSkeleton(),
                                    ]);
                              }

                              final List<ScopeModel> scopes =
                                  state.userData.scopes;

                              final String userRole = state.userData.role.name;

                              if (userRole == RoleModel.roleTeacher ||
                                  userRole == RoleModel.roleAdmin) {
                                return GridView(
                                  shrinkWrap: true,
                                  clipBehavior: Clip.none,
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        200, // Chiều rộng tối đa của item
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    mainAxisExtent: 130,
                                  ),
                                  children: [
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_calendar-broken.svg",
                                      title: "Thời khóa biểu",
                                      subtitle: "Tra cứu thời khóa biểu",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                            DashboardNavigateRequested(
                                                scopes, Routes.schedule));
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_calendar-broken.svg",
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

                              return SizedBox(
                                  height: 400,
                                  child: GridView(
                                    clipBehavior: Clip.none,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          200, // Chiều rộng tối đa của item
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 130,
                                    ),
                                    children: [
                                      FeatureCard(
                                        iconUrl:
                                            "assets/icons/svg/solar_calendar-broken.svg",
                                        title: "Thời khóa biểu",
                                        subtitle: "Xem lịch học & thi",
                                        onTap: () {
                                          context.read<DashboardBloc>().add(
                                              DashboardNavigateRequested(
                                                  scopes, Routes.schedule));
                                        },
                                      ),
                                      FeatureCard(
                                        iconUrl:
                                            "assets/icons/svg/mage_goals.svg",
                                        title: "Kết quả học tập",
                                        subtitle: "Tra cứu kết quả học tập",
                                      ),
                                      FeatureCard(
                                        iconUrl:
                                            "assets/icons/svg/tabler_coin.svg",
                                        title: "Học phí",
                                        subtitle: "Học phí",
                                      ),
                                      FeatureCard(
                                        iconUrl:
                                            "assets/icons/svg/carbon_book.svg",
                                        title: "Học phần",
                                        subtitle: "Đăng ký học phần",
                                        onTap: () {
                                          context.read<DashboardBloc>().add(
                                                DashboardNavigateRequested(
                                                    scopes, Routes.courseRegistration),
                                              );
                                        },
                                      ),
                                      FeatureCard(
                                        iconUrl:
                                            "assets/icons/svg/carbon_book.svg",
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
                                  ));
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
