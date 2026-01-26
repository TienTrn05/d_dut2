import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/custom_mail_picker.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_mail_launcher/open_mail_launcher.dart';

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

  String _extractStudentId(dynamic userData) {
    String? v;
    try {
      v = userData.studentId as String?;
    } catch (_) {}
    v ??=
        (() {
          try {
            return userData.studentCode as String?;
          } catch (_) {}
          return null;
        })();
    v ??=
        (() {
          try {
            return userData.code as String?;
          } catch (_) {}
          return null;
        })();
    v ??=
        (() {
          try {
            return userData.userPrincipalName as String?;
          } catch (_) {}
          return null;
        })();

    if (v == null || v.trim().isEmpty) return '';
    final local = v.contains('@') ? v.split('@').first : v;
    final digits =
        RegExp(r'\d+').allMatches(local).map((m) => m.group(0)!).join();

    return digits;
  }

  String _extractTeacherId(dynamic userData) {
    String? v;
    try {
      v = userData.studentId as String?;
    } catch (_) {}
    v ??=
        (() {
          try {
            return userData.studentCode as String?;
          } catch (_) {}
          return null;
        })();
    v ??=
        (() {
          try {
            return userData.code as String?;
          } catch (_) {}
          return null;
        })();
    v ??=
        (() {
          try {
            return userData.userPrincipalName as String?;
          } catch (_) {}
          return null;
        })();

    if (v == null || v.trim().isEmpty) return '';
    final local = v.contains('@') ? v.split('@').first : v;
    final digits =
        RegExp(r'\d+').allMatches(local).map((m) => m.group(0)!).join();

    return digits != "" ? digits : local;
  }

  String _extractEmail(dynamic userData) {
    String? v;
    try {
      v = userData.userPrincipalName as String?;
    } catch (_) {}
    v ??=
        (() {
          try {
            return userData.email as String?;
          } catch (_) {}
          return null;
        })();

    if (v == null) return '';
    v = v.trim();
    return v.contains('@') ? v : '';
  }

  void _openAcademicResults(BuildContext context, AuthUserAuthenticated state) {
    final studentId = _extractStudentId(state.userData);
    if (studentId.isEmpty) {
      CustomSnackbar.showSnackBar(
        context,
        'Thiếu thông tin',
        'Không tìm thấy mã số sinh viên để tải kết quả học tập',
        AlertType.error,
      );
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(Routes.academicResults, arguments: studentId);
  }

  void _openAcademicStats(BuildContext context, AuthUserAuthenticated state) {
    final studentId = _extractStudentId(state.userData);
    if (studentId.isEmpty) {
      CustomSnackbar.showSnackBar(
        context,
        'Thiếu thông tin',
        'Không tìm thấy mã số sinh viên để tải học vụ',
        AlertType.error,
      );
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(Routes.academicStatistics, arguments: studentId);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String weekday = DateFormat.EEEE('vi').format(today);
    final String month = 'Tháng ${today.month}';
    final String day = today.day.toString().padLeft(2, '0');

    Future<void> _sendEmail(
      BuildContext context,
      AuthUserAuthenticated state,
    ) async {
      // Kiểm tra có app Mail nào không
      bool available = await OpenMailLauncher.isMailAppAvailable();
      if (!available) {
        CustomAlertDialog.showCustomDialog(
          context,
          'Không tìm thấy ứng dụng Email',
          "Bạn có thể gửi góp ý trực tiếp đến: tolaptrinh@dut.udn.vn",
          AlertDialogType.warning,
          textCancel: "Đóng",
        );
        return;
      }
      final String userRole = state.userData.role.name;
      bool isStudent = userRole == RoleModel.roleStudent;

      final userId =
          isStudent
              ? _extractStudentId(state.userData)
              : _extractTeacherId(state.userData);

      final emailContent = EmailContent(
        to: ['tolaptrinh@dut.udn.vn'],
        subject: '[$userId] Đóng góp ý kiến cho ứng dụng dDUT',
        body: 'Góp ý về dDUT',
        isHtml: false,
      );

      // Lấy danh sách mail apps
      final apps = await OpenMailLauncher.getMailApps();

      if (apps.isEmpty) {
        // Không có app
        CustomAlertDialog.showCustomDialog(
          context,
          'Không tìm thấy ứng dụng Email',
          "Bạn có thể gửi góp ý trực tiếp đến: tolaptrinh@dut.udn.vn",
          AlertDialogType.warning,
          textCancel: "Đóng",
        );
        return;
      }

      // Nếu chỉ có 1 app → mở thẳng
      if (apps.length == 1) {
        final opened = await OpenMailLauncher.openSpecificMailApp(
          mailApp: apps.first,
          emailContent: emailContent,
        );
        if (!opened) {
          CustomAlertDialog.showCustomDialog(
            context,
            'Không thể mở ứng dụng',
            "Bạn có thể gửi góp ý trực tiếp đến: tolaptrinh@dut.udn.vn",
            AlertDialogType.warning,
            textCancel: "Đóng",
          );
        }
        return;
      }

      // Nếu có nhiều app → hiện dialog custom để chọn
      MailApp? selected = await CustomMailAppPicker.showCustomMailAppPicker(
        context: context,
        mailApps: apps,
        title: "Chọn ứng dụng Email",
        cancelText: "Hủy",
      );

      if (selected != null) {
        final opened = await OpenMailLauncher.openSpecificMailApp(
          mailApp: selected,
          emailContent: emailContent,
        );
        if (!opened) {
          CustomAlertDialog.showCustomDialog(
            context,
            'Không thể mở ứng dụng',
            "Bạn có thể gửi góp ý trực tiếp đến: tolaptrinh@dut.udn.vn",
            AlertDialogType.warning,
            textCancel: "Đóng",
          );
        }
      }
    }

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
                CustomSnackbar.showSnackBar(
                  context,
                  "Thông báo",
                  "Không được phép truy cập",
                  AlertType.warning,
                );
                context.read<DashboardBloc>().add(DashboardResetNavigation());
              } else if (state is DashboardNavigateSuccess) {
                Future.microtask(() async {
                  await Navigator.of(context).pushNamed(state.routeName);
                  if (context.mounted) {
                    context.read<DashboardBloc>().add(
                      DashboardResetNavigation(),
                    );
                  }
                });
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthUserAuthenticated) {
                final String userRole = authState.userData.role.name;
                final String authToken = authState.accessToken;
                context.read<ScheduleBloc>().add(
                  LoadScheduleDashboard(
                    isTeacher: userRole == RoleModel.roleTeacher,
                    authToken: authToken,
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 74),
            child: Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
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
                      },
                    );
                  },
                ),
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
                      BlocConsumer<ScheduleBloc, ScheduleState>(
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is ScheduleInitial) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthUserAuthenticated) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  final String userRole =
                                      authState.userData.role.name;
                                  final String authToken =
                                      authState.accessToken;
                                  context.read<ScheduleBloc>().add(
                                    LoadScheduleDashboard(
                                      isTeacher:
                                          userRole == RoleModel.roleTeacher,
                                      authToken: authToken,
                                    ),
                                  );
                                }
                              });
                            }
                          }
                          if (state is ScheduleLoading) {
                            return Expanded(
                              child: Column(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is ScheduleDashboardLoaded) {
                            return Expanded(
                              child:
                                  state.schedules.isEmpty
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
                                              color:
                                                  context.theme.grey ??
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
                                          children:
                                              state.schedules.map((item) {
                                                return ScheduleItem(
                                                  idSubject:
                                                      (item
                                                              .idUnitOfStudy
                                                              .isNotEmpty
                                                          ? item.idUnitOfStudy
                                                          : item.idExamShift),
                                                  subject: item.subjectName,
                                                  time:
                                                      item.isExam
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
                                gridItems = const [
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
                                            scopes,
                                            Routes.schedule,
                                          ),
                                        );
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/solar_users-group-rounded-broken.svg",
                                      title: "Lớp chủ nhiệm",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                          DashboardNavigateRequested(
                                            scopes,
                                            Routes.listHomeRoom,
                                          ),
                                        );
                                      },
                                    ),

                                    // Update lịch tuần
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/fluent_calendar-work-week-32-regular.svg",
                                      title: "Lịch tuần",
                                      onTap: () {
                                        final auth =
                                            context.read<AuthBloc>().state;
                                        if (auth is! AuthUserAuthenticated) {
                                          CustomSnackbar.showSnackBar(
                                            context,
                                            'Chưa đăng nhập',
                                            'Vui lòng đăng nhập để xem Lịch tuần',
                                            AlertType.warning,
                                          );
                                          return;
                                        }

                                        final email = _extractEmail(
                                          auth.userData,
                                        );
                                        if (email.isEmpty) {
                                          CustomSnackbar.showSnackBar(
                                            context,
                                            'Thiếu thông tin',
                                            'Không tìm thấy email để tải Lịch tuần',
                                            AlertType.error,
                                          );
                                          return;
                                        }

                                        Navigator.of(context).pushNamed(
                                          Routes.weeklySchedule,
                                          arguments: email,
                                        );
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/mdi_microsoft-teams.svg",
                                      title: "Ms Teams tool",
                                      onTap: () async {
                                        final url = Uri.parse(
                                          'https://msteamtool.dut.udn.vn',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode: LaunchMode.inAppBrowserView,
                                          );
                                        } else {
                                          CustomSnackbar.showSnackBar(
                                            context,
                                            'Không thể mở liên kết',
                                            'Vui lòng kiểm tra kết nối internet hoặc thử lại sau',
                                            AlertType.error,
                                          );
                                        }
                                      },
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder:
                                          (context, state) => FeatureCard(
                                            iconUrl:
                                                Assets.icons.svg.chatbotIcon,
                                            title: "Trợ lý dDUT",
                                            onTap: () {
                                              context.read<DashboardBloc>().add(
                                                DashboardNavigateRequested(
                                                  scopes,
                                                  Routes.chatBot,
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder:
                                          (context, state) => FeatureCard(
                                            iconUrl:
                                                "assets/icons/svg/material-symbols_feedback-outline-rounded.svg",
                                            title: "Góp ý",
                                            onTap: () {
                                              if (state
                                                  is AuthUserAuthenticated) {
                                                _sendEmail(context, state);
                                              }
                                            },
                                          ),
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
                                            scopes,
                                            Routes.schedule,
                                          ),
                                        );
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/mage_goals.svg",
                                      title: "Kết quả học tập",
                                      onTap: () {
                                        final auth =
                                            context.read<AuthBloc>().state;
                                        if (auth is AuthUserAuthenticated) {
                                          _openAcademicResults(context, auth);
                                        } else {
                                          CustomSnackbar.showSnackBar(
                                            context,
                                            'Chưa đăng nhập',
                                            'Vui lòng đăng nhập để xem kết quả học tập',
                                            AlertType.warning,
                                          );
                                        }
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/uil_chart-line.svg",
                                      title: "Học vụ",
                                      onTap: () async {
                                        final auth =
                                            context.read<AuthBloc>().state;
                                        if (auth is AuthUserAuthenticated) {
                                          _openAcademicStats(context, auth);
                                        } else {
                                          CustomSnackbar.showSnackBar(
                                            context,
                                            'Chưa đăng nhập',
                                            'Vui lòng đăng nhập để xem học vụ',
                                            AlertType.warning,
                                          );
                                        }
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
                                            scopes,
                                            Routes.detailHomeRoom,
                                          ),
                                        );
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/tabler_coin.svg",
                                      title: "Học phí",
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                          DashboardNavigateRequested(
                                            scopes,
                                            Routes.tuitionFee,
                                          ),
                                        );
                                      },
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/streamline-ultimate_workflow-teamwork-user-high-five.svg",
                                      title: "Hoạt động \ncộng đồng",
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(Routes.communityActivities);
                                      },
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder:
                                          (context, state) => FeatureCard(
                                            iconUrl:
                                                Assets.icons.svg.chatbotIcon,
                                            title: "Trợ lý dDUT",
                                            onTap: () {
                                              context.read<DashboardBloc>().add(
                                                DashboardNavigateRequested(
                                                  scopes,
                                                  Routes.chatBot,
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder:
                                          (context, state) => FeatureCard(
                                            iconUrl:
                                                "assets/icons/svg/material-symbols_feedback-outline-rounded.svg",
                                            title: "Góp ý",
                                            onTap: () {
                                              if (state
                                                  is AuthUserAuthenticated) {
                                                _sendEmail(context, state);
                                              }
                                            },
                                          ),
                                    ),
                                    FeatureCard(
                                      iconUrl:
                                          "assets/icons/svg/tabler_ticket.svg",
                                      title: "Lấy số tổ 1 cửa",
                                      originIconColor: true,
                                      onTap: () {
                                        context.read<DashboardBloc>().add(
                                          DashboardNavigateRequested(
                                            scopes,
                                            Routes.queue,
                                          ),
                                        );
                                      },
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
                          const SizedBox(height: 12),
                        ],
                      ),
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
