import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/absents_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/student_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/uos_info_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/uos_info_item.dart';
import 'package:flutter/material.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailUOSTeacherScreen extends StatefulWidget {
  const DetailUOSTeacherScreen({super.key});

  @override
  State<DetailUOSTeacherScreen> createState() => _DetailUOSTeacherScreenState();
}

class _DetailUOSTeacherScreenState extends State<DetailUOSTeacherScreen>
    with SingleTickerProviderStateMixin {
  bool isCheckAbsent = true;
  bool isOverlayVisible = false;
  late TabController _tabController;
  bool isSellectedAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Lắng nghe sự thay đổi tab và cập nhật state
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Cập nhật giao diện khi tab thay đổi
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            'Thông tin chi tiết học phần',
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
        body: Stack(
          children: [
            // Nội dung chính
            Container(
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
                      controller: _tabController,
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
                        Tab(text: "Điểm danh"),
                        Tab(text: "Thông báo"),
                      ],
                    ),
                  ),
                  // TabBarView
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: TabBarView(
                        controller: _tabController,
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
                                              field: "Mã lớp học phần",
                                              value: "1024010.2420.21.11"),
                                          InfoItem(
                                              field: "Mã môn", value: "123456"),
                                          InfoItem(
                                            field: "Hệ",
                                            value: "CLC",
                                          ),
                                          InfoItem(
                                            field: "Số tín chỉ",
                                            value: "03",
                                          ),
                                          InfoItem(
                                            field: "Kỳ học",
                                            value: "Học kì 1, 2025-2026",
                                          ),
                                          InfoItem(
                                            field: "Tuần học",
                                            value: "31-43",
                                          ),
                                          InfoItem(
                                            field: "TKB",
                                            value: "Thứ 4, 1-3, F109",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    UosInfoCard(
                                      title: 'Giảng dạy',
                                      child: Column(
                                        children: [
                                          InfoItem(
                                              field: "Hình thức GD",
                                              value: "Offline & Online"),
                                          UosInfoItem(
                                            field: "Mã truy cập",
                                            value: Text(
                                              "012ajsh",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                height: 1.5,
                                              ),
                                            ),
                                            linkIconAsset:
                                                "assets/icons/svg/lucide_copy.svg",
                                            action: () {
                                              try {
                                                Clipboard.setData(ClipboardData(
                                                    text: "012ajsh"));
                                                // debugPrint("Copied: 012ajsh");
                                                CustomSnackbar.showSnackBar(
                                                  context,
                                                  "Thành công",
                                                  "Đã sao chép mã 012ajsh",
                                                  AlertType.success,
                                                );
                                              } catch (e) {
                                                CustomSnackbar.showSnackBar(
                                                  context,
                                                  "Lỗi",
                                                  "Không thể sao chép",
                                                  AlertType.error,
                                                );
                                              }
                                            },
                                          ),
                                          UosInfoItem(
                                            field: "Link tham gia",
                                            value: GestureDetector(
                                              onTap: () async {
                                                final Uri url = Uri.parse(
                                                    "https://teams.microsoft.com/l/team/19%3Ad2pYw4aOqMVmggq1SStgmgoce9mEfA73aKGb_UzJbzQ1%40thread.tacv2/conversations?groupId=c2aeacc4-5d26-466b-a6be-ffb69ccfe8de&tenantId=42350984-d0f6-4a38-978a-aa84e495e429");
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url);
                                                } else if (context.mounted) {
                                                  CustomSnackbar.showSnackBar(
                                                    context,
                                                    "Lỗi",
                                                    "Không thể truy cập link",
                                                    AlertType.error,
                                                  );
                                                }
                                              },
                                              child: Text(
                                                "Link tham gia Teams",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                  fontStyle: FontStyle.italic,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: context
                                                          .theme.primaryColor ??
                                                      Colors.blue,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            linkIconAsset:
                                                "assets/icons/svg/lucide_copy.svg",
                                            action: () {
                                              try {
                                                Clipboard.setData(ClipboardData(
                                                    text:
                                                        "https://teams.microsoft.com/l/team/19%3Ad2pYw4aOqMVmggq1SStgmgoce9mEfA73aKGb_UzJbzQ1%40thread.tacv2/conversations?groupId=c2aeacc4-5d26-466b-a6be-ffb69ccfe8de&tenantId=42350984-d0f6-4a38-978a-aa84e495e429"));
                                                // debugPrint("Copied: 012ajsh");
                                                CustomSnackbar.showSnackBar(
                                                  context,
                                                  "Thành công",
                                                  "Đã sao chép đường link",
                                                  AlertType.success,
                                                );
                                              } catch (e) {
                                                CustomSnackbar.showSnackBar(
                                                  context,
                                                  "Lỗi",
                                                  "Không thể sao chép",
                                                  AlertType.error,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    UosInfoCard(
                                      title: 'Đánh giá',
                                      child: Column(
                                        children: [
                                          InfoItem(
                                              field: "Công thức điểm",
                                              value:
                                                  "[GK]*0.20+[BT]*0.20+[CK]*0.60"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isCheckAbsent) ...[
                                    Text(
                                      "Sinh viên (10)",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                    Text(
                                      "Vắng",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.theme.red,
                                      ),
                                    )
                                  ] else ...[
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: Checkbox(
                                            value: isSellectedAll,
                                            activeColor:
                                                context.theme.primaryColor,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                // Chọn tất cả
                                                isSellectedAll =
                                                    !isSellectedAll;
                                              });
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Chọn tất cả (10)",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: context.theme.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Điểm danh",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.theme.grey,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) => StudentCard(
                                    name: "Nhật Hạ",
                                    mail: "102210159@sv1.dut.udn.vn",
                                    absentCount: index,
                                    isCheckAbsent: isCheckAbsent,
                                    isAbsentToday: isSellectedAll,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(child: Text("Thông báo")),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Overlay
            if (isOverlayVisible)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isOverlayVisible = !isOverlayVisible;
                    });
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                    ),
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOverlayVisible) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(
                            child: FloatingActionButton.small(
                              onPressed: () {
                                setState(() {
                                  isCheckAbsent = !isCheckAbsent;
                                  isOverlayVisible = !isOverlayVisible;
                                });
                              },
                              backgroundColor: context.theme.lightBlue,
                              shape: CircleBorder(),
                              foregroundColor: Colors.white,
                              child: SvgPicture.asset(
                                isCheckAbsent
                                    ? "assets/icons/svg/student_tracking_overview.svg"
                                    : "assets/icons/svg/student_tracking.svg",
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ], // Khoảng cách giữa hai FAB]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOverlayVisible) ...[
                        Text(
                          !isCheckAbsent ? "Tổng quan" : "Điểm danh",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            isOverlayVisible = !isOverlayVisible;
                          });
                        },
                        backgroundColor: context.theme.primaryColor,
                        shape: CircleBorder(),
                        child: SvgPicture.asset(
                          isCheckAbsent
                              ? "assets/icons/svg/student_tracking.svg"
                              : "assets/icons/svg/student_tracking_overview.svg",
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
