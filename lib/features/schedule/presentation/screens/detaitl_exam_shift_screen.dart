import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_info_card.dart';
import 'package:flutter/material.dart';

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
        appBar: CustomAppbar(label: "Thông tin chi tiết ca thi"),
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
                              itemBuilder: (context, index) => StudentItem(
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
