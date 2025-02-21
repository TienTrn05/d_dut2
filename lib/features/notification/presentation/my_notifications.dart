import 'package:flutter/material.dart';

import './widgets/notification_card.dart';

class MyNotifications extends StatelessWidget {
  const MyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        NotificationCard(
          date: "15/02/2025",
          title:
              "Thầy Văn Công Vũ thông báo đến lớp: Kinh tế chính trị Mác - Lênin [24.Nh86]",
          content: "Thầy nhắn: Lớp NGHỈ HỌC (Tiết:3-4) ngày: 17/02/2025",
        ),
        NotificationCard(
          date: "14/02/2025",
          title:
              "Thầy Nguyễn Lê Minh thông báo đến lớp: TH Kỹ thuật vi điều khiển",
          content:
              "Khi đi thực hành, các bạn nhớ chuẩn bị trước và mang theo: Sách lập trình vi điều khiển PIC, laptop cá nhân...",
        ),
        NotificationCard(
          date: "15/02/2025",
          title:
              "Thầy Văn Công Vũ thông báo đến lớp: Kinh tế chính trị Mác - Lênin [24.Nh86]",
          content: "Thầy nhắn: Lớp NGHỈ HỌC (Tiết:3-4) ngày: 17/02/2025",
        ),
        NotificationCard(
          date: "14/02/2025",
          title:
              "Thầy Nguyễn Lê Minh thông báo đến lớp: TH Kỹ thuật vi điều khiển",
          content:
              "Khi đi thực hành, các bạn nhớ chuẩn bị trước và mang theo: Sách lập trình vi điều khiển PIC, laptop cá nhân...",
        ),
        NotificationCard(
          date: "15/02/2025",
          title:
              "Thầy Văn Công Vũ thông báo đến lớp: Kinh tế chính trị Mác - Lênin [24.Nh86]",
          content: "Thầy nhắn: Lớp NGHỈ HỌC (Tiết:3-4) ngày: 17/02/2025",
        ),
        NotificationCard(
          date: "14/02/2025",
          title:
              "Thầy Nguyễn Lê Minh thông báo đến lớp: TH Kỹ thuật vi điều khiển",
          content:
              "Khi đi thực hành, các bạn nhớ chuẩn bị trước và mang theo: Sách lập trình vi điều khiển PIC, laptop cá nhân...",
        ),
      ],
    );
  }
}