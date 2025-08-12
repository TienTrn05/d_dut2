import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/notification/presentation/widgets/notification_card.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsTab extends StatelessWidget {
  final List<NotiModel> notifications;
  final Function(int, String) onDelete;
  const NotificationsTab(
      {super.key, required this.notifications, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      return RefreshIndicator(
        color: context.theme.primaryColor,
        backgroundColor: Colors.white,
        onRefresh: () async {},
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return NotificationCard(
              date: Functions.formatDate(item.date),
              title: item.title,
              content: item.content,
              isRead: userRole == RoleModel.roleStudent ? item.isRead : false,
              canDel: userRole == RoleModel.roleTeacher ? true : false,
              onDelete: () => onDelete(index, item.title),
            );
          },
        ),
      );
    });
  }
}
