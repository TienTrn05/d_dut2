import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';

import '../bloc/notifications_bloc.dart';
import './widgets/notification_card.dart';

class GeneralNotifications extends StatelessWidget {
  const GeneralNotifications({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (contextNoti, state) {
      if (state.generalNotificationsStatus ==
              GeneralNotificationsStatus.loading &&
          state.generalNotifications.isEmpty) {
        return Column(
          children: [
            CardLoading(
              height: 100,
              margin: EdgeInsets.only(bottom: 8),
              borderRadius: BorderRadius.circular(16),
            ),
            CardLoading(
              height: 100,
              margin: EdgeInsets.only(bottom: 8),
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        );
      } else if (state.generalNotificationsStatus ==
          GeneralNotificationsStatus.failure) {
        return Center(
          child: Text(
            state.errorGeneralNotificationsMessage,
            style: TextStyle(color: context.theme.red),
          ),
        );
      } else if (state.generalNotificationsStatus ==
              GeneralNotificationsStatus.success &&
          state.generalNotifications.isEmpty) {
        return Center(
            child: Text("Hiện không có thông báo nào",
                style: TextStyle(color: context.theme.grey ?? Colors.grey)));
      }
      return Column(
        children: [
          // 1. Wrap the ListView with Expanded
          Expanded(
            // 2. Use ListView.builder for better performance with long lists
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              // The total number of items is notifications + 1 for the "Load more" button
              itemCount: state.generalNotifications.length + 1,
              itemBuilder: (context, index) {
                // If it's the last item, show the "Load more" button
                if (index == state.generalNotifications.length) {
                  return Center(
                    child: (state.generalNotificationsStatus ==
                                GeneralNotificationsStatus.loading &&
                            state.generalNotifications.isNotEmpty)
                        ? Column(
                            children: [
                              CardLoading(
                                height: 100,
                                margin: EdgeInsets.only(bottom: 8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              CardLoading(
                                height: 100,
                                margin: EdgeInsets.only(bottom: 8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          )
                        : (state.generalNotificationsStatus ==
                                GeneralNotificationsStatus.unchange
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<NotificationsBloc>().add(
                                        GeneralNotificationsLoadMoreRequested(
                                            token: token));
                                  },
                                  child: Text(
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
                              )),
                  );
                }

                // Otherwise, build the notification card
                final notification = state.generalNotifications[index];
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
