import 'package:e_dut/features/notification/presentation/widgets/notification_card.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
import 'package:flutter/material.dart';

class UosNotiTab extends StatelessWidget {
  final List<NotiModel> notifications;
  final Function(int, String) onDelete;
  const UosNotiTab(
      {super.key, required this.notifications, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        return NotificationCard(
          date: Functions.formatDate(item.date),
          title: item.title,
          content: item.content,
          canDel: true,
          onDelete: () => onDelete(index, item.title),
        );
      },
    );
  }
}
