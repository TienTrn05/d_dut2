import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';

import '../bloc/notifications_bloc.dart';
import './widgets/notification_card.dart';

class MyNotifications extends StatelessWidget {
  const MyNotifications({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (contextNoti, state) {
      if (state.myNotificationsStatus == MyNotificationsStatus.loading &&
          state.myNotifications.isEmpty) {
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
      } else if (state.myNotificationsStatus == MyNotificationsStatus.success &&
          state.myNotifications.isEmpty) {
        return const Center(child: Text("Hiện không có thông báo nào"));
      }
      return Column(
        children: [
          // 1. Wrap the ListView with Expanded
          Expanded(
            // 2. Use ListView.builder for better performance with long lists
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              // The total number of items is notifications + 1 for the "Load more" button
              itemCount: state.myNotifications.length + 1,
              itemBuilder: (context, index) {
                // If it's the last item, show the "Load more" button
                if (index == state.myNotifications.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          context.read<NotificationsBloc>().add(
                              MyNotificationsLoadMoreRequested(token: token));
                        },
                        child: (state.myNotificationsStatus ==
                                    MyNotificationsStatus.loading &&
                                state.myNotifications.isNotEmpty)
                            ? Center(
                                child: CircularProgressIndicator(
                                color: context.theme.primaryColor,
                              ))
                            : Text(
                                "Xem thêm",
                                style: TextStyle(
                                  color: context.theme.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: context.theme.grey,
                                ),
                              ),
                      ),
                    ),
                  );
                }

                // Otherwise, build the notification card
                final notification = state.myNotifications[index];
                return NotificationCard(
                  date:
                      "${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}",
                  title: notification.title,
                  content: notification.body,
                  // Use the actual 'read' status from the notification object
                  isRead: notification.read,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
