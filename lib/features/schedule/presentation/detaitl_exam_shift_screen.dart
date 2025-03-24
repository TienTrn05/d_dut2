import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/student_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/uos_info_card.dart';
import 'package:flutter/material.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';

class DetaitlExamShiftScreen extends StatefulWidget {
  const DetaitlExamShiftScreen({super.key});

  @override
  State<DetaitlExamShiftScreen> createState() => _DetaitlExamShiftScreenState();
}

class _DetaitlExamShiftScreenState extends State<DetaitlExamShiftScreen> {
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
              fontSize: FontSizes.medium,
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
                    fontSize: FontSizes.extraLarge,
                    fontWeight: FontWeight.bold,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
              Container(
                // height: 32,
                color: Colors.white,
                child: TabBar.secondary(
                  labelColor: Colors.white,
                  unselectedLabelColor: context.theme.grey,
                  indicator: BoxDecoration(
                    color: context.theme.primaryColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  dividerColor: context.theme.primaryColor,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13.0,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  // labelPadding:
                  //     EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  tabs: [
                    Tab(text: "Thông tin"),
                    Tab(text: "Danh sách sinh viên"),
                  ],
                ),
              ),
              // TabBarView
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: TabBarView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                            child: Column(
                              children: [
                                UosInfoCard(
                                  title: 'Thông tin chung',
                                  child: Column(
                                    children: [
                                      InfoItem(
                                          field: "Mã ca thi",
                                          value: "1024010.2420.21.11"),
                                      InfoItem(
                                          field: "Thời gian làm bài",
                                          value: "7:00, 13/12/2023"),
                                      InfoItem(
                                        field: "Phòng",
                                        value: "C202",
                                      ),
                                      InfoItem(
                                        field: "Xuất",
                                        value: "2C1",
                                      ),
                                      InfoItem(
                                        field: "Dạng đề",
                                        value: "Đề mở",
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                UosInfoCard(
                                  title: 'Cán bộ coi thi',
                                  child: Column(
                                    children: [
                                      InfoItem(
                                          field: "Cán bộ 1",
                                          value: "102-Trần Hồ Thủy Tiên"),
                                      InfoItem(
                                          field: "Cán bộ 2",
                                          value: "130-Đặng Thiên Bình"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          SearchBarCustom(),
                          Text(
                            "Sinh viên (10)",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
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
                                absentCount: index,
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
