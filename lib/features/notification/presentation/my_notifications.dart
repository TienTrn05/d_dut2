import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';

import '../bloc/notifications_bloc.dart';
import './widgets/notification_card.dart';

class MyNotifications extends StatelessWidget {
  const MyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (contextNoti, state) {
      if (state.myNotificationsStatus == MyNotificationsStatus.loading) {
        return Center(
            child: CircularProgressIndicator(
          color: context.theme.primaryColor,
        ));
      } else if (state.myNotificationsStatus == MyNotificationsStatus.failure) {
        return Center(
          child: Text(
            state.errorMyNotificationsMessage,
            style: TextStyle(color: context.theme.red),
          ),
        );
      } else if (state.myNotifications.isEmpty) {
        return const Center(child: Text("Hiện không có thông báo nào"));
      }
      return ListView(
          padding: EdgeInsets.all(0),
          children: state.myNotifications
              .map((notification) => NotificationCard(
                    date: "${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}",
                    title:
                        notification.title,
                    content:
                        notification.body,
                    isRead: false,
                  ))
              .toList());
    });
  }
}
