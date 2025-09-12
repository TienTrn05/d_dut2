import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/features/notification/presentation/widgets/notification_card.dart';
import 'package:e_dut/features/schedule/data/model/noti_model.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';

import '../../../data/model/unit_of_study/uos_detail_model.dart';

class UosNotiTab extends StatelessWidget {
  final UosDetailModel uosDetail;
  final List<NotiModel> notifications;
  final Future<void> Function() onRefresh;
  final Function(NotiModel) onDelete;
  const UosNotiTab(
      {super.key,
      required this.uosDetail,
      required this.notifications,
      required this.onRefresh,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.theme.primaryColor,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: notifications.isNotEmpty
          ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return NotificationCard(
                  date: Functions.formatDate(item.date),
                  title: item.title,
                  content: item.content,
                  canDel: true,
                  onDelete: () => onDelete(item),
                );
              },
            )
          : Center(
              child: Text(
                'Hiện không có thông báo nào',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.theme.grey ?? Colors.grey),
              ),
            ),
    );
  }
}
