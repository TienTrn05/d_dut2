import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/features/schedule/presentation/widgets/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';

class ExamShilftDetailScreen extends StatefulWidget {
  const ExamShilftDetailScreen({super.key});

  @override
  State<ExamShilftDetailScreen> createState() => _ExamShilftDetailScreenState();
}

class _ExamShilftDetailScreenState extends State<ExamShilftDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor,
          elevation: 0, // Xóa bóng dưới AppBar
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Quay lại màn hình trước
              },
            ),
          ),
          title: Text(
            'Thông tin chi tiết ca thi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationButton(
              notificationCount: 2,
              onTap: () =>
                  {Navigator.of(context).pushNamed(Routes.notification)},
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(24),
          child: Column(
            spacing: 10,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mạng máy tính",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
              Container(
                height: 28,
                color: Colors.white,
                child: TabBar.secondary(
                  labelColor: Colors.white,
                  unselectedLabelColor: context.theme.grey,
                  indicator: BoxDecoration(
                    color: context.theme.primaryColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: "Thông tin"),
                    Tab(text: "Danh sách sinh viên"),
                  ],
                ),
              ),
              // TabBarView
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: TabBarView(
                    children: [
                      Center(child: Text("Thông tin ca thi")),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          SearchBarCustom(),
                          Text(
                            "Sinh viên (10)",
                            style: TextStyle(
                              fontSize: 16,
                              color: context.theme.grey,
                            ),
                          ),
                          Expanded(
                            // Để danh sách có thể cuộn trong phần còn lại của màn hình
                            child: ListView.builder(
                              itemCount: 10,
                              itemBuilder: (context, index) => StudentCard(
                                name: "Nhật Hạ",
                                mail: "102210159@sv1.dut.udn.vn",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
