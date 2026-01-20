import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/snackbar/container_snackbar.dart';
import '/core/bloc/notification_settings/notification_settings_bloc.dart';
import '/features/auth/bloc/auth_bloc.dart';
import '/features/auth/data/model/role_model.dart';
import '/features/auth/presentation/unauthorized_page.dart';

import '../bloc/notifications_bloc.dart';
import '../domain/repositories/notification_repository.dart';
import 'general_notifications.dart';
import 'my_notifications.dart';
import 'widgets/custom_time_dropdown.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, required this.initialTabIndex});

  final int initialTabIndex;

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(
        title,
        style: TextStyle(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        padding: EdgeInsets.all(0),
        activeColor: Colors.white,
        activeTrackColor: context.theme.primaryColor,
        inactiveThumbColor: context.theme.grey,
        inactiveTrackColor: context.theme.lightGrey,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (contextAuth, stateAuth) {
        if (stateAuth is! AuthUserAuthenticated) {
          return UnauthorizedPage(title: 'Thông báo');
        }
        final String userRole = stateAuth.userData.role.name;

        final String authToken = stateAuth.accessToken;

        return BlocProvider(
          create:
              (context) =>
                  NotificationsBloc(
                      notificationRepository:
                          getIt.get<NotificationRepository>(),
                    )
                    ..add(
                      MyNotificationsSubscriptionRequested(
                        token: stateAuth.accessToken,
                      ),
                    )
                    ..add(
                      GeneralNotificationsSubscriptionRequested(
                        token: stateAuth.accessToken,
                      ),
                    ),
          child: DefaultTabController(
            length: 2,
            initialIndex: initialTabIndex,
            child: Scaffold(
              appBar: CustomAppbar(
                label: 'Thông báo',
                showNotificationButton: false,
                child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: SvgPicture.asset(
                        Assets.icons.svg.solarSettingsBroken,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ),
              backgroundColor: Colors.white,
              endDrawer: BlocBuilder<
                NotificationSettingsBloc,
                NotificationSettingsState
              >(
                builder: (context, state) {
                  return Drawer(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  Assets.icons.svg.solarBellBold,
                                  colorFilter: ColorFilter.mode(
                                    context.theme.primaryColor ?? Colors.blue,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Thông báo",
                                  style: TextStyle(
                                    fontSize: FontSizes.large,
                                    fontWeight: FontWeight.bold,
                                    color: context.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: context.theme.primaryColor),
                            _buildSwitchTile(
                              context,
                              "Bật thông báo chung",
                              state.generalEnabled,
                              (value) {
                                context.read<NotificationSettingsBloc>().add(
                                  ToggleGeneralNotification(isEnabled: value),
                                );
                              },
                            ),
                            _buildSwitchTile(
                              context,
                              "Bật thông báo của tôi",
                              state.personalEnabled,
                              (value) {
                                context.read<NotificationSettingsBloc>().add(
                                  ToggleMyNotification(
                                    isEnabled: value,
                                    userId:
                                        stateAuth.userData.userPrincipalName,
                                  ),
                                );
                              },
                            ),
                            _buildSwitchTile(
                              context,
                              userRole == RoleModel.roleTeacher
                                  ? "Bật thông báo lịch dạy/coi thi"
                                  : "Bật thông báo lịch học/thi",
                              state.examEnabled,
                              (value) {
                                context.read<NotificationSettingsBloc>().add(
                                  ToggleExamNotification(
                                    isEnabled: value,
                                    authToken: authToken,
                                    isTeacher:
                                        userRole == RoleModel.roleTeacher,
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [CustomTimeDropdown()],
                            ),
                            Expanded(child: SizedBox.shrink()),
                            if (state.errorMessage != null)
                              ContainerSnackbar(
                                title: "Cập nhật thất bại",
                                message: state.errorMessage ?? "Có lỗi xảy ra",
                                alertType: AlertType.error,
                                onClose: () {
                                  context.read<NotificationSettingsBloc>().add(
                                    ClearErrorMessage(),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              body: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    TabBar(
                      labelPadding: EdgeInsets.all(
                        0,
                      ), // Khoảng cách giữa chữ và tab
                      dividerColor:
                          context.theme.primaryColor, // Màu đường chia tab
                      indicator: BoxDecoration(
                        color:
                            context.theme.primaryColor, // Màu nền tab được chọn
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      labelColor: Colors.white, // Màu chữ của tab được chọn
                      unselectedLabelColor:
                          context.theme.grey, // Màu chữ của tab chưa chọn
                      tabs: [
                        Tab(
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Thông báo của tôi",
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Chung",
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TabBarView(
                          children: [
                            MyNotifications(
                              token: stateAuth.accessToken,
                            ), // Nội dung tab 1
                            GeneralNotifications(
                              token: stateAuth.accessToken,
                            ), // Nội dung tab 2
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
      },
    );
  }
}
