import 'package:flutter/material.dart';

import './widgets/notification_card.dart';

class GeneralNotifications extends StatelessWidget {
  const GeneralNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        NotificationCard(
          date: "14/02/2025",
          title: "Thông báo thu học phí kỳ II năm học 2024-2025 (đợt 1)",
          content: "Sinh viên xem thông báo tại đây",
        ),
        NotificationCard(
          date: "14/02/2025",
          title:
              "Khảo sát lấy ý kiến đánh giá khóa học đối với sinh viên hoàn thành CTĐT",
          content: "Thời gian: 07h00 ngày 17/01/2025 đến 17h00 ngày 15/02/2025",
        ),
      ],
    );
  }
}
